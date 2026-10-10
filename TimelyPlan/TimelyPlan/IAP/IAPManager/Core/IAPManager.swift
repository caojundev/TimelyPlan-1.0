import Foundation
import StoreKit
import Combine

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

    /// `Transaction.updates` 监听器。回调在 `start()` 中配置（见该方法注释）
    private nonisolated let observer = IAPTransactionObserver()
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
        // 先用缓存点亮 UI，随后 start() 会用线上权威值覆盖
        if enableCache { self.entitlement = storage.load() }
    }

    /// 单例用空初始化
    private init() {
        self.storage = IAPStorage()
    }

    deinit { observer.stop() }

    // MARK: - 公开 API

    /// 启动模块：开启交易监听并刷新一次权益。
    /// 建议在 App 启动时调用（或依赖 `configure(autoStart: true)`）。
    public func start() {
        guard !started, let config = config else { return }
        started = true

        if config.autoStartObserving {
            // 回调在这里（而非 init）接线：init 里创建的逃逸闭包若捕获 self，
            // 会触发 “self used before being initialized”
            observer.configure(
                onTransaction: { [weak self] _ in
                    guard let self = self else { return }
                    Task { await self.refreshEntitlement() }
                },
                onUnverified: { message in
                    #if DEBUG
                    print("[IAPManager] 未验签交易：\(message)")
                    #endif
                }
            )
            observer.start()
        }

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
        let snapshot = IAPEntitlementBuilder.build(from: transactions, config: config)
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
