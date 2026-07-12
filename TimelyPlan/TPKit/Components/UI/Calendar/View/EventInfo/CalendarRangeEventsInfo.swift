//
//  CalendarRangeEventsInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/9.
//

import Foundation
import UIKit

typealias DailyEventColors = [DateComponents: [UIColor]]

struct CalendarRangeEventsInfo {
    
    let range: DateInterval
    
    var dayColors: DailyEventColors // 所有天的事项信息
    
    func eventColors(for dateComponents: DateComponents) -> [UIColor]? {
        return dayColors[dateComponents]
    }
    
    static func empty(with range: DateInterval) -> CalendarRangeEventsInfo {
        return CalendarRangeEventsInfo(range: range, dayColors: [:])
    }
}

struct CalendarEventColorMapper {
    
    static func mapColorsByDay(
        events: [CalendarEvent],
        range: DateInterval
    ) -> DailyEventColors {
        let calendar = Calendar.current
        // 使用有序字典保持颜色插入顺序
        var dayColorsMap: [DateComponents: OrderedSet<UIColor>] = [:]
        for event in events {
            let eventStart = max(event.startDate, range.start)
            let eventEnd = min(event.endDate, range.end)
            guard eventStart <= eventEnd else { continue }
        
            let eventRange = DateInterval(start: eventStart, end: eventEnd)
            eventRange.enumerateDays { date in
                let key = calendar.dateComponents([.year, .month, .day], from: date)
                dayColorsMap[key, default: OrderedSet<UIColor>()].append(event.color)
                return true
            }
        }
    
        return dayColorsMap.mapValues { $0.array }
    }
}

// MARK: - 事项数据获取协议
protocol CalendarRangeEventsProvider: AnyObject {
    /// 异步获取指定日期范围的事项绘制信息
    /// - Returns: 可用于取消请求的标识，如果为nil表示不支持取消
    func fetchRangeEventsInfo(in range: DateInterval, completion: @escaping (CalendarRangeEventsInfo) -> Void)
    
    /// 取消指定范围的请求（可选实现）
    func cancelFetchForRange(_ range: DateInterval)
    
    /// 添加事项变化代理对象
    func addEventChangeDelegate(_ delegate: CalendarEventChangeDelegate)
}

// 默认实现，取消方法可选
extension CalendarRangeEventsProvider {
    func cancelFetchForRange(_ range: DateInterval) { }
}
