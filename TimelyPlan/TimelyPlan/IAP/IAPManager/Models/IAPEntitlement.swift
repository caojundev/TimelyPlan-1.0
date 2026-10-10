//
//  IAPEntitlement.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/05.
//

import Foundation

/// 当前用户的会员权益快照。
/// 这是业务层唯一需要读取的状态——UI 依据它决定解锁哪些功能。
public struct IAPEntitlement: Sendable, Equatable {

    /// 当前生效的商品 ID 集合（订阅未过期 + 永久买断）
    public let activeProductIDs: Set<String>

    /// 其中属于订阅的
    public let activeSubscriptionIDs: Set<String>

    /// 其中属于买断制的
    public let activeLifetimeIDs: Set<String>

    /// 订阅到期时间的内部存储。
    /// 存 `TimeInterval` 而不是 `Date`：部分工具链（Xcode 13 / Swift 5.5–5.6）的
    /// Foundation 尚未为 `Date` 标注 `Sendable`，直接存 `Date?` 会让本结构体
    /// 无法满足 `Sendable` 约束。`TimeInterval` 即 `Double`，任何版本都安全。
    private let subscriptionExpiryTimestamp: TimeInterval?

    /// 订阅到期时间（取所有生效订阅中最晚的一个）
    public var subscriptionExpiryDate: Date? {
        subscriptionExpiryTimestamp.map(Date.init(timeIntervalSince1970:))
    }

    public init(
        activeProductIDs: Set<String> = [],
        activeSubscriptionIDs: Set<String> = [],
        activeLifetimeIDs: Set<String> = [],
        subscriptionExpiryDate: Date? = nil
    ) {
        self.activeProductIDs = activeProductIDs
        self.activeSubscriptionIDs = activeSubscriptionIDs
        self.activeLifetimeIDs = activeLifetimeIDs
        self.subscriptionExpiryTimestamp = subscriptionExpiryDate?.timeIntervalSince1970
    }

    /// 是否拥有任意权益
    public var isActive: Bool { !activeProductIDs.isEmpty }

    /// 是否拥有指定商品的权益。传入产品 ID 即可，常用于做功能门禁。
    public func hasAccess(to productID: String) -> Bool {
        activeProductIDs.contains(productID)
    }

    public static let empty = IAPEntitlement()
}
