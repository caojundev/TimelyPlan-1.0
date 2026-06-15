//
//  Habit.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import CoreData

struct HabitUpdaterOption: OptionSet {
    
    let rawValue: Int
    
    /// 任务
    static let task = HabitUpdaterOption(rawValue: 1 << 1)
    
    /// 记录
    static let record = HabitUpdaterOption(rawValue: 2 << 1)
    
    /// 所有
    static let all: HabitUpdaterOption = [.task, .record]
}

final class HabitRepository {

    // MARK: - Singleton

    static let shared = HabitRepository()

    private init() {}

    // MARK: - Internal Dependencies

    private let taskManager = HabitTaskManager()
    private let periodItemFetcher = HabitPeriodItemFetcher()
    private let recordProcessor = HabitRecordProcessor()

    // MARK: Updater

    static func addUpdater(_ updater: AnyObject, for option: HabitUpdaterOption = .all) {
        if option.contains(.task) {
            shared.taskManager.updater.addDelegate(updater)
        }
        if option.contains(.record) {
            shared.recordProcessor.updater.addDelegate(updater)
        }
    }

    // MARK: Period Items

    static func fetchScheduledPeriodItems(
        on date: Date = .now,
        includeSamples: Bool = false,
        completion: @escaping ([HabitPeriodItem]?) -> Void
    ) {
        let activeTasks = shared.taskManager.getActiveTasks()
        shared.periodItemFetcher.fetchScheduledPeriodItems(
            for: activeTasks,
            on: date,
            includeSamples: includeSamples,
            completion: completion
        )
    }

    static func fetchScheduledPeriodItems(
        in period: HabitDatePeriod,
        includeSamples: Bool = false,
        completion: @escaping ([HabitPeriodItem]) -> Void
    ) {
        let activeTasks = shared.taskManager.getActiveTasks()
        shared.periodItemFetcher.fetchScheduledPeriodItems(
            for: activeTasks,
            in: period,
            includeSamples: includeSamples,
            completion: completion
        )
    }

    static func fetchPeriodItems(
        in period: HabitDatePeriod,
        includeSamples: Bool = false,
        completion: @escaping ([HabitPeriodItem]) -> Void
    ) {
        let activeTasks = shared.taskManager.getActiveTasks()
        shared.periodItemFetcher.fetchPeriodItems(
            for: activeTasks,
            in: period,
            includeSamples: includeSamples,
            completion: completion
        )
    }

    static func fetchPeriodItem(
        for task: HabitTask,
        in period: HabitDatePeriod,
        includeSamples: Bool = false,
        completion: @escaping (HabitPeriodItem) -> Void
    ) {
        shared.periodItemFetcher.fetchPeriodItem(
            for: task,
            in: period,
            includeSamples: includeSamples,
            completion: completion
        )
    }
    
    static func fetchReportPeriodItems(
        in period: HabitDatePeriod,
        includeArchived: Bool,
        includeSamples: Bool = false,
        completion: @escaping ([HabitPeriodItem]) -> Void
    ) {
        let tasks: [HabitTask] = includeArchived
        ? shared.taskManager.getAllTasks()
        : shared.taskManager.getActiveTasks()

        shared.periodItemFetcher.fetchScheduledPeriodItems(
            for: tasks,
            in: period,
            includeSamples: includeSamples,
            completion: completion
        )
    }

    // MARK: Task Queries

    static func searchActiveTasks(containText text: String, completion: @escaping ([HabitTask]?) -> Void) {
        shared.taskManager.searchActiveTasks(containText: text,
                                             completion: completion)
    }

    static func fetchActiveTasks(completion: @escaping ([HabitTask]?) -> Void) {
        shared.taskManager.fetchActiveTasks(completion: completion)
    }

    static func fetchArchivedTasks(completion: @escaping ([HabitTask]?) -> Void) {
        shared.taskManager.fetchArchivedTasks(completion: completion)
    }

    static func activeTasks() -> [HabitTask] {
        shared.taskManager.getActiveTasks()
    }

    static var hasArchivedTask: Bool {
        return archivedTasksCount() != 0
    }

    static func archivedTasks() -> [HabitTask] {
        shared.taskManager.getArchivedTasks()
    }

    static func archivedTasksCount() -> Int {
        shared.taskManager.getArchivedTasksCount()
    }

    // MARK: Task Mutations

    static func createTask(with editingTask: HabitEditingTask) {
        shared.taskManager.createTask(with: editingTask)
    }

    static func updateTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        shared.taskManager.updateTask(task, with: editingTask)
    }

    static func deleteTask(_ task: HabitTask) {
        shared.taskManager.deleteTask(task)
    }

    static func reorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        shared.taskManager.reorderTask(in: tasks, fromIndex: fromIndex, toIndex: toIndex)
    }

    static func setArchived(_ isArchived: Bool, for task: HabitTask) {
        shared.taskManager.setArchived(isArchived, for: task)
    }
}

// MARK: - 记录处理
typealias HabitGroupedDailyItems = [Int32: [HabitDailyItem]]

extension HabitRepository {

    static func fetchDailyItemsGroupedByDay(in dateRange: DateRange,
                                            includeSamples: Bool = false,
                                            completion: @escaping (HabitGroupedDailyItems?) -> Void) {
        fetchRecords(in: dateRange) { results in
            let items = groupedDailyItems(with: results, includeSamples: includeSamples)
            completion(items)
        }
    }
    
    static func fetchRecords(for tasks: [HabitTask],
                             in period: HabitDatePeriod,
                             completion: @escaping([CDHabitRecord]?)->Void) {
        let conditions: [PredicateCondition]
        if period.mode == .day {
            conditions = CDHabitRecord.conditions(forTasks: tasks, onDate: period.date)
        } else {
            conditions = CDHabitRecord.conditions(forTasks: tasks, inPeriod: period)
        }
        
        let predicate = conditions.andPredicate()
        CDHabitRecord.findAll(with: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }
    
    static func fetchRecords(in dateRange: DateRange,
                             completion: @escaping([CDHabitRecord]?)->Void) {
        let condition = CDHabitRecord.condition(in: dateRange)
        let predicate = NSPredicate.predicate(with: condition)
        CDHabitRecord.findAll(with: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }
    
    static func fetchRecords(in period: HabitDatePeriod,
                             completion: @escaping([CDHabitRecord]?)->Void) {
        let condition: PredicateCondition
        if period.mode == .day {
            condition = CDHabitRecord.condition(onDate: period.date)
        } else {
            condition = CDHabitRecord.condition(in: period.dateRange)
        }
        
        let predicate = NSPredicate.predicate(with: condition)
        CDHabitRecord.findAll(with: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }
    
    private static func groupedDailyItems(with results: [CDHabitRecord]?,
                                          includeSamples: Bool) -> HabitGroupedDailyItems? {
        guard let results = results else {
            return nil
        }
        
        var groupedDailyItems = HabitGroupedDailyItems()
        for result in results {
            guard let taskContent = result.task else {
                continue
            }
            
            let record = HabitRecord(content: result, includeSamples: includeSamples)
            let task = HabitTask(content: taskContent)
            let item = HabitDailyItem(record: record, task: task)
            
            let key = result.day
            var dayItems = groupedDailyItems[key] ?? []
            dayItems.append(item)
            groupedDailyItems[key] = dayItems
        }
        
        return groupedDailyItems
    }
    
    // MARK: Record Mutations

    /// 完成所有
    static func completeAll(for task: HabitTask, on date: Date) {
        shared.recordProcessor.completeAll(for: task, on: date)
    }

    static func updateRecord(
        amount: Int64,
        inputType: HabitRecordInputType,
        for task: HabitTask,
        on date: Date
    ) {
        shared.recordProcessor.updateRecord(amount: amount, inputType: inputType, for: task, on: date)
    }

    /// 添加或更改备注
    static func addLog(_ logInfo: HabitRecordLogInfo?, for task: HabitTask, on date: Date) {
        shared.recordProcessor.addLog(logInfo, for: task, on: date)
    }

    /// 跳过今天
    static func skip(with tag: ReasonTag, for task: HabitTask, on date: Date) {
        shared.recordProcessor.skip(with: tag, for: task, on: date)
    }

    /// 取消跳过
    static func cancelSkip(for task: HabitTask, on date: Date) {
        shared.recordProcessor.cancelSkip(for: task, on: date)
    }

    /// 标记为失败
    static func markAsFail(with tag: ReasonTag, for task: HabitTask, on date: Date) {
        shared.recordProcessor.markAsFail(with: tag, for: task, on: date)
    }

    /// 取消失败
    static func cancelFail(for task: HabitTask, on date: Date) {
        shared.recordProcessor.cancelFail(for: task, on: date)
    }

    /// 重置今日
    static func resetToday(of date: Date, for task: HabitTask) {
        shared.recordProcessor.resetToday(of: date, for: task)
    }

    static func deleteRecords(in dateRange: DateRange) {
        shared.recordProcessor.deleteRecords(in: dateRange)
    }
}
