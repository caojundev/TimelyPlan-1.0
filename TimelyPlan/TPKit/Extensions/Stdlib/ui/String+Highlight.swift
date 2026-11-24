//
//  String+Highlight.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/24.
//

import Foundation
import UIKit

extension String {
    
    /// 创建带有高亮效果的 NSAttributedString
    /// - Parameters:
    ///   - highlightText: 需要高亮的文本
    ///   - normalAttributes: 正常文本属性
    ///   - highlightAttributes: 高亮文本属性
    /// - Returns: 带有高亮效果的 NSAttributedString
    func attributedStringWithHighlight(
        _ highlightText: String?,
        normalAttributes: [NSAttributedString.Key: Any] = [:],
        highlightAttributes: [NSAttributedString.Key: Any] = [:]
    ) -> NSAttributedString {
        guard let highlightText = highlightText?.trimmingCharacters(in: .whitespacesAndNewlines),
              !highlightText.isEmpty,
              !self.isEmpty else {
            return NSAttributedString(string: self, attributes: normalAttributes)
        }
        
        let attributedString = NSMutableAttributedString(string: self, attributes: normalAttributes)
        let searchString = self.lowercased()
        let searchText = highlightText.lowercased()
        
        var searchRange = NSString(string: searchString).range(of: searchText)
        while searchRange.location != NSNotFound {
            // 计算原始字符串中的实际范围
            let originalRange = NSRange(location: searchRange.location, length: searchText.count)
            
            // 应用高亮属性
            attributedString.addAttributes(highlightAttributes, range: originalRange)
            
            // 继续搜索下一个匹配项
            let nextSearchLocation = searchRange.location + searchRange.length
            let remainingString = NSString(string: searchString).substring(from: nextSearchLocation)
            let remainingRange = NSString(string: remainingString).range(of: searchText)
            
            if remainingRange.location != NSNotFound {
                searchRange = NSRange(location: nextSearchLocation + remainingRange.location, length: remainingRange.length)
            } else {
                searchRange.location = NSNotFound
            }
        }
        
        return attributedString
    }
}
