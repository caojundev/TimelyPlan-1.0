import Foundation
import StoreKit
import Combine   // ObservableObject / @Published（SwiftUI 会自动桥接，UIKit 下也能用）

/// 内购管理模块的主入口（门面 / Facade）。
///
/// ## 接入方式
/// ```swift
/// // 1) 配置产品 ID（唯一必填步骤）
/// let config = IAPConfiguration(products: [
///     .monthly("com.app.premium.month"),
///     .yearly ("com.app.premium.year"),
///     .lifetime("com.app.premium.lifetime")
/// ])
///
/// // 2) 创建并启动
/// let iap = IAPManager(configuration: config)
/// iap.start()
///
/// // 3) 使用
/// await iap.loadProducts()
/// let result = await iap.purchase("com.app.premium.year")
/// if iap.entitlement.isActive { /* 解锁 */ }
/// ```
///
/// 标记 `@MainActor`：`@Published` 状态只在主线程变更，SwiftUI 绑定天然安全。
@MainActor
public final class IAPManager: ObservableObject {

    // MARK: - 单例（可选用法）

    /// 共享实例。未配置时调用 `configure(products:)` 即可。
    public static let shared = IAPManager()

    // MARK: - 对外状态

    /// 已加载的、可购买的商品（按 order 排序）
    @Published public private(set) var products: [IAPStoreProduct] = [] {
        didSet { notifyProducts() }
    }

    /// 当前权益快照——UI 依据它决定解锁
    @Published public private(set) var entitlement: IAPEntitlement = .empty {
        didSet { notifyEntitlement() }
    }

    /// 是否正在加载商品
    @Published public private(set) var isLoadingProducts = false

    /// 最近一次错误（供 UI 提示，读取后可由业务清空）
    @Published public var lastError: Error?

    // MARK: - 内部

    private nonisolated let observer: TransactionObserver
    private nonisolated let storage: IAPStorage

    private var config: IAPConfiguration?
    private var started = false

    /// 是否启用本地缓存（默认启用）
    public var enableCache = true

    /// 权益变化观察者（跨平台：UIKit / SwiftUI / 纯 Swift 均可用）
    private var entitlementObservers: [IAPObserverBox<IAPEntitlement>] = []

    /// 商品列表变化观察者
    private var productsObservers: [IAPObserverBox<[IAPStoreProduct]>] = []

    // MARK: - 跨平台事件订阅（UIKit 推荐用这个）

    /// 订阅权益变化。返回的对象释放时自动取消订阅。
    ///
    /// ```swift
    /// token = iap.observeEntitlement { [weak self] entitlement in
    ///     self?.unlock(entitlement.isActive)
    /// }
    /// ```
    @discardableResult
    public func observeEntitlement(
        _ handler: @escaping (IAPEntitlement) -> Void
    ) -> IAPObservationToken {
        let box = IAPObserverBox(handler)
        entitlementObservers.append(box)
        // 立即回放一次当前值，订阅方无需手动取初始状态
        handler(entitlement)
        return IAPObservationToken { [weak self] in
            self?.entitlementObservers.removeAll { $0 === box }
        }
    }

    /// 订阅商品列表变化。返回的对象释放时自动取消订阅。
    @discardableResult
    public func observeProducts(
        _ handler: @escaping ([IAPStoreProduct]) -> Void
    ) -> IAPObservationToken {
        let box = IAPObserverBox(handler)
        productsObservers.append(box)
        handler(products)
        return IAPObservationToken { [weak self] in
            self?.productsObservers.removeAll { $0 === box }
        }
    }

    /// 通知所有权益观察者（内部使用）
    private func notifyEntitlement() {
        let value = entitlement
        entitlementObservers.forEach { $0.handler(value) }
    }

    /// 通知所有商品观察者（内部使用）
    private func notifyProducts() {
        let value = products
        productsObservers.forEach { $0.handler(value) }
    }

    // MARK: - 生命周期

    /// 使用共享单例时，用这个方法注入配置。
    /// - Parameter autoStart: 是否立即启动（默认 true）
    public func configure(_ configuration: IAPConfiguration, autoStart: Bool = true) {
        self.config = configuration
        if autoStart { start() }
    }

    /// 指定配置创建实例（推荐）
    public init(configuration: IAPConfiguration, storage: IAPStorage = IAPStorage()) {
        self.config = configuration
        self.storage = storage
        // 注意：不能在 init 里让回调闭包捕获 self（即使只捕获 weak self 也可能被并发检查拦下）。
        // 这里改为捕获一个先于 self 存在的转发器，初始化完成后再把 self 装进去。
        let relay = ManagerRelay()
        self.observer = Self.makeObserver(relay: relay)
        relay.manager = self
        // 先用缓存点亮 UI，随后 start() 会用线上权威值覆盖
        if enableCache { self.entitlement = storage.load() }
    }

    /// 单例用空初始化
    private init() {
        self.storage = IAPStorage()
        let relay = ManagerRelay()
        self.observer = Self.makeObserver(relay: relay)
        relay.manager = self
    }

    /// 构造交易监听器。抽成静态方法给两个 init 复用，
    /// 同时保证闭包只捕获 `relay`，不接触尚未初始化完成的 `self`。
    private static func makeObserver(relay: ManagerRelay) -> TransactionObserver {
        TransactionObserver(
            onTransaction: { _ in
                // 交易回调来自后台线程，交给转发器回主 actor 刷新权益
                Task { await relay.refreshEntitlement() }
            },
            onUnverified: { message in
                #if DEBUG
                print("[IAPManager] 未验签交易：\(message)")
                #endif
            }
        )
    }

    deinit { observer.stop() }

    // MARK: - 公开 API

    /// 启动模块：开启交易监听并刷新一次权益。
    /// 建议在 App 启动时调用（或依赖 `configure(autoStart: true)`）。
    public func start() {
        guard !started, config != nil else { return }
        started = true
        if config?.autoStartObserving == true { observer.start() }
        Task { await refreshEntitlement() }
    }

    /// 从 App Store 拉取商品信息。进入付费页面前调用一次即可。
    @discardableResult
    public func loadProducts() async -> [IAPStoreProduct] {
        guard let config = self.config else { return [] }

        isLoadingProducts = true
        defer { isLoadingProducts = false }

        do {
            let ids = config.products.map(\.id)
            let storeProducts = try await Product.products(for: ids)

            // 按配置顺序（order 升序）组装
            let index = config.productIndex
            let mapped: [IAPStoreProduct] = storeProducts.compactMap { sp in
                guard let def = index[sp.id] else { return nil }
                return IAPStoreProduct(
                    product: sp, kind: def.kind, group: def.group, order: def.order
                )
            }
            .sorted { $0.order < $1.order }

            self.products = mapped
            return mapped
        } catch {
            self.lastError = error
            return []
        }
    }

    /// 购买指定商品。
    /// - Parameter productID: 配置中的产品 ID
    @discardableResult
    public func purchase(_ productID: String) async -> IAPPurchaseResult {
        guard let product = products.first(where: { $0.id == productID })?.product else {
            return .failed(IAPError.productNotFound(productID).localizedDescription)
        }
        return await purchase(product)
    }

    /// 购买指定商品（直接传已加载的 `IAPStoreProduct`）
    @discardableResult
    public func purchase(_ storeProduct: IAPStoreProduct) async -> IAPPurchaseResult {
        await purchase(storeProduct.product)
    }

    /// 恢复购买（App Store 要求必须提供的能力）
    @discardableResult
    public func restore() async -> IAPEntitlement {
        do {
            try await AppStore.sync()
        } catch {
            self.lastError = error
        }
        return await refreshEntitlement()
    }

    /// 重新读取当前权益（可随时调用）
    @discardableResult
    public func refreshEntitlement() async -> IAPEntitlement {
        guard let config = self.config else { return .empty }

        var transactions: [Transaction] = []
        for await result in Transaction.currentEntitlements {
            if case .verified(let tx) = result {
                transactions.append(tx)
            }
        }
        let snapshot = EntitlementBuilder.build(from: transactions, config: config)
        if enableCache { storage.save(snapshot) }
        self.entitlement = snapshot
        return snapshot
    }

    /// 某商品当前是否可售
    public func isAvailable(_ productID: String) -> Bool {
        products.contains { $0.id == productID }
    }

    /// 是否拥有某个业务分组的权限。
    /// 例如月/年订阅同属 `"premium"` 组，任一有效即返回 true。
    public func hasAccess(toGroup group: String) -> Bool {
        guard let config = self.config else { return false }
        let groupIndex = config.groupIndex
        return entitlement.activeProductIDs.contains { groupIndex[$0] == group }
    }

    // MARK: - 内部购买实现

    private func purchase(_ product: Product) async -> IAPPurchaseResult {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    let snapshot = await refreshEntitlement()
                    return .success(entitlement: snapshot)

                case .unverified(_, let error):
                    return .unverified(error.localizedDescription)
                }

            case .userCancelled:
                return .userCancelled

            case .pending:
                return .pending

            @unknown default:
                return .failed(IAPError.unknown.localizedDescription)
            }
        } catch {
            return .failed(error.localizedDescription)
        }
    }
}

// MARK: - 内部辅助

/// `IAPManager` 与交易回调之间的弱引用转发器。
///
/// 存在的唯一理由：`TransactionObserver` 的回调是逃逸闭包，而它是在 `IAPManager.init`
/// 里接线的。若闭包直接引用 `self`，会触发 “self used before being initialized”
/// （`observer` 此刻还没赋值）；只捕获 `weak self` 又会在跨隔离域时触发
/// “reference to captured var 'self'”。因此把弱引用装进这个先于 `self` 诞生的盒子里，
/// 等 init 结束后再赋值，两个问题都不复存在。
@MainActor
private final class ManagerRelay {

    /// 由 `IAPManager.init` 在自身初始化完成后写入
    weak var manager: IAPManager?

    /// 供后台事务回调调用：回主 actor 刷新权益
    func refreshEntitlement() {
        Task { await manager?.refreshEntitlement() }
    }
}
