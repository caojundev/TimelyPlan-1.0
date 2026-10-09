import Foundation

/// 权益的本地缓存。
///
/// 作用：断网冷启动时先展示上一次的权益，避免用户"被掉会员"的观感；
/// 联网后由 `IAPManager.refreshEntitlement()` 覆盖为权威值。
///
/// 注意：**本地缓存仅供 UI 兜底，绝不可作为验权依据**。
///
/// `UserDefaults` 官方文档明确其线程安全（内部有锁），但 SDK 未声明 `Sendable`，
/// 因此这里用 `@unchecked` 手动承诺；本类型仅持有它，不做可变状态共享。
public struct IAPStorage: @unchecked Sendable {

    private let key: String
    private let defaults: UserDefaults

    public init(key: String = "com.iapmanager.entitlement.cache", defaults: UserDefaults = .standard) {
        self.key = key
        self.defaults = defaults
    }

    /// 缓存权益快照
    public func save(_ entitlement: IAPEntitlement) {
        let payload = Payload(
            ids: Array(entitlement.activeProductIDs),
            subs: Array(entitlement.activeSubscriptionIDs),
            lifetimes: Array(entitlement.activeLifetimeIDs),
            expiry: entitlement.subscriptionExpiryDate
        )
        guard let data = try? JSONEncoder().encode(payload) else { return }
        defaults.set(data, forKey: key)
    }

    /// 读取缓存（无缓存返回 `.empty`）
    public func load() -> IAPEntitlement {
        guard let data = defaults.data(forKey: key),
              let payload = try? JSONDecoder().decode(Payload.self, from: data) else {
            return .empty
        }
        return IAPEntitlement(
            activeProductIDs: Set(payload.ids),
            activeSubscriptionIDs: Set(payload.subs),
            activeLifetimeIDs: Set(payload.lifetimes),
            subscriptionExpiryDate: payload.expiry
        )
    }

    /// 清空缓存（如登出账号时）
    public func clear() {
        defaults.removeObject(forKey: key)
    }

    private struct Payload: Codable {
        let ids: [String]
        let subs: [String]
        let lifetimes: [String]
        let expiry: Date?
    }
}
