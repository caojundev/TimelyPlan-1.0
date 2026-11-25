//
//  WSFocusMonthHeatMapDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation

// MARK: - 数据条目

/// 专注·小·本月热力图的数据条目。
///
/// 只保留渲染所需的数据，内容视图不依赖会话模型，画廊预览也无需构造真实会话。
class WSFocusMonthHeatMapDataItem: NSObject, WSPluginDataItem {
    
    /// 本月任意一天
    let date: Date
    
    /// 本月专注总时长
    let duration: Duration
    
    /// 每日热力等级，key 为日
    let dayLevels: [Int: Int]
    
    init(date: Date, duration: Duration, dayLevels: [Int: Int]) {
        self.date = date
        self.duration = duration
        self.dayLevels = dayLevels
        super.init()
    }
    
    /// 由本月的会话生成展示数据
    convenience init(date: Date, sessions: [FocusSession]) {
        let statsItem = FocusStatsDataItem(task: nil,
                                           timer: nil,
                                           dateRange: date.rangeOfThisMonth(),
                                           sessions: sessions)
        
        var dayLevels = [Int: Int]()
        for (key, duration) in statsItem.dayDurations ?? [:] {
            guard let dayDate = Date.dateFromDayStringKey(key) else {
                continue
            }
            
            dayLevels[dayDate.day] = WSFocusMonthHeatMapDataItem.levelIndex(of: duration)
        }
        
        self.init(date: date,
                  duration: statsItem.duration ?? 0,
                  dayLevels: dayLevels)
    }
    
    /// 时长对应的热力等级，与年度统计的分级保持一致
    static func levelIndex(of duration: Duration) -> Int {
        if duration > 3 * SECONDS_PER_HOUR {
            return 4
        } else if duration > 2 * SECONDS_PER_HOUR {
            return 3
        } else if duration > SECONDS_PER_HOUR {
            return 2
        } else if duration > 0 {
            return 1
        } else {
            return 0
        }
    }
}
