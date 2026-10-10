//
//  IAPPaywallProduct.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation

/// 商品特性信息
struct IAPFeature {
    let text: String
    let highlighted: Bool  // true = 蓝色高亮, false = 灰色
}

/// 内购商品完整配置
struct IAPPaywallProduct {
    let id: String
    let title: String               // "Annual" / "Monthly" / "Lifetime"
    let discountText: String?       // "23% OFF", nil 则不显示
    let feature: IAPFeature         // 卡片上展示的一行特性
    let priceText: String           // "¥98/yr"
    let originalPriceText: String?  // "Original ¥128/yr", nil 则不显示
    let priceNote: String?          // "Billed monthly", nil 则不显示
}
