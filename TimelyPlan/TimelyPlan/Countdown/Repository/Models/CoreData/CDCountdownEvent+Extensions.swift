//
//  CDCountdownEvent+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import CoreData
import UIKit

extension CDCountdownEvent: TPHexColorConvertible, SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    // MARK: - TPHexColorConvertible
    static var defaultColor: UIColor {
        return CountdownConfig.countdownEventDefaultColor
    }
    
    /// 倒数日事项模型
    var event: CountdownEvent {
        return CountdownEvent(content: self)
    }
    
    // MARK: - 创建与更新
    /// 根据编辑事项创建新倒数日事项
    static func newEvent(with editingEvent: CountdownEditingEvent) -> CDCountdownEvent {
        let event = CDCountdownEvent.createEntity(in: .defaultContext)
        event.identifier = UUID().uuidString /// 新创建倒数日事项设置标识
        event.update(with: editingEvent)
        return event
    }
    
    /// 使用编辑事项更新倒数日事项内容
    func update(with editingEvent: CountdownEditingEvent) {
        self.eventType = Int16(editingEvent.type.rawValue)
        self.dateType = Int16(editingEvent.date.type.rawValue)
        self.targetDate = editingEvent.date.targetDate
        self.isLeapMonth = editingEvent.date.isLeapMonth
        self.includesStartDate = editingEvent.includesStartDate
        self.timeUnit = Int16(editingEvent.timeUnit.rawValue)
        self.name = editingEvent.name
        self.emoji = editingEvent.emoji
        self.colorHex = editingEvent.color.hexString
        self.note = editingEvent.note
        
        /// 显示方式：仅使用一个 Int16 字段承载全部模式
        self.myDayDisplayMode = editingEvent.myDayDisplayMode.code
        self.calendarDisplayMode = editingEvent.calendarDisplayMode.code
        
        /// 时间计划与提醒
        updateTimePlan(editingEvent.timePlan)
        updateReminder(editingEvent.reminder)
    }
    
    /// 更新时间计划（nil 表示不重复）
    func updateTimePlan(_ timePlan: CountdownTimePlan?) {
        guard let timePlan = timePlan, let type = timePlan.type , type != .none else {
            self.timePlanJSON = nil
            return
        }
        
        self.timePlanJSON = timePlan.jsonString()
    }
    
    /// 更新提醒（nil 表示无提醒）
    func updateReminder(_ reminder: CountdownReminder?) {
        guard let reminder = reminder, reminder.hasAlarm else {
            self.reminderJSON = nil
            return
        }
        
        self.reminderJSON = reminder.jsonString()
    }
}

// MARK: - 获取倒数日事项
extension CDCountdownEvent {
    
    // MARK: - Predicate
    static var activeEventsPredicateCondition: PredicateCondition {
        return (CountdownEventKey.isArchived, .notEqual(true))
    }
    
    static var archivedEventsPredicateCondition: PredicateCondition {
        return (CountdownEventKey.isArchived, .isTrue)
    }
    
    // MARK: - 异步获取
    static func fetchActiveEvents(completion: @escaping([CDCountdownEvent]?) -> Void) {
        let predicate = NSPredicate.predicate(with: activeEventsPredicateCondition)
        CDCountdownEvent.fetchAll(matching: predicate,
                                  sortBy: ElementOrderKey,
                                  ascending: true) { results in
            completion(results as? [CDCountdownEvent])
        }
    }
    
    static func fetchArchivedEvents(completion: @escaping([CDCountdownEvent]?) -> Void) {
        let predicate = NSPredicate.predicate(with: archivedEventsPredicateCondition)
        CDCountdownEvent.fetchAll(matching: predicate,
                                  sortBy: ElementOrderKey,
                                  ascending: true) { results in
            completion(results as? [CDCountdownEvent])
        }
    }
    
    // MARK: - 异步搜索
    /// 按名称搜索活动倒数日事项（不区分大小写）
    static func searchActiveEvents(containText text: String,
                                   completion: @escaping([CDCountdownEvent]?) -> Void) {
        let conditions: [PredicateCondition] = [activeEventsPredicateCondition,
                                                (CountdownEventKey.name, .contains(text))]
        let predicate = conditions.andPredicate()
        CDCountdownEvent.fetchAll(matching: predicate,
                                  sortBy: ElementOrderKey,
                                  ascending: true) { results in
            completion(results as? [CDCountdownEvent])
        }
    }
    
    // MARK: - 同步获取
    /// 获取特定标识的倒数日事项
    static func getEvent(withIdentifier identifier: String) -> CDCountdownEvent? {
        let condition: PredicateCondition = (CountdownEventKey.identifier, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        return CDCountdownEvent.getFirst(matching: predicate, in: .defaultContext)
    }
    
    /// 同步获取所有倒数日事项
    static func getAllEvents() -> [CDCountdownEvent]? {
        let events: [CDCountdownEvent]? = CDCountdownEvent.getAll(sortBy: ElementOrderKey,
                                                                  ascending: true,
                                                                  in: .defaultContext)
        return events
    }
    
    /// 获取所有活动倒数日事项
    static func getActiveEvents() -> [CDCountdownEvent]? {
        return getEvents(withCondition: activeEventsPredicateCondition)
    }
    
    /// 获取所有已归档倒数日事项
    static func getArchivedEvents() -> [CDCountdownEvent]? {
        return getEvents(withCondition: archivedEventsPredicateCondition)
    }
    
    /// 获取已归档倒数日事项数目
    static func numberOfArchivedEvents() -> Int {
        let predicate = NSPredicate.predicate(with: archivedEventsPredicateCondition)
        return CDCountdownEvent.countOfEntries(with: predicate, in: .defaultContext)
    }
    
    private static func getEvents(withCondition condition: PredicateCondition) -> [CDCountdownEvent]? {
        let predicate = NSPredicate.predicate(with: condition)
        let events: [CDCountdownEvent]? = CDCountdownEvent.getAll(matching: predicate,
                                                                  sortBy: ElementOrderKey,
                                                                  ascending: true,
                                                                  in: .defaultContext)
        return events
    }
}

extension CountdownEvent {
    
    /// 根据 CoreData 倒数日事项创建模型
    convenience init(content: CDCountdownEvent) {
        /// targetDate 在实体中为非可选属性，这里做一次可选提升以兼容不同版本的代码生成结果
        let targetDate = content.targetDate as Date? ?? Date().endOfDay()
        let eventType = CountdownEventType(rawValue: Int(content.eventType)) ?? .countdown
        let dateType = CountdownDateType(rawValue: Int(content.dateType)) ?? .gregorian
        let timeUnit = CountdownTimeUnit(rawValue: Int(content.timeUnit)) ?? .days
        self.init(identifier: content.identifier ?? UUID().uuidString,
                  type: eventType,
                  order: content.order,
                  name: content.name,
                  emoji: content.emoji,
                  colorHex: content.colorHex,
                  date: CountdownDate(type: dateType,
                                      targetDate: targetDate,
                                      isLeapMonth: content.isLeapMonth),
                  includesStartDate: content.includesStartDate,
                  timeUnit: timeUnit,
                  note: content.note,
                  myDayDisplayMode: CountdownDisplayMode(code: content.myDayDisplayMode),
                  calendarDisplayMode: CountdownDisplayMode(code: content.calendarDisplayMode),
                  reminderJSON: content.reminderJSON,
                  timePlanJSON: content.timePlanJSON,
                  isArchived: content.isArchived)
    }
}

extension Array where Element == CDCountdownEvent {
    
    /// 所有标识
    var identifiers: [String] {
        var results = [String]()
        for event in self {
            if let identifier = event.identifier {
                results.append(identifier)
            }
        }
        
        return results
    }
    
    var toEvents: [CountdownEvent] {
        return self.map { CountdownEvent(content: $0) }
    }
}
