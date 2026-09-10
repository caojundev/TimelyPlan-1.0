//
//  GoalRecordManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/7.
//

import Foundation
import CoreData

/// 目标记录管理器：负责目标记录的创建、获取与删除，
/// 并在「记录进度」时协同 `GoalTaskManager` 更新目标任务当前数值。
class GoalRecordManager {
    
    /// 目标记录处理更新器
    let updater = GoalRecordProcessorUpdater()
    
    /// 目标任务管理器（记录进度时需要更新当前数值）
    let taskManager: GoalTaskManager
    
    /// 目标计划更新器（记录变化后刷新目标整体进度时使用）
    var planUpdater: GoalPlanProcessorUpdater?
    
    /// 默认上下文对象
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    init(taskManager: GoalTaskManager = GoalTaskManager()) {
        self.taskManager = taskManager
    }
    
    // MARK: - 添加记录
    
    /// 添加一条记录（仅记录，不会更新目标任务的当前数值）
    /// - Parameters:
    ///   - amount: 记录数目（本次记录的数值变化量）
    ///   - note: 备注
    ///   - goalTask: 目标任务
    ///   - date: 记录日期
    @discardableResult
    func addRecord(amount: Int64,
                   note: String? = nil,
                   for goalTask: GoalTask,
                   on date: Date = .now) -> GoalRecord? {
        guard let content = CDGoalRecord.addRecord(amount: amount,
                                                   date: date,
                                                   note: note,
                                                   for: goalTask) else {
            return nil
        }
        
        let record = GoalRecord(content: content)
        updater.didCreateGoalRecord(record, for: goalTask)
        HandyRecord.updateChangeCount()
        
        /// 添加记录后刷新目标整体进度（记录通常伴随进度变化）
        refreshGoalPlanProgress(for: goalTask)
        return record
    }
    
    /// 记录进度：更新目标任务当前数值并添加一条记录
    /// - Parameters:
    ///   - amount: 输入的数值
    ///   - inputType: 记录输入类型
    ///   - note: 备注
    ///   - goalTask: 目标任务
    ///   - date: 记录日期
    func record(amount: Int64,
                inputType: GoalRecordInputType,
                note: String? = nil,
                for goalTask: GoalTask,
                on date: Date = .now) {
        let oldValue = goalTask.currentValue
        let newValue = currentValue(byEntering: amount, inputType: inputType, for: goalTask)
        
        /// 先更新进度，达到目标数值时会自动完成
        taskManager.updateGoalTask(goalTask, currentValue: newValue)
        
        /// 记录数目为本次实际的数值变化量
        addRecord(amount: newValue - oldValue, note: note, for: goalTask, on: date)
    }
    
    /// 完成所有：把目标任务进度推进到目标值（100%），并按本次实际变化量创建一条记录
    /// - Parameters:
    ///   - goalTask: 目标任务
    ///   - date: 记录日期
    func completeAll(for goalTask: GoalTask,
                     on date: Date = .now) {
        /// 无有效进度区间（开始值 == 目标值）的任务：无法按数值记录进度，直接标记完成
        guard goalTask.isValidProgress else {
            taskManager.updateGoalTask(goalTask, isCompleted: true)
            return
        }
        
        let oldValue = goalTask.currentValue
        let targetValue = goalTask.targetValue
        if oldValue == targetValue && goalTask.isCompleted {
            /// 已按目标值完成，无需处理
            return
        }
        
        /// 将当前值推进到目标值；达到 100% 时目标任务管理器会自动标记完成
        taskManager.updateGoalTask(goalTask, currentValue: targetValue)
        
        /// 记录本次补齐的实际数值变化量（可能为负，对应递减型目标）
        let difference = targetValue - oldValue
        if difference != 0 {
            addRecord(amount: difference, for: goalTask, on: date)
        }
    }
    
    /// 根据输入数值与输入类型计算目标任务的最新当前数值
    private func currentValue(byEntering inputValue: Int64,
                              inputType: GoalRecordInputType,
                              for goalTask: GoalTask) -> Int64 {
        switch inputType {
        case .increase:
            return goalTask.currentValue(byIncrementing: inputValue)
        case .decrease:
            return goalTask.currentValue(byIncrementing: -inputValue)
        case .update:
            return goalTask.validatedCurrentValue(inputValue)
        }
    }
    
    // MARK: - 获取
    
    /// 同步获取目标记录
    func getRecords(for goalTask: GoalTask? = nil,
                    fromDate: Date? = nil,
                    toDate: Date? = nil) -> [GoalRecord] {
        return CDGoalRecord.getRecords(for: goalTask,
                                       fromDate: fromDate,
                                       toDate: toDate)?.toGoalRecords ?? []
    }
    
    /// 异步获取目标记录
    func fetchRecords(for goalTask: GoalTask? = nil,
                      fromDate: Date? = nil,
                      toDate: Date? = nil,
                      completion: @escaping ([GoalRecord]?) -> Void) {
        CDGoalRecord.fetchRecords(for: goalTask,
                                  fromDate: fromDate,
                                  toDate: toDate) { contents in
            completion(contents?.toGoalRecords)
        }
    }
    
    // MARK: - 删除
    
    /// 删除目标任务在指定日期区间内的记录（日期区间为 nil 表示不限制）
    @discardableResult
    func deleteRecords(for goalTask: GoalTask? = nil,
                       fromDate: Date? = nil,
                       toDate: Date? = nil) -> Bool {
        guard CDGoalRecord.deleteRecords(for: goalTask,
                                         fromDate: fromDate,
                                         toDate: toDate) else {
            return false
        }
        
        var dateRange: DateRange? = nil
        if fromDate != nil || toDate != nil {
            dateRange = DateRange(startDate: fromDate, endDate: toDate)
        }
        
        updater.didDeleteGoalRecords(for: goalTask, in: dateRange)
        HandyRecord.updateChangeCount()
        
        /// 删除指定任务的记录后，根据剩余记录重算任务当前值并刷新所属目标整体进度
        if let goalTask = goalTask {
            recomputeGoalTaskCurrentValue(for: goalTask)
            refreshGoalPlanProgress(for: goalTask)
        }
        
        return true
    }
    
    /// 删除单条目标记录
    /// - Parameters:
    ///   - record: 目标记录（需持有稳定标识）
    ///   - goalTask: 记录所属目标任务
    @discardableResult
    func deleteRecord(_ record: GoalRecord,
                      for goalTask: GoalTask) -> Bool {
        guard CDGoalRecord.deleteRecord(withIdentifier: record.identifier) else {
            return false
        }
        
        let dateRange = record.date.map { DateRange(startDate: $0.startOfDay(), endDate: $0.endOfDay()) }
        updater.didDeleteGoalRecords(for: goalTask, in: dateRange)
        HandyRecord.updateChangeCount()
        
        /// 删除后根据剩余记录重算任务当前值，并刷新任务所属目标整体进度
        recomputeGoalTaskCurrentValue(for: goalTask)
        refreshGoalPlanProgress(for: goalTask)
        return true
    }
    
    // MARK: - 更新
    
    /// 更新单条目标记录的数值与备注
    /// - Parameters:
    ///   - record: 目标记录（需持有稳定标识）
    ///   - amount: 新的数值（记录的变化量，增加型为正、减少型为负）
    ///   - note: 新的备注（传 nil 表示清空）
    ///   - goalTask: 记录所属目标任务
    @discardableResult
    func updateRecord(_ record: GoalRecord,
                      amount: Int64,
                      note: String?,
                      for goalTask: GoalTask) -> Bool {
        guard let content = CDGoalRecord.getRecord(withIdentifier: record.identifier) else {
            return false
        }
        
        let oldAmount = content.amount
        let oldNote = content.note
        let amountChanged = amount != oldAmount
        let noteChanged = note != oldNote
        
        /// 无任何变化时直接返回
        guard amountChanged || noteChanged else {
            return true
        }
        
        if amountChanged {
            content.amount = amount
        }
        content.note = note
        
        let updatedModel = GoalRecord(content: content)
        
        /// 通知记录变化（数值变化优先，二者同时变化时以数值为准）
        if amountChanged {
            updater.didUpdateGoalRecord(updatedModel,
                                        for: goalTask,
                                        with: .amountChanged(oldValue: oldAmount, newValue: amount))
        } else if noteChanged {
            updater.didUpdateGoalRecord(updatedModel,
                                        for: goalTask,
                                        with: .noteChanged(oldValue: oldNote, newValue: note))
        }
        HandyRecord.updateChangeCount()
        
        /// 数值变化后重算任务当前值，并刷新所属目标整体进度
        if amountChanged {
            recomputeGoalTaskCurrentValue(for: goalTask)
        }
        refreshGoalPlanProgress(for: goalTask)
        return true
    }
    
    // MARK: - 任务当前值重算
    
    /// 记录增删改后，根据目标任务当前所有记录的数值变化量重算其当前值。
    ///
    /// 由于每条记录保存的是「本次进度变化量」，因此
    /// `当前值 = 初始值 + 记录变化量之和`，并按合法区间夹取后写回任务。
    private func recomputeGoalTaskCurrentValue(for goalTask: GoalTask) {
        guard let taskContent = CDGoalTask.getGoalTask(withIdentifier: goalTask.identifier) else {
            return
        }
        
        let initialValue = taskContent.initialValue
        let targetValue = taskContent.targetValue
        
        /// 剩余记录变化量之和
        let remainingRecords = CDGoalRecord.getRecords(for: goalTask) ?? []
        let totalDelta = remainingRecords.reduce(Int64(0)) { $0 + $1.amount }
        
        let rawValue = initialValue + totalDelta
        let value = GoalTask.validatedCurrentValue(rawValue,
                                                   initialValue: initialValue,
                                                   targetValue: targetValue)
        
        /// 写回任务当前值（内部会触发进度更新与自动完成判定）
        taskManager.updateGoalTask(goalTask, currentValue: value)
    }
    
    // MARK: - 重置今日
    /// 重置指定日期：删除目标任务在该日期的所有记录，并按记录净变化回退任务当前值
    /// - Parameters:
    ///   - goalTask: 目标任务
    ///   - date: 需要重置的日期
    /// - Returns: 是否有记录被重置
    @discardableResult
    func resetToday(for goalTask: GoalTask,
                    on date: Date = .now) -> Bool {
        let fromDate = date.startOfDay()
        let toDate = date.endOfDay()
        guard let records = CDGoalRecord.getRecords(for: goalTask,
                                                    fromDate: fromDate,
                                                    toDate: toDate),
              records.count > 0 else {
            return false
        }
        
        /// 该日期记录的净变化量（回退当前值用）
        let netChange = records.reduce(0) { $0 + $1.amount }
        
        /// 删除该日期全部记录
        guard CDGoalRecord.deleteRecords(records) else {
            return false
        }
        
        updater.didDeleteGoalRecords(for: goalTask, in: DateRange(startDate: fromDate, endDate: toDate))
        HandyRecord.updateChangeCount()
        
        /// 回退目标任务当前值（使今日进度归零），并刷新所属目标整体进度
        taskManager.updateGoalTask(goalTask, currentValue: goalTask.currentValue(byIncrementing: -netChange))
        refreshGoalPlanProgress(for: goalTask)
        
        return true
    }
    
    // MARK: - 目标进度刷新
    /// 刷新目标任务所属目标的整体进度，进度变化时通知更新器
    private func refreshGoalPlanProgress(for goalTask: GoalTask) {
        guard let taskContent = CDGoalTask.getGoalTask(withIdentifier: goalTask.identifier),
              let planContent = taskContent.goalPlan else {
            return
        }
        
        guard planContent.updateProgress() else {
            return
        }
        
        planUpdater?.didUpdateGoalPlan(GoalPlan(content: planContent))
        HandyRecord.updateChangeCount()
    }
}
