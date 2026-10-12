//
//  IAPStoreProduct.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/05.
//

import Foundation
import StoreKit

/// 一个已加载的、可购买的商品（StoreKit `Product` 的业务侧包装）。
/// 持有原始 `Product`，业务层可直接拿来做 UI 展示（价格、名称、描述）。
///
/// StoreKit 2 的 `Product` 本身是不可变值类型（只读成员，无可变状态），跨线程传递安全，
/// 但部分 SDK 版本未为其声明 `Sendable` 一致性，因此这里用 `@unchecked` 手动承诺。
public struct IAPStoreProduct: Identifiable, @unchecked Sendable {

    /// App Store 返回的原始商品对象
    public let product: Product

    /// 你在配置里声明的类型
    public let kind: ProductKind

    /// 业务分组
    public let group: String

    /// 展示顺序
    public let order: Int

    /// 产品 ID
    public var id: String { product.id }

    /// App Store 本地化后的价格文案，如 "¥25.00"
    public var displayPrice: String { product.displayPrice }

    /// 本地化名称
    public var displayName: String { product.displayName }

    /// 本地化描述
    public var description: String { product.description }

    /// 是否为订阅
    public var isSubscription: Bool { kind == .subscription }

    /// 订阅周期是否为「年」
    var isYearlySubscription: Bool {
        guard let period = product.subscription?.subscriptionPeriod else {
            return false
        }
        
        return period.unit == .year
    }
    
    /// 订阅周期文案，如 "每月" / "3 个月"；买断制返回 nil。
    public var subscriptionPeriodText: String? {
        guard let period = product.subscription?.subscriptionPeriod else { return nil }
        return Self.periodText(value: period.value, unit: period.unit)
    }

    /// 是否提供免费试用（有 introductory offer 且为免费试用）
    public var hasFreeTrial: Bool {
        guard let intro = product.subscription?.introductoryOffer else { return false }
        return intro.paymentMode == .freeTrial
    }

    /// 免费试用周期文案，如 "7 天免费试用"；无试用返回 nil。
    public var freeTrialText: String? {
        guard let intro = product.subscription?.introductoryOffer,
              intro.paymentMode == .freeTrial,
              let periodText = Self.periodText(value: intro.period.value, unit: intro.period.unit) else {
            return nil
        }
        
        return String(format: resGetString("%@ free trial"), periodText)
    }
    
    // MARK: - 周期文案
    /// 周期文案：单数取「每日 / 每周 / 每月 / 每年」，复数拼接数量（如 "3 个月"）
    private static func periodText(value: Int, unit: Product.SubscriptionPeriod.Unit) -> String? {
        switch unit {
        case .day:
            return value == 1 ? resGetString("Daily") : String(format: resGetString("%ld days"), value)
        case .week:
            return value == 1 ? resGetString("Weekly") : String(format: resGetString("%ld weeks"), value)
        case .month:
            return value == 1 ? resGetString("Monthly") : String(format: resGetString("%ld months"), value)
        case .year:
            return value == 1 ? resGetString("Yearly") : String(format: resGetString("%ld years"), value)
        @unknown default:
            return nil
        }
    }
}
