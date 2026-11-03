//
//  WSMyDayTimelineDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation

// MARK: - 事项条目

/// 时间线事项行的数据条目，用于点击回调
struct WSMyDayTimelineEventItem: WSPluginDataItem {
    
    /// 事项标识
    let identifier: String
    
    /// 原始事项
    let event: MyDayEvent
    
    init(event: MyDayEvent) {
        self.identifier = event.identifier
        self.event = event
    }
}

// MARK: - 组件数据

/// 我的一天·时间线的组件数据。
///
/// 保存今天的全部事项，时间线视图内部再过滤出正在进行与将要发生的事项；
/// 事项行与连接线由 `TimelineTimedEventConverter` 转换为与时间线一致的布局。
class WSMyDayTimelineDataItem: NSObject, WSPluginDataItem {
    
    /// 日期
    let date: Date
    
    /// 今天的全部事项，按开始时间排序
    let events: [MyDayEvent]
    
    init(date: Date, events: [MyDayEvent]) {
        self.date = date
        self.events = events
        super.init()
    }
}
