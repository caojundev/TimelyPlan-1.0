//
//  WSFocusWeekActivityDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation

// MARK: - 数据条目

/// 专注·小·本周活动的数据条目。
///
/// 只保留渲染所需的数据，内容视图不依赖会话模型，画廊预览也无需构造真实会话。
class WSFocusWeekActivityDataItem: NSObject, WSPluginDataItem {
    
    /// 本周第一天
    let startDate: Date
    
    /// 本周最后一天
    let endDate: Date
    
    /// 本周专注总时长
    let duration: Duration
    
    /// 本周专注次数
    let times: Int
    
    /// 每天的活动进度，取值为 0~1，按展示顺序排列
    let dailyActivity: [Float]
    
    init(startDate: Date,
         endDate: Date,
         duration: Duration,
         times: Int,
         dailyActivity: [Float]) {
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.times = times
        self.dailyActivity = dailyActivity
        super.init()
    }
    
    /// 由一周的会话生成展示数据
    convenience init(dateRange: DateRange, sessions: [FocusSession]) {
        let startDate = dateRange.startDate ?? Date().firstDayOfWeek()
        let endDate = startDate.dateByAddingDays(DAYS_PER_WEEK - 1) ?? startDate
        
        var durations = [Duration](repeating: 0, count: DAYS_PER_WEEK)
        var times = 0
        for session in sessions {
            guard let sessionDate = session.startDate else {
                continue
            }
            
            let offset = startDate.daysBetween(sessionDate)
            guard offset >= 0 && offset < DAYS_PER_WEEK else {
                continue
            }
            
            durations[offset] += Duration(session.duration)
            times += 1
        }
        
        /// 柱条高度按本周最长的一天归一化
        let maxDuration = durations.max() ?? 0
        let dailyActivity = durations.map { duration -> Float in
            guard maxDuration > 0 else {
                return 0.0
            }
            
            return Float(duration) / Float(maxDuration)
        }
        
        self.init(startDate: startDate,
                  endDate: endDate,
                  duration: durations.reduce(0, +),
                  times: times,
                  dailyActivity: dailyActivity)
    }
}
