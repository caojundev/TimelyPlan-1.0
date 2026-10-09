import Foundation
import StoreKit

/// 把 StoreKit 的 `Transaction` / `currentEntitlements` 结果翻译成业务侧的 `IAPEntitlement`。
/// 纯函数集合，无状态，便于测试。
enum EntitlementBuilder {

    /// 从一批已验签的交易推导权益快照。
    /// - Parameters:
    ///   - transactions: `Transaction.currentEntitlements` 中所有 `.verified` 的交易
    ///   - config: 商品配置（用于区分订阅/买断）
    ///   - now: 当前时间，便于测试注入
    static func build(
        from transactions: [Transaction],
        config: IAPConfiguration,
        now: Date = Date()
    ) -> IAPEntitlement {

        let index = config.productIndex
        var activeIDs = Set<String>()
        var subscriptionIDs = Set<String>()
        var lifetimeIDs = Set<String>()
        var latestExpiry: Date?

        for tx in transactions {
            guard let def = index[tx.productID] else { continue }   // 非本模块管理的商品，忽略

            switch def.kind {
            case .nonConsumable:
                // 买断制：一旦购买永久有效
                guard tx.revocationDate == nil else { continue }     // 被退款/撤销
                activeIDs.insert(tx.productID)
                lifetimeIDs.insert(tx.productID)

            case .subscription:
                // 订阅：需要判断是否在有效期内或被撤销
                guard tx.revocationDate == nil else { continue }
                if let expiry = tx.expirationDate {
                    guard expiry > now else { continue }             // 已过期
                    if latestExpiry == nil || expiry > latestExpiry! {
                        latestExpiry = expiry
                    }
                }
                activeIDs.insert(tx.productID)
                subscriptionIDs.insert(tx.productID)
            }
        }

        return IAPEntitlement(
            activeProductIDs: activeIDs,
            activeSubscriptionIDs: subscriptionIDs,
            activeLifetimeIDs: lifetimeIDs,
            subscriptionExpiryDate: latestExpiry
        )
    }
}
