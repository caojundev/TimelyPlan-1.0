//
//  WSFocusTodayActivityDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation

// MARK: - 数据条目

/// 专注·小·今日活动的数据条目。
///
/// 只保留渲染所需的数据，内容视图不依赖会话模型，画廊预览也无需构造真实会话。
class WSFocusTodayActivityDataItem: NSObject, WSPluginDataItem {
    
    /// 统计日期
    let date: Date
    
    /// 当日专注总时长
    let duration: Duration
    
    /// 当日专注次数
    let times: Int
    
    /// 每小时活动进度，取值为 0~1
    let hourlyActivity: [Int: Float]
    
    init(date: Date, duration: Duration, times: Int, hourlyActivity: [Int: Float]) {
        self.date = date
        self.duration = duration
        self.times = times
        self.hourlyActivity = hourlyActivity
        super.init()
    }
    
    /// 由日专注统计信息生成展示数据
    convenience init(dayInfo: FocusStatsDayInfo) {
        self.init(date: dayInfo.date,
                  duration: dayInfo.duration,
                  times: dayInfo.sessions.count,
                  hourlyActivity: dayInfo.hourlyActivity)
    }
}
