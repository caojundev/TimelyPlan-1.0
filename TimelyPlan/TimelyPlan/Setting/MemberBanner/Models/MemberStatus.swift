//
//  MemberStatus.swift
//  MemberBanner
//
//  数据模型层：只描述「要展示什么」，不含任何 UI 代码。
//  这样 View 与业务数据解耦 —— 只要组装出 MemberStatus 就能渲染 Banner。
//

import Foundation
import StoreKit

/// 会员档位
enum MembershipTier: String, CaseIterable {
    case monthly  = "monthly"
    case yearly   = "yearly"
    case lifetime = "lifetime"

    /// 展示名称（如「年度」）
    var displayName: String {
        switch self {
        case .monthly:
            return resGetString("Monthly Plan")
        case .yearly:
            return resGetString("Yearly Plan")
        case .lifetime:
            return resGetString("Lifetime Plan")
        }
    }
}

/// 会员状态模型
struct MemberStatus {
    
    /// 会员档位
    let tier: MembershipTier

    /// 到期时间。永久会员无到期日，传 nil 即可。
    let expireDate: Date?
    
    /// 权益是否全部解锁
    let isAllUnlocked: Bool
    
    /// 剩余天数（永久会员或未拿到到期时间时为 nil）
    var remainingDays: Int? {
        guard let expireDate = expireDate else {
            return nil
        }
        
        return max(Date.days(fromDate: Date(), toDate: expireDate), 0)
    }
    
    /// 剩余天数文案：0 显示「今天」，1 用单数，大于 1 用复数
    var remainingDaysText: String? {
        guard let remainingDays = remainingDays else {
            return nil
        }
        
        switch remainingDays {
        case 0:
            return resGetString("Today")
        case 1:
            return String(format: resGetString("%ld day left"), remainingDays)
        default:
            return String(format: resGetString("%ld days left"), remainingDays)
        }
    }

    // MARK: - 派生展示文案（把「怎么拼字」收敛到模型，View 只负责排版）

    /// 卡片主标题：「尊享会员 · 年度」
    var cardTitle: String {
        return "\(resGetString("Premium")) • \(tier.displayName)"
    }

    /// 卡片副标题：「有效期至 2027年3月15日 · 剩余 519 天」
    /// 永久会员展示为「终身有效 · 永久权益」
    var cardSubtitle: String {
        if tier == .lifetime {
            return resGetString("Lifetime access · Permanent benefits")
        }
        
        var parts: [String] = []
        if let expireDate = expireDate {
            parts.append(String(format: resGetString("Valid until %@"), expireDate.yearMonthDayString))
        }
        
        if let remainingDaysText = remainingDaysText {
            parts.append(remainingDaysText)
        }
        
        return parts.joined(separator: " • ")
    }

    /// 权益状态文案
    var unlockText: String {
        return resGetString("All benefits unlocked")
    }
}

// MARK: - 由内购权益组装
extension MemberStatus {
    
    /// 从内购权益与商品信息组装（未开通会员返回 nil）
    /// - Parameters:
    ///   - entitlement: `IAPManager.entitlement` 当前权益快照
    ///   - products: `IAPManager.products` 已加载的商品，用于识别订阅周期（可为空）
    static func make(from entitlement: IAPEntitlement,
                     products: [IAPStoreProduct] = []) -> MemberStatus? {
        guard entitlement.isActive else {
            return nil
        }
        
        return MemberStatus(tier: tier(for: entitlement, products: products),
                            expireDate: entitlement.subscriptionExpiryDate,
                            isAllUnlocked: true)
    }
    
    /// 会员档位
    private static func tier(for entitlement: IAPEntitlement,
                             products: [IAPStoreProduct]) -> MembershipTier {
        /// 买断制：永久会员
        if !entitlement.activeLifetimeIDs.isEmpty {
            return .lifetime
        }
        
        /// 订阅：优先按已加载商品的订阅周期判断（年 / 月）
        let subscription = products
            .filter { entitlement.activeSubscriptionIDs.contains($0.id) }
            .sorted { $0.order < $1.order }
            .first
        if let subscription = subscription {
            return subscription.isYearlySubscription ? .yearly : .monthly
        }
        
        /// 商品未加载时按配置的 Product ID 兜底
        if entitlement.hasAccess(to: AppConfig.IAP.yearly) {
            return .yearly
        }
        
        return .monthly
    }
}
