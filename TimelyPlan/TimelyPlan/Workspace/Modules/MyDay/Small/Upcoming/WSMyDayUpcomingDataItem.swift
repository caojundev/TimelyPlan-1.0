//
//  WSMyDayUpcomingDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit
import EventKit

// MARK: - 事项数据

/// 临近事项的展示数据。
struct WSMyDayUpcomingEventItem {
    
    /// 事项标识
    let identifier: String
    
    /// 事项名称
    let title: String?
    
    /// 事项副标题，内容与时间线单元格一致
    let subtitle: TextRepresentable?
    
    /// 事项颜色
    let color: UIColor
    
    /// 事项类型图标，与时间线节点图标一致
    let sourceIcon: TPIcon?
    
    /// 开始时间
    let startDate: Date
    
    /// 结束时间
    let endDate: Date
    
    /// 原始事项，点击时据此打开详情
    let event: MyDayEvent
    
    init(event: MyDayEvent) {
        self.identifier = event.identifier
        self.title = event.displayTitle
        self.subtitle = event.displaySubtitle
        self.color = event.color
        self.sourceIcon = event.sourceIcon
        self.startDate = event.startDate
        self.endDate = event.endDate
        self.event = event
    }
}

// MARK: - 组件数据

/// 我的一天·临近事项的组件数据。
///
/// 保存今天的全部事项，展示哪一条由内容视图按当前时间解析，
/// 这样时间流逝时无需重新取数即可切换到下一事项。
class WSMyDayUpcomingDataItem: NSObject, WSPluginDataItem {
    
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

// MARK: - 展示解析

/// 某一时刻需要展示的临近事项
struct WSMyDayUpcomingDisplay {
    
    /// 展示的事项
    let item: WSMyDayUpcomingEventItem
    
    /// 当前时间在事项中的进度，取值 0~1
    let progress: CGFloat
    
    /// 与展示事项重叠且尚未结束的其他事项数目
    let overlappingCount: Int
}

/// 按当前时间解析需要展示的临近事项
enum WSMyDayUpcomingResolver {
    
    /// 从全部事项中取正在进行的事项，没有时取接下来第一个非全天事项
    static func resolve(events: [MyDayEvent], at date: Date) -> WSMyDayUpcomingDisplay? {
        let items = events.filter { !$0.isAllDay }.map(WSMyDayUpcomingEventItem.init(event:))
        let ongoing = items.first { $0.startDate <= date && date <= $0.endDate }
        let upcoming = items.first { $0.startDate > date }
        guard let item = ongoing ?? upcoming else {
            return nil
        }
        
        /// 与展示事项重叠、且按当前时间尚未结束的其他事项
        let overlappingCount = items.filter { candidate in
            guard candidate.identifier != item.identifier else {
                return false
            }
            
            return candidate.startDate < item.endDate
                && candidate.endDate > item.startDate
                && candidate.endDate > date
        }.count
        
        return WSMyDayUpcomingDisplay(item: item,
                                      progress: progress(of: item, at: date),
                                      overlappingCount: overlappingCount)
    }
    
    /// 当前时间在事项中的进度
    private static func progress(of item: WSMyDayUpcomingEventItem, at date: Date) -> CGFloat {
        let duration = item.endDate.timeIntervalSince(item.startDate)
        guard duration > 0.0, date > item.startDate else {
            return 0.0
        }
        
        return CGFloat(min(max(date.timeIntervalSince(item.startDate) / duration, 0.0), 1.0))
    }
}
