//
//  IAPPaywallProduct.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import StoreKit

/// 商品特性信息
struct IAPFeature {
    let text: String
    let highlighted: Bool  // true = 蓝色高亮, false = 灰色
    
    static var empty: IAPFeature {
        return IAPFeature(text: "", highlighted: false)
    }
}

/// 内购商品完整配置
struct IAPPaywallProduct {
    let id: String
    let title: String               // "Yearly" / "Monthly" / "Lifetime"
    let discountText: String?       // "Save 23%", nil 则不显示
    let feature: IAPFeature         // 卡片上展示的一行特性
    let priceText: String           // "¥98/yr"
    let originalPriceText: String?  // "Original ¥128/yr", nil 则不显示
    let priceNote: String?          // "Billed monthly", nil 则不显示

    /// 转换来源：由 `IAPStoreProduct` 转换而来时保留原商品，购买时直接使用；
    /// 手工构造（预览 / 兜底）时为 nil。
    let storeProduct: IAPStoreProduct?

    init(
        id: String,
        title: String,
        discountText: String?,
        feature: IAPFeature,
        priceText: String,
        originalPriceText: String?,
        priceNote: String?,
        storeProduct: IAPStoreProduct? = nil
    ) {
        self.id = id
        self.title = title
        self.discountText = discountText
        self.feature = feature
        self.priceText = priceText
        self.originalPriceText = originalPriceText
        self.priceNote = priceNote
        self.storeProduct = storeProduct
    }
}

// MARK: - Store 商品转换

extension IAPPaywallProduct {

    /// 由 `IAPStoreProduct`（App Store 返回的商品）转换为付费页展示模型。
    ///
    /// 价格、名称等文案均取自 App Store 的本地化结果；折扣/原价因 StoreKit
    /// 不提供参考价而留空（不展示）。
    init(storeProduct: IAPStoreProduct) {
        self.init(
            id: storeProduct.id,
            title: Self.title(for: storeProduct),
            discountText: nil,
            feature: Self.feature(for: storeProduct),
            priceText: Self.priceText(for: storeProduct),
            originalPriceText: nil,
            priceNote: Self.priceNote(for: storeProduct),
            storeProduct: storeProduct
        )
    }

    /// 批量转换
    static func convert(_ storeProducts: [IAPStoreProduct]) -> [IAPPaywallProduct] {
        storeProducts.map(IAPPaywallProduct.init(storeProduct:))
    }

    // MARK: - 字段映射
    private static func title(for product: IAPStoreProduct) -> String {
        return product.displayName
    }

    /// 卡片上展示的一行特性
    private static func feature(for product: IAPStoreProduct) -> IAPFeature {
        // 免费试用优先高亮展示
        if let trial = product.freeTrialText {
            return IAPFeature(text: trial, highlighted: true)
        }
        
        guard product.isSubscription else {
            return IAPFeature(text: product.description, highlighted: false)
        }

        return .empty
    }

    /// 价格文案："¥98/yr"（买断制不带周期后缀）
    private static func priceText(for product: IAPStoreProduct) -> String {
        guard let suffix = periodSuffix(for: product) else { return product.displayPrice }
        return product.displayPrice + suffix
    }

    /// 价格说明："Billed monthly" / "Billed yearly"；有免费试用或买断制时不展示
    private static func priceNote(for product: IAPStoreProduct) -> String? {
        guard product.isSubscription,
              !product.hasFreeTrial,
              let period = product.product.subscription?.subscriptionPeriod else {
            return nil
        }
        switch period.unit {
        case .day:   return resGetString("Billed daily")
        case .week:  return resGetString("Billed weekly")
        case .month: return resGetString("Billed monthly")
        case .year:  return resGetString("Billed yearly")
        @unknown default: return nil
        }
    }

    /// 价格周期后缀：" /yr" 之类
    private static func periodSuffix(for product: IAPStoreProduct) -> String? {
        guard let period = product.product.subscription?.subscriptionPeriod else { return nil }
        let value = period.value
        switch period.unit {
        case .day:
            return value == 1 ? resGetString("/day") : String(format: resGetString("/%dd"), value)
        case .week:
            return value == 1 ? resGetString("/wk") : String(format: resGetString("/%dw"), value)
        case .month:
            return value == 1 ? resGetString("/mo") : String(format: resGetString("/%dmo"), value)
        case .year:
            return value == 1 ? resGetString("/yr") : String(format: resGetString("/%dy"), value)
        @unknown default:
            return nil
        }
    }
}
