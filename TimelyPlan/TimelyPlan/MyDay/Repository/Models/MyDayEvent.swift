//
//  MyDayEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/16.
//

import Foundation

// 我的一天事件来源
enum MyDayEventSource: Int, CaseIterable {
    case todo   // 待办任务
    case habit  // 习惯任务
    case focus  // 专注计时器
}

class MyDayEvent: NSObject {
    let identifier: String
    let source: MyDayEventSource
    let title: String?
    let color: UIColor
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let isCompleted: Bool
    
    // 原始数据条目的引用
    let sourceItem: Any
    
    init(identifier: String,
         source: MyDayEventSource,
         name: String?,
         color: UIColor,
         startDate: Date,
         endDate: Date,
         isAllDay: Bool,
         isCompleted: Bool,
         sourceItem: Any) {
        self.identifier = identifier
        self.source = source
        self.title = name
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.sourceItem = sourceItem
        self.isCompleted = isCompleted
    }
    
    /// 日期范围
    var dateRange: DateInterval {
        return DateInterval(start: startDate, end: endDate)
    }
    
}

extension Array where Element == MyDayEvent {
    
    var allDayEvents: [MyDayEvent] {
        return filter { $0.isAllDay }
    }
    
    var timedEvents: [MyDayEvent] {
        return filter { !$0.isAllDay }
    }
    
    /// 获取排序后的我的一天事项数组
    var orderedEvents: [MyDayEvent] {
        return sorted { lEvent, rEvent in
            // 1. 全天任务放在上方
            if lEvent.isAllDay != rEvent.isAllDay {
                return lEvent.isAllDay && !rEvent.isAllDay
            }
            
            // 2. 开始日期早的在上方
            if lEvent.startDate != rEvent.startDate {
                return lEvent.startDate < rEvent.startDate
            }
            
            // 3. 持续时间长的在上方
            let lDuration = lEvent.endDate.timeIntervalSince(lEvent.startDate)
            let rDuration = rEvent.endDate.timeIntervalSince(rEvent.startDate)
            if lDuration != rDuration {
                return lDuration > rDuration
            }
            
            // 4. 按 source 排序
            if lEvent.source != rEvent.source {
                return lEvent.source.rawValue < rEvent.source.rawValue
            }
            
            // 所有条件都相同时保持原有顺序
            return false
        }
    }
    
}
