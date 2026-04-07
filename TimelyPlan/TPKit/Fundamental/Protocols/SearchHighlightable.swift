//
//  SearchHighlightable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation
import UIKit

protocol SearchHighlightable: AnyObject {
    
    /// 高亮文本
    var highlightedText: String? { get set}
    
    /// 获取默认的正常文本属性
    var normalAttributes: [NSAttributedString.Key: Any] { get }
    
    var searchNormalFont: UIFont { get }
    
    var searchNormalTextColor: UIColor { get }
    
    
    /// 获取默认的高亮文本属性（黄色背景，黑色文字）
    var highlightAttributes: [NSAttributedString.Key: Any] { get }
    
    var searchHighlightFont: UIFont { get }
    
    var searchHighlightColorAttributes: [NSAttributedString.Key: Any] { get }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?)
}

extension SearchHighlightable {
    
    /// 获取默认的正常文本属性
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: searchNormalTextColor,
            .font: searchHighlightFont
        ]
    }
    
    var searchNormalFont: UIFont {
        return BOLD_SYSTEM_FONT
    }
    
    var searchNormalTextColor: UIColor {
        return resGetColor(.title)
    }
    
    /// 获取默认的高亮文本属性（黄色背景，黑色文字）
    var highlightAttributes: [NSAttributedString.Key: Any] {
        var attributes = searchHighlightColorAttributes
        attributes[.font] = searchHighlightFont
        return attributes
    }
    
    var searchHighlightFont: UIFont {
        return searchNormalFont
    }
    
    /// 高亮颜色属性
    var searchHighlightColorAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black
        ]
    }
}
