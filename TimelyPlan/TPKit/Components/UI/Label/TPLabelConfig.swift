//
//  TPLabelConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/9.
//

import Foundation
import UIKit

class TPLabelConfig: Equatable, NSCopying {
    
    /// 字体
    var font = BOLD_SYSTEM_FONT
    
    /// 显示行数
    var numberOfLines: Int = 1

    // 文本对齐方式
    var textAlignment: NSTextAlignment = .left
    
    // 文本的断行方式
    var lineBreakMode: NSLineBreakMode = .byTruncatingTail
    
    /// 自动调整字体大小
    var adjustsFontSizeToFitWidth: Bool = false
    
    /// 标签透明度
    var alpha: CGFloat = 1.0
    
    /// 文本颜色
    var textColor: UIColor? = resGetColor(.title) 

    /// 高亮颜色
    var highlightedTextColor: UIColor?
    
    /// 选中颜色
    var selectedTextColor: UIColor?
    
    // MARK: - 初始化方法
     required init() {
     }
     
    // MARK: - 静态构造方法
    static var titleConfig: TPLabelConfig {
        let config = TPLabelConfig()
        config.font = BOLD_SYSTEM_FONT
        config.textColor = resGetColor(.title)
        return config
    }
    
    static var subtitleConfig: TPLabelConfig {
        let config = TPLabelConfig()
        config.font = BOLD_SMALL_SYSTEM_FONT
        config.textColor = .secondaryLabel
        config.alpha = 0.8
        return config
    }

    /// 通过普通文本初始化配置
    static func withFont(_ font: UIFont = BOLD_SYSTEM_FONT,
                         numberOfLines: Int = 1,
                         textColor: UIColor = .label,
                         textAlignment: NSTextAlignment = .left,
                         lineBreakMode: NSLineBreakMode = .byTruncatingTail,
                         adjustsFontSizeToFitWidth: Bool = false) -> TPLabelConfig {
        let config = TPLabelConfig()
        config.textColor = textColor
        config.font = font
        config.numberOfLines = numberOfLines
        config.textAlignment = textAlignment
        config.lineBreakMode = lineBreakMode
        config.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        return config
    }

    // MARK: - 链式方法
    
    @discardableResult
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    func numberOfLines(_ lines: Int) -> Self {
        self.numberOfLines = lines
        return self
    }
    
    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    @discardableResult
    func highlightedTextColor(_ color: UIColor) -> Self {
        self.highlightedTextColor = color
        return self
    }
    
    @discardableResult
    func selectedTextColor(_ color: UIColor) -> Self {
        self.selectedTextColor = color
        return self
    }
    
    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    @discardableResult
    func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
        self.lineBreakMode = mode
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ enabled: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = enabled
        return self
    }
    
    @discardableResult
    func alpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = type(of: self).init()
        copy.font = font
        copy.numberOfLines = numberOfLines
        copy.textAlignment = textAlignment
        copy.lineBreakMode = lineBreakMode
        copy.adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth
        copy.alpha = alpha
        copy.textColor = textColor
        copy.highlightedTextColor = highlightedTextColor
        copy.selectedTextColor = selectedTextColor
        return copy
    }

    // MARK: - Equatable
    static func == (lhs: TPLabelConfig, rhs: TPLabelConfig) -> Bool {
       return lhs.font == rhs.font &&
              lhs.numberOfLines == rhs.numberOfLines &&
              lhs.textAlignment == rhs.textAlignment &&
              lhs.lineBreakMode == rhs.lineBreakMode &&
              lhs.adjustsFontSizeToFitWidth == rhs.adjustsFontSizeToFitWidth &&
              lhs.alpha == rhs.alpha &&
              lhs.textColor == rhs.textColor &&
              lhs.selectedTextColor == rhs.selectedTextColor &&
              lhs.highlightedTextColor == rhs.highlightedTextColor
    }
    
}
