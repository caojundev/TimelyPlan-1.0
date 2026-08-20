//
//  IAPProduct.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation

/// 特性项图标类型
enum IAPFeatureIcon {
    case checkmark        // ✓ 对勾
    case family           // 👥 家庭共享
    case custom(UIImage)  // 自定义图片
    case none             // 无图标
}

/// 单条商品特性
struct IAPFeature {
    let icon: IAPFeatureIcon
    let text: String
    let highlighted: Bool  // true = 蓝色高亮, false = 灰色
}

/// 内购商品完整配置
struct IAPProduct {
    let id: String
    let title: String               // "Annual" / "Monthly" / "Lifetime"
    let discountText: String?       // "23% OFF", nil 则不显示
    let features: [IAPFeature]      // 特性列表
    let priceText: String           // "¥98/yr"
    let originalPriceText: String?  // "Original ¥128/yr", nil 则不显示
    let priceNote: String?          // "Billed monthly", nil 则不显示
}
