//
//  CalendarEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/23.
//

import Foundation
import UIKit

class CalendarEventColor {
    
    ///日历事件颜色
    static let colors = [Color(0x999DA8),
                         Color(0x34B729),
                         Color(0x4286F5),
                         Color(0xC274FF),
                         Color(0x7E64FD),
                         Color(0x01CFD4),
                         Color(0x00CF85),
                         Color(0xD40102),
                         Color(0xF3501D),
                         Color(0xFE887C),
                         Color(0xF6BF25)]
    
    /// 默认颜色
    static let defaultColor: UIColor = colors[3]
    
    /// 随机事件颜色
    static var random: UIColor {
        let index = Int(arc4random()) % colors.count
        return colors[index]
    }
    
    /// 获取事件颜色对应的背景色
    static func backgroundColor(for eventColor: UIColor) -> UIColor {
        return eventColor.withAlphaComponent(0.25)
    }
    
    static func foregroundColor(for eventColor: UIColor) -> UIColor {
        let lightColor = eventColor.withBrightness(0.3)
        let darkColor = eventColor.withSaturation(0.3)
        return UIColor(.dm, light: lightColor, dark: darkColor)
    }
    
    static func highlightedForegroundColor(for eventColor: UIColor) -> UIColor {
        return .white
    }
}

// 1. 枚举区分事件来源
enum CalendarEventSource {
    case local      // 用户自定义任务
    case system     // 系统日历
}

class CalendarEvent: NSObject {
    let identifier: String
    let source: CalendarEventSource
    let title: String?
    let startDate: Date
    let endDate: Date
    let isAllDay: Bool
    let color: UIColor
    var notes: String?

    // 原始数据条目的引用
    let sourceItem: Any
    
    init(identifier: String,
         source: CalendarEventSource,
         name: String?,
         color: UIColor,
         startDate: Date,
         endDate: Date,
         isAllDay: Bool,
         sourceItem: Any) {
        self.identifier = identifier
        self.source = source
        self.title = name
        self.color = color
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
        self.sourceItem = sourceItem
    }
    
    /// 日期范围
    var dateRange: DateInterval {
        return DateInterval(start: startDate, end: endDate)
    }
    
    /// 是否横跨多天
    var spansMultipleDays: Bool {
        let count = Date.days(fromDate: startDate, toDate: endDate)
        if count == 0 {
            return false
        }
        
        return true
    }
    
    /// 横跨天数
    var spanDays: Int {
        let count = Date.days(fromDate: startDate, toDate: endDate)
        return count + 1
    }
    
    /// 获取特定日期在某个时间范围内横跨的第几天
    func getDayIndex(targetDate: Date) -> Int {
        let index = Date.days(fromDate: startDate, toDate: targetDate)
        return index
    }

}

extension Array where Element == CalendarEvent {
    
    var allDayEvents: [CalendarEvent] {
        return self.filter { $0.isAllDay }
    }
    
    var timedEvents: [CalendarEvent] {
        return self.filter { !$0.isAllDay }
    }
    
    /// 获取排序后的日历事项数组
    var orderedEvents: [CalendarEvent] {
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
            
            // 4. source 为 system 的在上方
            if lEvent.source != rEvent.source {
                return lEvent.source == .system
            }
            
            // 所有条件都相同时保持原有顺序
            return false
        }
    }
    
}
