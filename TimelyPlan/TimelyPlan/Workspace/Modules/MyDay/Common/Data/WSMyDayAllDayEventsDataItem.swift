//
//  WSMyDayAllDayEventsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 事项数据

/// 单个全天事项的展示数据。作为点击回调的数据条目传给交互器
struct WSMyDayAllDayEventItem: WSPluginDataItem {
    
    /// 事项标识
    let identifier: String
    
    /// 事项名称
    let title: String?
    
    /// 事项颜色，与时间线节点颜色一致
    let color: UIColor
    
    /// 是否已完成
    let isCompleted: Bool
    
    /// 事项类型图标，与时间线节点图标一致
    let sourceIcon: TPIcon?
    
    /// 原始事项，点击时据此打开详情
    let event: MyDayEvent
    
    init(event: MyDayEvent) {
        self.identifier = event.identifier
        self.title = event.title
        self.color = event.color
        self.isCompleted = event.isCompleted
        self.sourceIcon = event.sourceIcon
        self.event = event
    }
}

// MARK: - 组件数据

/// 我的一天·全天事项的组件数据。
///
/// 展示条数由内容视图按可用高度决定，这里保留当天的全部全天事项。
class WSMyDayAllDayEventsDataItem: NSObject, WSPluginDataItem {
    
    /// 日期
    let date: Date
    
    /// 当天的全天事项，按时间线一致的顺序排列
    let items: [WSMyDayAllDayEventItem]
    
    init(date: Date, items: [WSMyDayAllDayEventItem]) {
        self.date = date
        self.items = items
        super.init()
    }
    
    /// 由我的一天事项生成展示数据
    convenience init(date: Date, events: [MyDayEvent]) {
        self.init(date: date, items: events.map(WSMyDayAllDayEventItem.init(event:)))
    }
}
