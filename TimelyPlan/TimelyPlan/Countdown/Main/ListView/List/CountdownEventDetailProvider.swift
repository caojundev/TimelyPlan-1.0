//
//  CountdownEventDetailProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/17.
//

import Foundation

class CountdownEventDetailProvider {
    
    /// 副标题组件：目标日期 + 剩余天数
    static func subtitleComponents(for event: CountdownEvent) -> [ASAttributedString] {
        var components = [ASAttributedString]()
        /// 日期字符串
        let dateString = event.occuranceDate.displayText
        components.append(dateString.attributedString)
        return components
    }
    
    /// 副标题
    static func detail(for event: CountdownEvent) -> ASAttributedString {
        return subtitleComponents(for: event).joined(separator: " • ")
    }
}
