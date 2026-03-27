//
//  SearchHighlightable.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/27.
//

import Foundation

protocol SearchHighlightable {
    
    /// 高亮文本
    var highlightedText: String? { get set}
    
    /// 获取默认的正常文本属性
    var normalAttributes: [NSAttributedString.Key: Any] { get }
    
    /// 获取默认的高亮文本属性（黄色背景，黑色文字）
    var highlightAttributes: [NSAttributedString.Key: Any] { get }
    
    /// 设置搜索文本并更新高亮显示
    func setHighlightedText(_ highlightedText: String?)
}

extension SearchHighlightable {
    
    /// 获取默认的正常文本属性
    var normalAttributes: [NSAttributedString.Key: Any] {
        return [
            .foregroundColor: resGetColor(.title),
            .font: BOLD_BODY_FONT
        ]
    }
    
    /// 获取默认的高亮文本属性（黄色背景，黑色文字）
    var highlightAttributes: [NSAttributedString.Key: Any] {
        return [
            .backgroundColor: Color(0xFFD60A),
            .foregroundColor: UIColor.black,
            .font: BOLD_SYSTEM_FONT
        ]
    }
}
