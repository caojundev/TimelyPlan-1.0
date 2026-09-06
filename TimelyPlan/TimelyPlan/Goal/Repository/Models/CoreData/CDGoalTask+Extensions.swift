//
//  CDGoalTask+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/4.
//

import Foundation
import CoreData
import UIKit

extension CDGoalTask: TPHexColorConvertible, SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    // MARK: - TPHexColorConvertible
    static var defaultColor: UIColor {
        return .primary
    }
    
    // MARK: - 枚举桥接
    /// 计算方式
    var progressCalculation: GoalProgressCalculation {
        get {
            return GoalProgressCalculation(rawValue: Int(self.calculation)) ?? .sum
        }
        
        set {
            self.calculation = Int16(newValue.rawValue)
        }
    }
    
    /// 记录方式
    var progressRecordType: GoalProgressRecordType {
        get {
            return GoalProgressRecordType(rawValue: Int(self.recordType)) ?? .manual
        }
        
        set {
            self.recordType = Int16(newValue.rawValue)
        }
    }
    
    /// 自动记录数值（为 0 时表示未设置）
    var autoRecordNumber: Int? {
        get {
            guard self.autoRecordValue != 0 else {
                return nil
            }
            
            return Int(self.autoRecordValue)
        }
        
        set {
            self.autoRecordValue = Int64(newValue ?? 0)
        }
    }
    
    /// 任务权重（1～10）
    var weightNumber: Int64 {
        get {
            return Int64(self.weight)
        }
        
        set {
            self.weight = Int16(newValue)
        }
    }
    
    /// 日期区间
    var dateRange: DateRange {
        get {
            return DateRange(startDate: self.startDate, endDate: self.endDate)
        }
        
        set {
            self.startDate = newValue.startDate
            self.endDate = newValue.endDate
        }
    }
    
    // MARK: - 创建与更新
    /// 根据编辑任务创建目标任务
    static func newGoalTask(in goalPlan: GoalPlan,
                            with editingTask: GoalEditingTask) -> CDGoalTask? {
        guard let cdGoalPlan = CDGoalPlan.getGoalPlan(withIdentifier: goalPlan.identifier) else {
            return nil
        }
        
        let task = CDGoalTask.createEntity(in: .defaultContext)
        task.identifier = UUID().uuidString /// 新创建目标任务设置标识
        task.creationDate = .now
        task.currentValue = editingTask.initialValue
        task.update(with: editingTask)
        cdGoalPlan.addTask(task, onTop: false)
        return task
    }
    
    /// 使用编辑任务更新目标任务内容
    func update(with editingTask: GoalEditingTask) {
        self.name = editingTask.name
        self.colorHex = editingTask.color.hexString
        self.isAddedToMyDay = editingTask.isAddedToMyDay
        
        /// 计划
        self.startDate = editingTask.startDate
        self.endDate = editingTask.endDate
        self.startTime = editingTask.startTime
        self.duration = editingTask.duration
        
        /// 提醒
        self.shouldRemind = editingTask.shouldRemind
        self.reminderJSON = editingTask.shouldRemind ? editingTask.reminder?.jsonString() : nil
        
        self.note = editingTask.note
        
        /// 进度
        self.initialValue = editingTask.initialValue
        self.targetValue = editingTask.targetValue
        self.progressCalculation = editingTask.calculation
        self.progressRecordType = editingTask.recordType
        self.autoRecordNumber = editingTask.autoRecordValue
        self.weightNumber = editingTask.weight
        
        /// 当前数值需要限制在调整后的区间内
        self.currentValue = GoalTask.validatedCurrentValue(self.currentValue,
                                                           initialValue: self.initialValue,
                                                           targetValue: self.targetValue)
        
        updateSteps(editingTask.steps)
        updateProgressFraction()
        self.modificationDate = .now
    }
    
    /// 更新步骤，返回是否发生改变
    @discardableResult
    func updateSteps(_ steps: [TodoStep]?) -> Bool {
        let markdown = steps?.markdown()
        guard self.stepMarkdown != markdown else {
            return false
        }
        
        self.stepMarkdown = markdown
        self.stepCount = Int64(steps?.totalCount() ?? 0)
        self.stepCompletedCount = Int64(steps?.completedCount() ?? 0)
        return true
    }
    
    /// 更新完成状态
    func updateCompleted(_ isCompleted: Bool) {
        self.isCompleted = isCompleted
        self.completionDate = isCompleted ? .now : nil
    }
    
    /// 更新当前数值
    func updateCurrentValue(_ currentValue: Int64) {
        self.currentValue = GoalTask.validatedCurrentValue(currentValue,
                                                           initialValue: self.initialValue,
                                                           targetValue: self.targetValue)
        updateProgressFraction()
    }
    
    /// 更新进度
    func updateProgressFraction() {
        self.progressFraction = GoalTask.progressFraction(initialValue: self.initialValue,
                                                          targetValue: self.targetValue,
                                                          currentValue: self.currentValue)
    }
    
    /// 更新提醒
    func updateReminder(_ reminder: ScheduledReminder?, shouldRemind: Bool) {
        self.shouldRemind = shouldRemind
        self.reminderJSON = shouldRemind ? reminder?.jsonString() : nil
    }
}

// MARK: - 处理目标任务
extension CDGoalTask {
    
    /// 根据标识获取目标任务
    static func getGoalTask(withIdentifier identifier: String) -> CDGoalTask? {
        return getItem(with: identifier)
    }
    
    /// 根据标识数组批量获取目标任务
    static func getGoalTasks(withIdentifiers identifiers: [String]) -> [CDGoalTask]? {
        let condition: PredicateCondition = (GoalTaskKey.identifier, .belongsTo(identifiers))
        let predicate = NSPredicate.predicate(with: condition)
        let results: [CDGoalTask]? = getAll(matching: predicate, in: .defaultContext)
        return results
    }
    
    /// 根据目标任务模型数组获取对应的托管对象
    static func getIdentifiableGoalTasks(with goalTasks: [GoalTask]) -> [CDGoalTask]? {
        let identifiers = goalTasks.map { $0.identifiableKey }
        guard identifiers.count > 0 else {
            return nil
        }
        
        return getGoalTasks(withIdentifiers: identifiers)
    }
    
    /// 更新目标任务内容
    static func updateGoalTask(_ goalTask: GoalTask,
                               with editingTask: GoalEditingTask) -> Bool {
        guard let cdTask = getItem(with: goalTask.identifier) else {
            return false
        }
        
        cdTask.update(with: editingTask)
        return true
    }
    
    static func updateGoalTask(_ goalTask: GoalTask, name: String?) -> Bool {
        guard let cdTask = getItem(with: goalTask.identifier) else {
            return false
        }
        
        cdTask.name = name
        cdTask.modificationDate = .now
        return true
    }
    
    static func updateGoalTask(_ goalTask: GoalTask, note: String?) -> Bool {
        guard let cdTask = getItem(with: goalTask.identifier) else {
            return false
        }
        
        cdTask.note = note
        cdTask.modificationDate = .now
        return true
    }
    
    static func updateGoalTask(_ goalTask: GoalTask, steps: [TodoStep]?) -> Bool {
        guard let cdTask = getItem(with: goalTask.identifier) else {
            return false
        }
        
        guard cdTask.updateSteps(steps) else {
            return false
        }
        
        cdTask.modificationDate = .now
        return true
    }
    
    /// 更新当前数值，返回更新后的数值
    static func updateGoalTask(_ goalTask: GoalTask, currentValue: Int64) -> Int64? {
        guard let cdTask = getItem(with: goalTask.identifier) else {
            return nil
        }
        
        cdTask.updateCurrentValue(currentValue)
        cdTask.modificationDate = .now
        return cdTask.currentValue
    }
    
    static func updateGoalTasks(_ goalTasks: [GoalTask], isCompleted: Bool) -> Bool {
        guard let cdTasks = getIdentifiableGoalTasks(with: goalTasks), cdTasks.count > 0 else {
            return false
        }
        
        let modificationDate = Date()
        for cdTask in cdTasks {
            cdTask.updateCompleted(isCompleted)
            cdTask.modificationDate = modificationDate
        }
        
        return true
    }
    
    static func updateGoalTasks(_ goalTasks: [GoalTask], isAddedToMyDay: Bool) -> Bool {
        guard let cdTasks = getIdentifiableGoalTasks(with: goalTasks), cdTasks.count > 0 else {
            return false
        }
        
        let modificationDate = Date()
        for cdTask in cdTasks {
            cdTask.isAddedToMyDay = isAddedToMyDay
            cdTask.modificationDate = modificationDate
        }
        
        return true
    }
    
    /// 删除目标任务
    static func deleteGoalTasks(_ goalTasks: [GoalTask]) -> Bool {
        guard let cdTasks = getIdentifiableGoalTasks(with: goalTasks), cdTasks.count > 0 else {
            return false
        }
        
        NSManagedObjectContext.defaultContext.deleteObjects(cdTasks)
        return true
    }
    
    /// 重排目标任务
    static func reorderGoalTask(in goalTasks: [GoalTask]) -> Bool {
        guard syncOrders(for: goalTasks) else {
            return false
        }
        
        return true
    }
}

// MARK: - 获取目标任务
extension CDGoalTask {
    
    /// 排序键
    static var orderKey: String {
        return GoalTaskKey.order
    }
    
    // MARK: - 同步获取
    /// 同步获取所有目标任务
    static func getAllGoalTasks() -> [CDGoalTask]? {
        let results: [CDGoalTask]? = getAll(sortBy: orderKey,
                                            ascending: true,
                                            in: .defaultContext)
        return results
    }
    
    /// 同步获取所有未完成目标任务
    static func getActiveGoalTasks() -> [CDGoalTask]? {
        let predicate = activeGoalTaskPredicate
        let results: [CDGoalTask]? = getAll(matching: predicate,
                                            sortBy: orderKey,
                                            ascending: true,
                                            in: .defaultContext)
        return results
    }
    
    /// 未完成目标任务数目
    static func numberOfActiveGoalTasks() -> Int {
        let count = countOfEntries(with: activeGoalTaskPredicate, in: .defaultContext)
        return count
    }
    
    // MARK: - 异步获取
    /// 获取指定目标对应任务
    static func fetchGoalTasks(of goalPlan: GoalPlan,
                               completion: @escaping ([CDGoalTask]?) -> Void) {
        let predicate = taskPredicate(for: goalPlan, showCompleted: true)
        fetchAll(matching: predicate, sortBy: orderKey, ascending: true) { results in
            completion(results as? [CDGoalTask])
        }
    }
    
    
    
    
    
    /// 获取所有目标任务
    static func fetchAllGoalTasks(showCompleted: Bool = true,
                                  completion: @escaping ([CDGoalTask]?) -> Void) {
        let predicate = showCompleted ? nil : activeGoalTaskPredicate
        fetchAll(matching: predicate, sortBy: orderKey, ascending: true) { results in
            completion(results as? [CDGoalTask])
        }
    }
    
    /// 获取所有未完成目标任务
    static func fetchActiveGoalTasks(completion: @escaping ([CDGoalTask]?) -> Void) {
        fetchAll(matching: activeGoalTaskPredicate,
                 sortBy: orderKey,
                 ascending: true) { results in
            completion(results as? [CDGoalTask])
        }
    }
    
    /// 获取特定日期区间内需要展示的目标任务
    static func fetchCalendarEventGoalTasks(in range: DateInterval,
                                            completion: @escaping ([CDGoalTask]?) -> Void) {
        fetchAll(matching: activeGoalTaskPredicate(in: range),
                 sortBy: orderKey,
                 ascending: true) { results in
            completion(results as? [CDGoalTask])
        }
    }
    
    /// 获取我的一天中特定日期区间内的目标任务
    static func fetchMyDayEventGoalTasks(in range: DateInterval,
                                         completion: @escaping ([CDGoalTask]?) -> Void) {
        fetchAll(matching: activeMyDayGoalTaskPredicate(in: range),
                 sortBy: orderKey,
                 ascending: true) { results in
            completion(results as? [CDGoalTask])
        }
    }
    
    /// 获取包含提醒的目标任务
    static func fetchNotifiableGoalTasks(completion: @escaping ([CDGoalTask]?) -> Void) {
        fetchAll(matching: notifiableGoalTaskPredicate,
                 sortBy: orderKey,
                 ascending: true) { results in
            completion(results as? [CDGoalTask])
        }
    }
    
    /// 获取特定区间内已完成的目标任务
    static func fetchCompletedGoalTasks(in range: DateInterval,
                                        completion: @escaping ([CDGoalTask]?) -> Void) {
        let conditions: [PredicateCondition] = [
            completedCondition,
            (GoalTaskKey.completionDate, .between(range.start, range.end))
        ]
        
        fetchAll(matching: conditions.andPredicate(),
                 sortBy: orderKey,
                 ascending: true) { results in
            completion(results as? [CDGoalTask])
        }
    }
    
    /// 搜索目标任务
    static func searchGoalTasks(containText text: String,
                                showCompleted: Bool = true,
                                completion: @escaping ([CDGoalTask]?) -> Void) {
        var conditions: [PredicateCondition] = []
        if !showCompleted {
            conditions.append(notCompletedCondition)
        }
        
        conditions.append((GoalTaskKey.name, .contains(text)))
        fetchAll(matching: conditions.andPredicate(),
                 sortBy: orderKey,
                 ascending: true) { results in
            completion(results as? [CDGoalTask])
        }
    }
}

// MARK: - 谓词
extension CDGoalTask {
    
    static func taskPredicate(for goalPlan: GoalPlan,
                              showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (GoalTaskKey.goalPlanIdentifier, .equal(goalPlan.identifier)),
        ]
        
        if !showCompleted {
            conditions.append(notCompletedCondition)
        }
        
        return conditions.andPredicate()
    }
    
    /// 所有未完成目标任务
    static var activeGoalTaskPredicate: NSPredicate {
        return NSPredicate.predicate(with: notCompletedCondition)
    }
    
    /// 特定日期区间内未完成的目标任务
    static func activeGoalTaskPredicate(in range: DateInterval) -> NSPredicate {
        return activeGoalTaskPredicate(in: range, isAddedToMyDay: nil)
    }
    
    /// 我的一天中特定日期区间内未完成的目标任务
    static func activeMyDayGoalTaskPredicate(in range: DateInterval) -> NSPredicate {
        return activeGoalTaskPredicate(in: range, isAddedToMyDay: true)
    }
    
    private static func activeGoalTaskPredicate(in range: DateInterval,
                                                isAddedToMyDay: Bool?) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            notCompletedCondition,
            (GoalTaskKey.startDate, .isNotEmpty),
            (GoalTaskKey.startDate, .lessThanOrEqual(range.end))
        ]
        
        if let isAddedToMyDay = isAddedToMyDay {
            conditions.append((GoalTaskKey.isAddedToMyDay, isAddedToMyDay ? .isTrue : .isFalse))
        }
        
        /// 结束日期为空或者在区间起始之后
        let emptyEndDateCondition: PredicateCondition = (GoalTaskKey.endDate, .isEmpty)
        let withEndDateConditions: [PredicateCondition] = [
            (GoalTaskKey.endDate, .isNotEmpty),
            (GoalTaskKey.endDate, .greaterThanOrEqual(range.start))
        ]
        
        let endDatePredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [
            NSPredicate.predicate(with: emptyEndDateCondition),
            withEndDateConditions.andPredicate()
        ])
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: [conditions.andPredicate(),
                                                                  endDatePredicate])
    }
    
    /// 包含提醒的目标任务
    static var notifiableGoalTaskPredicate: NSPredicate {
        let conditions: [PredicateCondition] = [
            notCompletedCondition,
            (GoalTaskKey.shouldRemind, .isTrue),
            (GoalTaskKey.reminderJSON, .isNotEmpty)
        ]
        
        return conditions.andPredicate()
    }
    
    static var completedCondition: PredicateCondition {
        return (GoalTaskKey.isCompleted, .isTrue)
    }
    
    static var notCompletedCondition: PredicateCondition {
        return (GoalTaskKey.isCompleted, .isFalse)
    }
}

extension Array where Element == CDGoalTask {
    
    /// 转换成目标任务模型数组
    var toGoalTasks: [GoalTask] {
        return self.map { GoalTask(content: $0) }
    }
}
