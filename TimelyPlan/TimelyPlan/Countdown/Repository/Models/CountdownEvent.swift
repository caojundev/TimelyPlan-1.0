//
//  CountdownEvent.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import UIKit

/// 倒数日事件的 CoreData 属性键
struct CountdownEventKey {
    static let identifier = "identifier"
    static let eventType = "eventType"
    static let order = "order"
    static let name = "name"
    static let emoji = "emoji"
    static let colorHex = "colorHex"
    static let targetDate = "targetDate"
    static let note = "note"
    static let isArchived = "isArchived"
}

/// 倒数日事件
class CountdownEvent: NSObject,
                      TPHexColorConvertible,
                      SortableIdentifiable {
    
    /// 事件唯一标识
    var identifier: String
    
    /// 事件类型
    var type: CountdownEventType
    
    /// 排序因子
    var order: Int64
    
    /// 事件名称
    var name: String?
    
    /// 事件表情
    var emoji: String?
    
    /// 事件颜色
    var colorHex: String?
    
    /// 目标日期
    var targetDate: Date
    
    /// 备注
    var note: String?
    
    /// 是否已归档
    var isArchived: Bool
    
    init(identifier: String = UUID().uuidString,
         type: CountdownEventType = .countdown,
         order: Int64 = 0,
         name: String? = nil,
         emoji: String? = nil,
         colorHex: String? = nil,
         targetDate: Date = Date().endOfDay(),
         note: String? = nil,
         isArchived: Bool = false) {
        self.identifier = identifier
        self.type = type
        self.order = order
        self.name = name
        self.emoji = emoji
        self.colorHex = colorHex
        self.targetDate = targetDate
        self.note = note
        self.isArchived = isArchived
        super.init()
    }
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return identifier
    }
    
    // MARK: - Getters
    /// 显示名称
    var displayName: String {
        return name ?? resGetString("Untitled Countdown")
    }
    
    /// 距离目标日期的天数（正数为剩余天数，负数为已经过去的天数）
    var remainingDays: Int {
        return Date.days(fromDate: Date(), toDate: targetDate)
    }
    
    /// 目标日期是否已经过去
    var isExpired: Bool {
        return remainingDays < 0
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        hasher.combine(targetDate)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CountdownEvent else { return false }
        if self === other { return true }
        return editingEvent == other.editingEvent
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? CountdownEvent {
            return self.identifier == other.identifier
                && self.targetDate == other.targetDate
        }
        
        return false
    }
}

extension CountdownEvent {
    
    /// 默认颜色
    static var defaultColor: UIColor {
        return CountdownConfig.countdownEventDefaultColor
    }
}

/// 编辑倒数日事件
struct CountdownEditingEvent: Equatable {
    
    /// 事件类型
    var type: CountdownEventType = .countdown
    
    /// 事件名称
    var name: String?
    
    /// 事件表情
    var emoji: String = CountdownConfig.defaultEmoji
    
    /// 事件颜色
    var color: UIColor = CountdownConfig.countdownEventDefaultColor
    
    /// 目标日期
    var targetDate: Date
    
    /// 备注
    var note: String?
    
    init(type: CountdownEventType = .countdown,
         targetDate: Date = Date().endOfDay()) {
        self.type = type
        self.targetDate = targetDate
    }
    
    // MARK: - Equatable
    static func == (lhs: CountdownEditingEvent, rhs: CountdownEditingEvent) -> Bool {
        return lhs.type == rhs.type
            && lhs.name == rhs.name
            && lhs.emoji == rhs.emoji
            && lhs.color == rhs.color
            && lhs.targetDate == rhs.targetDate
            && lhs.note == rhs.note
    }
}

// MARK: - 编辑倒数日
extension CountdownEvent {
    
    /// 编辑事件
    var editingEvent: CountdownEditingEvent {
        var event = CountdownEditingEvent(type: type, targetDate: targetDate)
        event.name = name
        event.emoji = emoji ?? CountdownConfig.defaultEmoji
        event.color = color ?? CountdownConfig.countdownEventDefaultColor
        event.note = note
        return event
    }
    
    /// 判断编辑内容是否与当前事件相同
    func isSameEvent(as editingEvent: CountdownEditingEvent) -> Bool {
        return self.editingEvent == editingEvent
    }
}

extension Array where Element == CountdownEvent {
    
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
}
