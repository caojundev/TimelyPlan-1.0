//
//  IAPManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/10.
//

import Foundation
import StoreKit
import os.log

// MARK: - 订阅管理器
@MainActor
final class SubscriptionManager: ObservableObject {
    
    static let shared = SubscriptionManager()
    
    // MARK: 发布属性
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isEntitled: Bool = false
    @Published private(set) var activeSubscriptions: [Product] = []
    @Published private(set) var currentSubscription: Product?
    
    // MARK: 私有属性
    private var products: [Product] = []
    private var productIDs: Set<String> = []
    private var transactionListener: Task<Void, Error>?
    private let logger = Logger(subsystem: "com.app.subscription", category: "StoreKit")
    private let defaults = UserDefaults.standard
    
    private init() {
        startTransactionListener()
    }
    
    deinit {
        transactionListener?.cancel()
    }
}

// MARK: - 公开接口
extension SubscriptionManager {
    
    /// 配置产品ID列表
    func configure(with productIDs: Set<String>) {
        self.productIDs = productIDs
        Task {
            await loadProducts()
            await updatePurchasedState()
        }
    }
    
    /// 加载产品
    func loadProducts() async {
        guard !productIDs.isEmpty else {
            logger.warning("产品ID列表为空，请先调用 configure")
            return
        }
        
        do {
            let storeProducts = try await Product.products(for: productIDs)
            self.products = storeProducts
            
            // 缓存产品信息
            cacheProducts(storeProducts)
            
            logger.info("成功加载 \(storeProducts.count) 个产品")
        } catch {
            logger.error("加载产品失败: \(error.localizedDescription)")
        }
    }
    
    /// 购买产品
    func purchase(_ product: Product) async throws {
        logger.info("开始购买: \(product.id)")
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try verifyTransaction(verification)
            await handlePurchaseSuccess(for: transaction)
            logger.info("购买成功: \(transaction.productID)")
            
        case .userCancelled:
            logger.info("用户取消购买")
            throw SubscriptionError.userCancelled
            
        case .pending:
            logger.info("购买等待中")
            throw SubscriptionError.pending
            
        @unknown default:
            throw SubscriptionError.unknown
        }
    }
    
    /// 恢复购买
    func restorePurchases() async throws {
        logger.info("开始恢复购买")
        try await AppStore.sync()
        await updatePurchasedState()
    }
    
    /// 检查是否有有效订阅
    func checkEntitlement() async -> Bool {
        await updatePurchasedState()
        return isEntitled
    }
    
    /// 获取产品信息
    func product(for productID: String) -> Product? {
        return products.first { $0.id == productID }
    }
}

// MARK: - 内部处理
private extension SubscriptionManager {
    
    /// 启动交易监听器
    func startTransactionListener() {
        transactionListener = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { break }
                
                await MainActor.run {
                    self.handleTransactionUpdate(result)
                }
            }
        }
    }
    
    /// 处理交易更新
    func handleTransactionUpdate(_ result: VerificationResult<Transaction>) {
        switch result {
        case .verified(let transaction):
            Task {
                await handleVerifiedTransaction(transaction)
            }
            
        case .unverified(let transaction, let error):
            logger.error("未验证交易: \(transaction.id), 错误: \(error.localizedDescription)")
        }
    }
    
    /// 处理已验证的交易
    func handleVerifiedTransaction(_ transaction: Transaction) async {
        // 完成交易
        await transaction.finish()
        
        // 更新购买状态
        if transaction.revocationDate == nil {
            // 有效的购买
            await handlePurchaseSuccess(for: transaction)
        } else {
            // 已撤销的购买
            await handleRevocation(for: transaction)
        }
    }
    
    /// 处理购买成功
    func handlePurchaseSuccess(for transaction: Transaction) async {
        purchasedProductIDs.insert(transaction.productID)
        await updateEntitlementStatus()
    }
    
    /// 处理购买撤销
    func handleRevocation(for transaction: Transaction) async {
        purchasedProductIDs.remove(transaction.productID)
        await updateEntitlementStatus()
        logger.info("购买已撤销: \(transaction.productID)")
    }
    
    /// 验证交易
    func verifyTransaction(_ result: VerificationResult<Transaction>) throws -> Transaction {
        switch result {
        case .verified(let transaction):
            return transaction
            
        case .unverified(_, let error):
            throw SubscriptionError.verificationFailed(error)
        }
    }
    
    /// 更新购买状态
    func updatePurchasedState() async {
        var purchasedIDs = Set<String>()
        var activeProducts = [Product]()
        
        // 从缓存恢复
        if let cached = getCachedProductIDs() {
            purchasedIDs = cached
        }
        
        // 检查当前权利
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.revocationDate == nil {
                    // 检查是否过期
                    if let expirationDate = transaction.expirationDate,
                       expirationDate > Date() {
                        purchasedIDs.insert(transaction.productID)
                        
                        if let product = products.first(where: { $0.id == transaction.productID }) {
                            activeProducts.append(product)
                        }
                    }
                }
            }
        }
        
        self.purchasedProductIDs = purchasedIDs
        self.activeSubscriptions = activeProducts
        self.currentSubscription = activeProducts.first
        
        // 更新缓存
        cacheProductIDs(purchasedIDs)
        
        // 更新权利状态
        await updateEntitlementStatus()
    }
    
    /// 更新权利状态
    func updateEntitlementStatus() async {
        isEntitled = !activeSubscriptions.isEmpty
    }
}

// MARK: - 缓存管理
private extension SubscriptionManager {
    
    private enum CacheKeys {
        static let productIDs = "com.subscription.cachedProductIDs"
        static let products = "com.subscription.cachedProducts"
        static let lastRefresh = "com.subscription.lastRefreshDate"
    }
    
    /// 缓存产品ID
    func cacheProductIDs(_ ids: Set<String>) {
        defaults.set(Array(ids), forKey: CacheKeys.productIDs)
        defaults.set(Date(), forKey: CacheKeys.lastRefresh)
    }
    
    /// 获取缓存的产品ID
    func getCachedProductIDs() -> Set<String>? {
        guard let ids = defaults.array(forKey: CacheKeys.productIDs) as? [String] else {
            return nil
        }
        return Set(ids)
    }
    
    /// 缓存产品信息
    func cacheProducts(_ products: [Product]) {
        let productData = products.map { product -> [String: Any] in
            return [
                "id": product.id,
                "displayName": product.displayName,
                "description": product.description,
                "price": product.price as Any,
                "displayPrice": product.displayPrice
            ]
        }
        defaults.set(productData, forKey: CacheKeys.products)
    }
}

// MARK: - 错误类型
enum SubscriptionError: LocalizedError {
    case userCancelled
    case pending
    case unknown
    case verificationFailed(Error)
    case productNotFound
     
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "用户取消了购买"
        case .pending:
            return "购买等待中，需要家长批准"
        case .unknown:
            return "发生未知错误"
        case .verificationFailed(let error):
            return "交易验证失败: \(error.localizedDescription)"
        case .productNotFound:
            return "未找到对应产品"
        }
    }
}

// MARK: - 使用示例
/*
 
 // 在 App 启动时配置
 SubscriptionManager.shared.configure(with: [
     "com.app.premium.monthly",
     "com.app.premium.yearly"
 ])
 
 // 在视图中使用
 struct ContentView: View {
     @StateObject private var subscriptionManager = SubscriptionManager.shared
     
     var body: some View {
         VStack {
             if subscriptionManager.isEntitled {
                 Text("已订阅")
             } else {
                 // 显示购买界面
             }
         }
     }
 }
 
 // 购买
 if let product = SubscriptionManager.shared.product(for: "com.app.premium.monthly") {
     Task {
         do {
             try await SubscriptionManager.shared.purchase(product)
         } catch {
             // 处理错误
         }
     }
 }
 
 // 恢复购买
 Task {
     try? await SubscriptionManager.shared.restorePurchases()
 }
 
 */
