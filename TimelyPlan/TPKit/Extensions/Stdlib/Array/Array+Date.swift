//
//  Array+Date.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/1.
//

import Foundation

extension Array where Element == Date {

    /// 过滤未来日期
    var futureDates: [Date] {
        let now = Date.now
        let dates = self.filter { date in
            return date > now
        }
        
        return dates
    }
    
    /// 列表是否包含某一天的日期
    func containsDay(_ date: Date) -> Bool {
        var bContain = false
        for aDate in self {
            if aDate.isInSameDayAs(date) {
                bContain = true
                break
            }
        }
        
        return bContain
    }
}
