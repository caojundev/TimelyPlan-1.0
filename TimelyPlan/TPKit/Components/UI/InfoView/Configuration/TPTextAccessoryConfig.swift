//
//  TPTextAccessoryConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/8.
//

import Foundation
import UIKit

class TPTextAccessoryConfig {
    
    /// 值文本
    var valueText: String?

    /// 值标签字体
    var valueFont: UIFont = .boldSystemFont(ofSize: 12.0)

    /// 数值间距
    var valueMargins = UIEdgeInsets(left: 5.0)
    
    /// 最小值宽度
    var minimumValueWidth: CGFloat = 0.0
    
    /// 最大值宽度
    var maximumValueWidth: CGFloat = 160.0
    
    var textColor: UIColor? = .secondaryLabel
    
    /// 获取值文本尺寸
    var valueSize: CGSize {
        var valueWidth = valueText?.width(with: valueFont) ?? 0.0
        valueWidth = min(max(minimumValueWidth, ceil(valueWidth)),  maximumValueWidth)
        let valueHeight = valueFont.lineHeight
        return CGSize(width: valueWidth, height: valueHeight)
    }
    
    static func valueText(_ text: String?, textColor: UIColor? = nil) -> TPTextAccessoryConfig {
        let config = TPTextAccessoryConfig()
        config.valueText = text
        config.textColor = textColor ?? .secondaryLabel
        return config
    }
}
