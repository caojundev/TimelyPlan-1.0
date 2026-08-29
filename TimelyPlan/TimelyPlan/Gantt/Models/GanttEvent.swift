//
//  GanttEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation

// 甘特图事件来源
enum GanttEventSource: Int, CaseIterable {
    case todo /// 待办
    case goal /// 目标
}

// MARK: - 数据模型
struct GanttEvent {
    let id: String
    let name: String
    let startDate: Date
    let endDate: Date
    let progress: CGFloat
    let color: UIColor
    let source: GanttEventSource
    let sourceItem: Any
    
    var title: String {
        var components = [name]
        let progressString = Float(progress).percentageString(decimalPlaces: 1)
        components.append(progressString)
        return components.joined(separator: " • ")
    }
}

extension Array where Element == GanttEvent {
    
    var orderedEvents: [GanttEvent] {
        return sorted { lEvent, rEvent in
            // 1. 开始日期早的在上方
            if lEvent.startDate != rEvent.startDate {
                return lEvent.startDate < rEvent.startDate
            }
            
            // 2. 持续时间短的在上方
            let lDuration = lEvent.endDate.timeIntervalSince(lEvent.startDate)
            let rDuration = rEvent.endDate.timeIntervalSince(rEvent.startDate)
            if lDuration != rDuration {
                return lDuration < rDuration
            }
            
            // 3. 按 source 排序
            if lEvent.source != rEvent.source {
                return lEvent.source.rawValue < rEvent.source.rawValue
            }
            
            return lEvent.id.compare(rEvent.id) == .orderedAscending
        }
    }
    
}
