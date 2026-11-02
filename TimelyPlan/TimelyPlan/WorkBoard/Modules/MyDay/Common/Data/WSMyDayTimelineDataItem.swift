//
//  WSMyDayTimelineDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation

// MARK: - 组件数据

/// 我的一天·时间线的组件数据。
///
/// 保留当前时间正在进行与尚未结束的事项，事项行与连接线由内容视图内的
/// 时间线视图按 `TimelineTimedEventConverter` 转换为与时间线一致的布局。
class WSMyDayTimelineDataItem: NSObject, WSPluginDataItem {
    
    /// 日期
    let date: Date
    
    /// 待展示的事项，按开始时间排序
    let events: [MyDayEvent]
    
    init(date: Date, events: [MyDayEvent]) {
        self.date = date
        self.events = events
        super.init()
    }
}
