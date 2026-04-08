//
//  CDHabitTask+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import UIKit
import CoreData

extension CDHabitTask: TPHexColorConvertible, SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    /// 默认颜色
    static var defaultColor: UIColor {
        return kHabitTaskDefaultColor
    }
    
    /// 表情符号
    var emoji: String {
        if let iconName = iconName {
            return iconName
        }
        
        return name?.first?.stringValue ?? "C"
    }
    
    /// 日期范围
    var dateRange: DateRange {
        return DateRange(startDate: self.startDate ?? .now, endDate: self.endDate)
    }
    
    /// 目标
    var goal: HabitGoal {
        let targetMode = HabitGoal.TargetMode(rawValue: Int(self.goalMode)) ?? .checkin
        let recordType = HabitGoal.RecordType(rawValue: Int(self.goalRecordType)) ?? .completeAll
        return HabitGoal(mode: targetMode,
                         targetAmount: goalTargetAmount,
                         unit: goalUnit,
                         recordType: recordType,
                         recordAmount: goalRecordAmount)
    }
    
    /// 根据编辑任务创建新任务
    static func newTask(with editingTask: HabitEditingTask) -> CDHabitTask {
        let task = CDHabitTask.createEntity(in: .defaultContext)
        task.identifier = UUID().uuidString ///新创建任务设置标识
        task.creationDate = .now
        task.isArchived = false
        task.update(with: editingTask)
        return task
    }
    
    func update(with editingTask: HabitEditingTask) {
        self.iconName = editingTask.emoji
        self.name = editingTask.name
        self.colorHex = editingTask.color.hexString
        
        /// 时间范围
        self.startDate = editingTask.dateRange.startDate
        self.endDate = editingTask.dateRange.endDate
        
        /// 目标
        let goal = editingTask.goal
        self.goalMode = Int16(goal.mode.rawValue)
        self.goalTargetAmount = goal.validatedTargetAmount
        self.goalUnit = goal.unit
        self.goalRecordType = Int16(goal.recordType?.rawValue ?? 0)
        self.goalRecordAmount = goal.recordAmount ?? 0
        
        self.timePlanRuleJSON = editingTask.timePlan.regularRule?.jsonString()
        self.timeOption = Int16(editingTask.timeOption.rawValue)
        self.shouldRemind = editingTask.shouldRemind
        self.reminderJSON = editingTask.reminder?.jsonString()
        self.note = editingTask.note
        self.modificationDate = .now
    }
}

// MARK: - 获取任务
extension CDHabitTask {
    
    // MARK: - 异步搜索
    /// 搜索计时器
    static func searchActiveTasks(containText text: String, completion:(@escaping([CDHabitTask]?) -> Void)) {
        let conditions: [PredicateCondition] = [(HabitTaskKey.isArchived, .isFalse),
                                                (HabitTaskKey.name, .contains(text))]
        let predicate = conditions.andPredicate()
        CDHabitTask.fetchAll(matching: predicate, sortBy: ElementOrderKey, ascending: true) { results in
            let tasks = results as? [CDHabitTask]
            completion(tasks)
        }
    }
    
    // MARK: - 异步获取
    static func fetchActiveTasks(completion: @escaping([CDHabitTask]?) -> Void) {
        CDHabitTask.findAll(with: activeTaskPredicate,
                            sortedBy: ElementOrderKey,
                            ascending: true) { results in
            completion(results as? [CDHabitTask])
        }
    }
    
    static func fetchArchivedTasks(completion: @escaping([CDHabitTask]?) -> Void) {
        CDHabitTask.findAll(with: archivedTaskPredicate,
                            sortedBy: ElementOrderKey,
                            ascending: true) { results in
            completion(results as? [CDHabitTask])
        }
    }
    
    // MARK: - 同步获取
    /// 获取特定标识的任务
    static func getTask(with identifier: String) -> CDHabitTask? {
        let condition: PredicateCondition = (HabitTaskKey.identifier, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        let result = CDHabitTask.findFirst(withPredicate: predicate, in: .defaultContext)
        return result
    }
    
    /// 获取特定标识数组中的所有任务
    static func getTasks(with identifiers: [String]) -> [CDHabitTask]? {
        let condition: PredicateCondition = (HabitTaskKey.identifier, .belongsTo(identifiers))
        let predicate = NSPredicate.predicate(with: condition)
        let results: [CDHabitTask]? = CDHabitTask.findAll(with: predicate, in: .defaultContext)
        return results
    }
    
    /// 获取所有习惯任务
    static func getAllTasks() -> [CDHabitTask] {
        return getTasks(with: nil)
    }
    
    /// 获取归档任务
    static func getArchivedTasks() -> [CDHabitTask] {
        let predicate = archivedTaskPredicate
        return getTasks(with: predicate)
    }
    
    /// 归档任务数目
    static func getArchivedTasksCount() -> Int {
        let predicate = archivedTaskPredicate
        let count = CDHabitTask.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
    /// 获取活动任务
    static func getActiveTasks() -> [CDHabitTask] {
        return getTasks(with: activeTaskPredicate)
    }
    
    static func getTasks(with predicate: NSPredicate? = nil) -> [CDHabitTask] {
        let results: [CDHabitTask]? = CDHabitTask.findAll(with: predicate,
                                                          sortedBy: HabitTaskKey.order,
                                                          ascending: true,
                                                          in: .defaultContext)
        guard let results = results else {
            return []
        }
        
        return results
    }

    // MARK: - Predicate
    /// 已归档任务谓词
    private static var archivedTaskPredicate: NSPredicate {
        let condition: PredicateCondition = (HabitTaskKey.isArchived, .isTrue)
        return NSPredicate.predicate(with: condition)
    }
    
    private static var activeTaskPredicate: NSPredicate {
        let condition: PredicateCondition = (HabitTaskKey.isArchived, .notEqual(true))
        return NSPredicate.predicate(with: condition)
    }
}

extension NSManagedObject {
    
    /// 最小排序因子
    static var minimumOrder: Int64 {
        return minimumOrder(with: nil)
    }
    
    static func minimumOrder(with predicate: NSPredicate? = nil) -> Int64 {
        let order = performAggregateOperation(function: .min,
                                              onAttribute: ElementOrderKey,
                                              withPredicate: predicate,
                                              in: .defaultContext) as? Int64
        return order ?? 0
    }
    
    /// 最大排序因子
    static var maximumOrder: Int64 {
        return maximumOrder(with: nil)
    }
    
    static func maximumOrder(with predicate: NSPredicate? = nil) -> Int64 {
        let order = performAggregateOperation(function: .max,
                                              onAttribute: ElementOrderKey,
                                              withPredicate: predicate,
                                              in: .defaultContext) as? Int64
        return order ?? 0
    }
}

extension Array where Element == CDHabitTask {
    /// 转换成 HabitTask 数组
    var tasks: [HabitTask] {
        return self.map { HabitTask(content: $0) }
    }
}
