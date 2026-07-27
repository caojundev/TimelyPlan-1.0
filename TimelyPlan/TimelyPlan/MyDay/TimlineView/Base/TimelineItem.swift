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
    let topColor: UIColor
    let bottomColor: UIColor
    let height: CGFloat
    let timeInterval: TimeInterval?
}

struct TimelineItem {
    let id = UUID()
    let timeStart: String
    let timeEnd: String?
    let title: String
    let type: TimelineItemType
    let position: TimelineItemPosition 
    let isCompleted: Bool
    let durationText: String?
    let nodeColor: UIColor
    let nodeStyle: TimeLineNodeStyle
    let event: MyDayEvent?
    
    let startDate: Date
    let endDate: Date
}

enum TimelineDataItem {
    case event(TimelineItem)
    case connection(TimelineConnectionItem)
}
