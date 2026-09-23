//
//  CountdownCalculator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/23.
//

import Foundation

/// 倒数日计算器
class CountdownCalculator {
    
    /// 以参照日期所在日为基准计算到目标日期所在日的天数：正数为剩余天数，负数为已经过去的天数。
    static func days(referenceDate: Date,
                     targetDate: Date,
                     countingType: CountdownEvent.CountingType,
                     includeStartDate: Bool) -> Int {
        let days = abs(Date.days(fromDate: referenceDate, toDate: targetDate))
        guard countingType == .countUp, includeStartDate else {
            return days
        }
        
        return days + 1
    }
}
