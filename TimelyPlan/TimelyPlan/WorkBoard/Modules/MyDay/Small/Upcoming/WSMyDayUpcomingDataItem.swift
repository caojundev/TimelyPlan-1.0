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

/// 临近事项的展示数据。作为点击回调的数据条目传给交互器
struct WSMyDayUpcomingEventItem: WSPluginDataItem {
    
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
        self.init(event: event,
                  title: event.displayTitle,
                  subtitle: event.displaySubtitle)
    }
    
    init(event: MyDayEvent, title: String?, subtitle: TextRepresentable?) {
        self.identifier = event.identifier
        self.title = title
        self.subtitle = subtitle
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
/// 保留今天全部非全天事项，展示哪一条由内容视图按当前时间解析，
/// 这样时间流逝时无需重新取数即可切换到下一事项。
class WSMyDayUpcomingDataItem: NSObject, WSPluginDataItem {
    
    /// 日期
    let date: Date
    
    /// 今天的非全天事项，按开始时间排序
    let items: [WSMyDayUpcomingEventItem]
    
    init(date: Date, items: [WSMyDayUpcomingEventItem]) {
        self.date = date
        self.items = items
        super.init()
    }
    
    /// 由我的一天事项生成展示数据
    convenience init(date: Date, events: [MyDayEvent]) {
        self.init(date: date, items: events.map(WSMyDayUpcomingEventItem.init(event:)))
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
    
    /// 取正在进行的事项，没有时取今天接下来的第一个事项
    static func resolve(items: [WSMyDayUpcomingEventItem], at date: Date) -> WSMyDayUpcomingDisplay? {
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
