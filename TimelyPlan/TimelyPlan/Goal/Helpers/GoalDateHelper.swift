//
//  GoalDateHelper.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

struct GoalDateHelper {
    
    private static let intervalFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    /// 目标日期区间描述
    /// - Parameters:
    ///   - startDate: 开始日期
    ///   - endDate: 结束日期
    /// - Returns: 日期区间字符串；无日期时返回 nil
    static func intervalDescription(startDate: Date?, endDate: Date?) -> String? {
        let start = startDate ?? endDate
        let end = endDate ?? startDate
        
        guard let start = start, let end = end else {
            return nil
        }
        
        let startString = intervalFormatter.string(from: start)
        let endString = intervalFormatter.string(from: end)
        
        if startString == endString {
            return startString
        }
        
        return startString + " - " + endString
    }
}
