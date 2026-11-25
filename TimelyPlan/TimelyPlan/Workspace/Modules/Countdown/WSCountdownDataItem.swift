//
//  WSCountdownDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/21.
//

import Foundation
import UIKit

// MARK: - 数据条目

/// 倒数日组件数据。
///
/// 承载单个倒数日事项展示所需的全部信息。内容视图只依赖该数据渲染，
/// 不直接访问事项模型，也不做取数与换算。
class WSCountdownDataItem: NSObject, WSPluginDataItem {
    
    /// 事项唯一标识。交互时据此读取最新的倒数日事项，避免持有过期快照
    let eventIdentifier: String
    
    /// 事项名称
    let title: String
    
    /// 事项图标（emoji）
    let emoji: String
    
    /// 事项主题色
    let color: UIColor
    
    /// 发生日期文本，如「2026年10月25日」
    let dateText: String
    
    /// 剩余时间换算结果，交给 `CountdownTimeValueView` 直接渲染
    let timeResult: CountdownCalculator.TimeResult
    
    init(eventIdentifier: String,
         title: String,
         emoji: String,
         color: UIColor,
         dateText: String,
         timeResult: CountdownCalculator.TimeResult) {
        self.eventIdentifier = eventIdentifier
        self.title = title
        self.emoji = emoji
        self.color = color
        self.dateText = dateText
        self.timeResult = timeResult
        super.init()
    }
    
    /// 由倒数日事项生成展示数据
    convenience init(event: CountdownEvent) {
        self.init(eventIdentifier: event.identifier,
                  title: event.displayName,
                  emoji: event.emoji ?? event.type.emoji,
                  color: event.color ?? event.type.color,
                  dateText: event.occuranceDate.displayText,
                  timeResult: event.remainingTimeResult)
    }
}

/// 倒数日多行组件数据。
///
/// 承载多个倒数日事项，供需要同时展示多行的组件（如中号、大号的事项组件）使用。
class WSCountdownEventsDataItem: NSObject, WSPluginDataItem {
    
    /// 待展示的事项，按展示顺序排列
    let items: [WSCountdownDataItem]
    
    init(items: [WSCountdownDataItem]) {
        self.items = items
        super.init()
    }
    
    /// 由倒数日事项列表生成展示数据
    convenience init(events: [CountdownEvent]) {
        self.init(items: events.map { WSCountdownDataItem(event: $0) })
    }
}
