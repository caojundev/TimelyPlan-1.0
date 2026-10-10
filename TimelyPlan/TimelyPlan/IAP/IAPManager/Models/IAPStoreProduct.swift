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

    /// 订阅周期文案，如 "每月" / "每年"；买断制返回 nil。
    public var subscriptionPeriodText: String? {
        guard let period = product.subscription?.subscriptionPeriod else { return nil }
        // iOS 15 上 unit 枚举仅有 day/week/month/year 四类（不含 nil-unit case）
        switch period.unit {
        case .day:   return period.value == 1 ? "每天" : "\(period.value) 天"
        case .week:  return period.value == 1 ? "每周" : "\(period.value) 周"
        case .month: return period.value == 1 ? "每月" : "\(period.value) 个月"
        case .year:  return period.value == 1 ? "每年" : "\(period.value) 年"
        @unknown default: return nil
        }
    }

    /// 是否提供免费试用（有 introductory offer 且为免费试用）
    public var hasFreeTrial: Bool {
        guard let intro = product.subscription?.introductoryOffer else { return false }
        return intro.paymentMode == .freeTrial
    }

    /// 免费试用周期文案，如 "7 天免费试用"；无试用返回 nil。
    public var freeTrialText: String? {
        guard let intro = product.subscription?.introductoryOffer,
              intro.paymentMode == .freeTrial else { return nil }
        let p = intro.period
        let unitText: String
        switch p.unit {
        case .day:   unitText = "天"
        case .week:  unitText = "周"
        case .month: unitText = "个月"
        case .year:  unitText = "年"
        @unknown default: unitText = ""
        }
        return "\(p.value) \(unitText)免费试用"
    }
}
