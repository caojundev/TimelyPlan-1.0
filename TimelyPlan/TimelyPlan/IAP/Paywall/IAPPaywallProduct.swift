//
//  IAPPaywallProduct.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import StoreKit

/// 内购商品完整配置
struct IAPPaywallProduct {
    let id: String
    let title: String               // "Yearly" / "Monthly" / "Lifetime"
    let discountText: String?       // "Save 23%", nil 则不显示
    let priceText: String           // "¥98/yr"
    let originalPriceText: String?  // "Original ¥128/yr", nil 则不显示
    /// 副标题（商品描述）
    let subtitle: String?

    /// 转换来源：由 `IAPStoreProduct` 转换而来时保留原商品，购买时直接使用；
    /// 手工构造（预览 / 兜底）时为 nil。
    let storeProduct: IAPStoreProduct?

    init(
        id: String,
        title: String,
        discountText: String?,
        priceText: String,
        originalPriceText: String?,
        subtitle: String?,
        storeProduct: IAPStoreProduct? = nil
    ) {
        self.id = id
        self.title = title
        self.discountText = discountText
        self.priceText = priceText
        self.originalPriceText = originalPriceText
        self.subtitle = subtitle
        self.storeProduct = storeProduct
    }
}

// MARK: - Store 商品转换

extension IAPPaywallProduct {

    /// 由 `IAPStoreProduct`（App Store 返回的商品）转换为付费页展示模型。
    ///
    /// 价格、名称、描述等文案均取自 App Store 的本地化结果；原价因 StoreKit
    /// 不提供参考价而留空（不展示）。
    init(storeProduct: IAPStoreProduct, discountText: String? = nil) {
        self.init(
            id: storeProduct.id,
            title: Self.title(for: storeProduct),
            discountText: discountText,
            priceText: Self.priceText(for: storeProduct),
            originalPriceText: nil,
            subtitle: Self.subtitle(for: storeProduct),
            storeProduct: storeProduct
        )
    }

    /// 批量转换（同时计算年订阅相对月订阅的折扣）
    static func convert(_ storeProducts: [IAPStoreProduct]) -> [IAPPaywallProduct] {
        let monthly = storeProducts.first { $0.id == AppConfig.IAP.monthly }
        return storeProducts.map { storeProduct in
            IAPPaywallProduct(
                storeProduct: storeProduct,
                discountText: discountText(for: storeProduct, monthly: monthly)
            )
        }
    }

    // MARK: - 折扣

    /// 折扣/营销标签文案。
    ///
    /// - 年订阅：月订阅价格 × 12 作为一年原价，与年订阅价格比较，
    ///   节省比例 = (原价 - 年价) / 原价，四舍五入到整数百分比（如 "Save 60%"）
    /// - 永久买断：固定展示 "Best Value"
    private static func discountText(for product: IAPStoreProduct,
                                     monthly: IAPStoreProduct?) -> String? {
        // 买断制：最划算
        if product.id == AppConfig.IAP.lifetime {
            return resGetString("Best Value")
        }

        guard product.id == AppConfig.IAP.yearly,
              let monthly = monthly else {
            return nil
        }

        let fullYearPrice = monthly.product.price * 12
        let yearlyPrice = product.product.price

        // 无月价参考、或年价并未更便宜时不展示折扣
        guard fullYearPrice > 0, yearlyPrice < fullYearPrice else { return nil }

        // 取整百分比（四舍五入）
        let savedRatio = (fullYearPrice - yearlyPrice) / fullYearPrice
        let percent = NSDecimalNumber(decimal: roundToInt(savedRatio * 100)).intValue
        return String(format: resGetString("Save %d%%"), percent)
    }

    /// 四舍五入到整数
    private static func roundToInt(_ value: Decimal) -> Decimal {
        var result = Decimal()
        var input = value
        NSDecimalRound(&result, &input, 0, .plain)
        return result
    }

    // MARK: - 字段映射

    private static func title(for product: IAPStoreProduct) -> String {
        return product.displayName
    }

    /// 副标题：商品描述（App Store 本地化文案）
    private static func subtitle(for product: IAPStoreProduct) -> String? {
        let text = product.description.trimmingCharacters(in: .whitespacesAndNewlines)
        return text.isEmpty ? nil : text
    }

    /// 价格文案："¥98/yr"（买断制不带周期后缀）
    private static func priceText(for product: IAPStoreProduct) -> String {
        let price = displayPrice(for: product)
        guard let suffix = periodSuffix(for: product) else { return price }
        return price + suffix
    }

    /// 本地化价格文案：小数部分全为 0 时省略小数位（"¥98.00" → "¥98"），
    /// 否则保持 StoreKit 原样（"¥9.99"）。
    ///
    /// 直接裁剪 `displayPrice`，货币符号、位置、千分位等本地化格式完全保留。
    private static func displayPrice(for product: IAPStoreProduct) -> String {
        let text = product.displayPrice
        // 只有整数价格才需要去掉小数位
        guard isWholeNumber(product.product.price) else { return text }

        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        guard let separator = formatter.decimalSeparator,
              let range = text.range(of: separator, options: .backwards) else {
            return text
        }

        // 小数分隔符之后应为一串 0（其后可跟货币符号、空格等非数字内容）
        let fraction = text[range.upperBound...]
        let zeroCount = fraction.prefix { $0 == "0" }.count
        guard zeroCount > 0 else { return text }

        let rest = fraction.dropFirst(zeroCount)
        guard rest.allSatisfy({ !$0.isNumber }) else { return text }

        return String(text[..<range.lowerBound]) + rest
    }
    
    /// 判断价格是否没有小数部分
    private static func isWholeNumber(_ value: Decimal) -> Bool {
        roundToInt(value) == value
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

    /// 价格说明：订阅返回计费周期（"Billed monthly"），买断返回 "One-time Purchase"
    static func priceNote(for product: IAPStoreProduct) -> String? {
        guard product.isSubscription else {
            return resGetString("One-time Purchase")
        }
        
        guard let period = product.product.subscription?.subscriptionPeriod else {
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
}
