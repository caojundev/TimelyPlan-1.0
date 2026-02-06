//
//  StatsInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/5.
//

import Foundation

struct StatsSummary: Equatable {
    
    /// 唯一标识
    var identifier = UUID().uuidString
    
    /// 主标题
    var title: String?
    
    /// 数值标签
    var value: String? = "---"
    
    /// 富文本数值文本
    var attributedValue: ASAttributedString?
     
    /// 带下标的富文本标题
    static func attributedValue(text: String,
                                separator: String? = " ",
                                badge: String,
                                badgeBaselineOffset: CGFloat = 0.0,
                                badgeFont: UIFont = BOLD_SMALL_SYSTEM_FONT,
                                badgeColor: UIColor = .secondaryLabel) -> ASAttributedString {
        
        var title = text
        if let separator = separator {
            title += separator
        }
        
        var string: ASAttributedString = title.attributedString
        string = string.byAppend(badge: badge,
                                  baselineOffset: badgeBaselineOffset,
                                  font: badgeFont,
                                  color: badgeColor)
        return string
    }
    
}
