//
//  TimelineItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation

// MARK: - 数据模型

enum TimeLineNodeStyle {
    case independent
    case connectToPrevious
    case connectToNext
    case connectToBoth
}

enum TimelineItemPosition {
    case first      // 第一个节点
    case middle     // 中间节点
    case last       // 最后一个节点
    case only       // 唯一节点（只有一个事件时）
}

enum TimelineItemType: Equatable {
    case point
    case short
    case long
}

enum TimelineConnectionStyle {
    case solid
    case dashed
    case overlapping
}

struct TimelineConnectionItem {
    let id = UUID()
    let style: TimelineConnectionStyle
    let height: CGFloat
    let topDate: Date /// 顶部日期
    let bottomDate: Date /// 底部日期
    let topColor: UIColor
    let bottomColor: UIColor
    
    var timeInterval: TimeInterval {
        return bottomDate.timeIntervalSince(topDate)
    }
}

struct TimelineItem {
    let id = UUID()
    let event: MyDayEvent
    let type: TimelineItemType
    let position: TimelineItemPosition
    let nodeStyle: TimeLineNodeStyle
    
    var nodeColor: UIColor {
        return event.color
    }
    
    var startDate: Date {
        return event.startDate
    }
    
    var endDate: Date {
        return event.endDate
    }
}

enum TimelineDataItem {
    case event(TimelineItem)
    case connection(TimelineConnectionItem)
}
