//
//  MyDayTimelineItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/21.
//

import Foundation
import UIKit

// MARK: - 数据模型

enum MyDayTimelineNodeStyle {
    case independent
    case connectToPrevious
    case connectToNext
    case connectToBoth
}

enum MyDayTimelineItemPosition {
    case first      // 第一个节点
    case middle     // 中间节点
    case last       // 最后一个节点
    case only       // 唯一节点（只有一个事件时）
}

enum MyDayTimelineItemType: Equatable {
    case point
    case short
    case long
}

enum MyDayTimelineConnectionStyle {
    case solid
    case dashed
    case overlapping
}

/// 时间线区块
enum MyDayTimelineSection: Int {
    case allDay = 0
    case timed
}

// MARK: - 条目基类

/// 时间线条目基类
/// - Note: 需遵循 `ListDiffable` 协议，供 `TPCollectionViewAdapter` 做差异计算
class MyDayTimelineDataItem: NSObject {
    
    /// 唯一标识
    let identifier: String
    
    init(identifier: String) {
        self.identifier = identifier
        super.init()
    }
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MyDayTimelineDataItem else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
    
    // MARK: - ListDiffable
    
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}

// MARK: - 事件条目

class MyDayTimelineItem: MyDayTimelineDataItem {
    
    let event: MyDayEvent
    let type: MyDayTimelineItemType
    let position: MyDayTimelineItemPosition
    let nodeStyle: MyDayTimelineNodeStyle
    
    init(event: MyDayEvent,
         type: MyDayTimelineItemType,
         position: MyDayTimelineItemPosition,
         nodeStyle: MyDayTimelineNodeStyle) {
        self.event = event
        self.type = type
        self.position = position
        self.nodeStyle = nodeStyle
        super.init(identifier: event.identifier)
    }
    
    var nodeColor: UIColor {
        return event.color
    }
    
    var startDate: Date {
        return event.startDate
    }
    
    var endDate: Date {
        return event.endDate
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? MyDayTimelineItem else { return false }
        if self === other { return true }
        
        guard identifier == other.identifier,
              type == other.type,
              position == other.position,
              nodeStyle == other.nodeStyle else {
            return false
        }
        
        return startDate == other.startDate
            && endDate == other.endDate
            && event.title == other.event.title
            && event.isCompleted == other.event.isCompleted
    }
}

// MARK: - 连接线条目

class MyDayTimelineConnectionItem: MyDayTimelineDataItem {
    
    let style: MyDayTimelineConnectionStyle
    let height: CGFloat
    let topDate: Date /// 顶部日期
    let bottomDate: Date /// 底部日期
    let topColor: UIColor
    let bottomColor: UIColor
    
    init(style: MyDayTimelineConnectionStyle,
         height: CGFloat,
         topDate: Date,
         bottomDate: Date,
         topColor: UIColor,
         bottomColor: UIColor) {
        self.style = style
        self.height = height
        self.topDate = topDate
        self.bottomDate = bottomDate
        self.topColor = topColor
        self.bottomColor = bottomColor
        super.init(identifier: "\(topDate.timeIntervalSince1970)-\(bottomDate.timeIntervalSince1970)")
    }
    
    var timeInterval: TimeInterval {
        return bottomDate.timeIntervalSince(topDate)
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? MyDayTimelineConnectionItem else { return false }
        if self === other { return true }
        
        return identifier == other.identifier
            && style == other.style
            && height == other.height
    }
}

// MARK: - 区块对象

/// 时间线区块对象（供适配器作为 `objects` 使用）
class MyDayTimelineSectionObject: NSObject {
    
    let kind: MyDayTimelineSection
    
    /// 区块内全部条目
    private(set) var items: [MyDayTimelineDataItem]
    
    /// 是否展开（仅全天区块使用）
    var isExpanded: Bool = false
    
    /// 最多显示的条目数量，`nil` 表示不限制（仅全天区块使用）
    var maxVisibleCount: Int?
    
    init(kind: MyDayTimelineSection, items: [MyDayTimelineDataItem] = []) {
        self.kind = kind
        self.items = items
        super.init()
    }
    
    // MARK: - 条目
    
    /// 当前显示的条目（全天区块收起时按配置数量截断）
    func visibleItems() -> [MyDayTimelineDataItem] {
        let count = visibleItemCount
        guard count < items.count else {
            return items
        }
        
        return Array(items[0..<count])
    }
    
    /// 被隐藏的条目数量
    var hiddenItemCount: Int {
        return max(0, items.count - visibleItemCount)
    }
    
    /// 是否需要显示展开/收起按钮
    var shouldShowFooter: Bool {
        guard kind == .allDay, let maxVisibleCount = maxVisibleCount else {
            return false
        }
        
        return items.count > maxVisibleCount
    }
    
    private var visibleItemCount: Int {
        if isExpanded {
            return items.count
        }
        
        guard let maxVisibleCount = maxVisibleCount else {
            return items.count
        }
        
        return min(items.count, maxVisibleCount)
    }
    
    // MARK: - ListDiffable
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(kind.rawValue)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? MyDayTimelineSectionObject else { return false }
        if self === other { return true }
        return kind == other.kind
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return "\(kind.rawValue)" as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}
