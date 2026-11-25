//
//  WSFocusTodayComparisonDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation

// MARK: - 数据条目

/// 专注·小·今日对比的数据条目。
class WSFocusTodayComparisonDataItem: NSObject, WSPluginDataItem {
    
    /// 今日专注时长
    let today: Duration
    
    /// 昨日专注时长
    let yesterday: Duration
    
    /// 相比昨日的变化，正数为增加，负数为减少
    var delta: Duration {
        return today - yesterday
    }
    
    init(today: Duration, yesterday: Duration) {
        self.today = today
        self.yesterday = yesterday
        super.init()
    }
}
