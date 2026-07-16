//
//  HabitRepository.swift
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

    private static let taskManager = HabitTaskManager()
    private static let periodItemFetcher = HabitPeriodItemFetcher()
    private static let recordProcessor = HabitRecordProcessor()

    // MARK: - 注册远程数据变更
    private static var isRemoteChangeObserved = false
    private static func observeRemoteChangeIfNeeded() {
        if isRemoteChangeObserved {
            return
        }
        
        isRemoteChangeObserved = true
        HandyRecord.observeRemoteChange { changeInfo in
            let entityNames = changeInfo.entityNames
            if entityNames.contains(.habitTask) {
                taskManager.updater.didChangeRemoteHabitTask(with: changeInfo.extractHabitTask())
            }

            if entityNames.contains(.habitRecord) {
                recordProcessor.updater.didChangeRemoteHabitRecord(with: changeInfo.extractHabitRecord())
            }
        }
    }
    
    // MARK: - 添加处理更新器
    /// 添加更新器代理对象
    static func addUpdater(_ updater: AnyObject, for option: HabitUpdaterOption = .all) {
        observeRemoteChangeIfNeeded()
        if option.contains(.task) {
            taskManager.updater.addDelegate(updater)
        }
        
        if option.contains(.record) {
            recordProcessor.updater.addDelegate(updater)
        }
    }

    // MARK: Period Items
    static func fetchNotifiablePeriodItems(completion: @escaping ([HabitPeriodItem]) -> Void) {
        taskManager.fetchNotifiableTasks { tasks in
            guard let tasks = tasks else {
                completion([])
                return
            }
            
            let period = HabitDatePeriod(date: .now, mode: .day)
            periodItemFetcher.fetchPeriodItems(
                for: tasks,
                in: period,
                includeSamples: false,
                completion: completion)
        }
    }
    
    static func fetchScheduledPeriodItems(
        on date: Date = .now,
        includeSamples: Bool = false,
        completion: @escaping ([HabitPeriodItem]?) -> Void
    ) {
        let activeTasks = taskManager.getActiveTasks()
        periodItemFetcher.fetchScheduledPeriodItems(
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
        let activeTasks = taskManager.getActiveTasks()
        periodItemFetcher.fetchScheduledPeriodItems(
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
        let activeTasks = taskManager.getActiveTasks()
        periodItemFetcher.fetchPeriodItems(
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
        periodItemFetcher.fetchPeriodItem(
            for: task,
            in: period,
            includeSamples: includeSamples,
            completion: completion
        )
    }
    
    static func fetchPeriodItem(for taskIdentifier: String,
                                on date: Date,
                                completion: @escaping (HabitPeriodItem?) -> Void
    ) {
        guard let task = taskManager.getTask(with: taskIdentifier) else {
            completion(nil)
            return
        }
        
        let period = HabitDatePeriod(date: date, mode: .day)
        periodItemFetcher.fetchPeriodItem(
            for: task,
            in: period,
            includeSamples: false,
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
        ? taskManager.getAllTasks()
        : taskManager.getActiveTasks()

        periodItemFetcher.fetchScheduledPeriodItems(
            for: tasks,
            in: period,
            includeSamples: includeSamples,
            completion: completion
        )
    }

    // MARK: Task Queries
    /// 获取日历事项任务
    static func fetchCalendarEventTasks(in range: DateInterval,
                                        completion: @escaping([HabitTask]?) -> Void) {
        taskManager.fetchCalendarEventTasks(in: range, completion: completion)
    }
    
    /// 获取我的一天事项任务
    static func fetchMyDayEventTasks(in range: DateInterval,
                                     completion: @escaping([HabitTask]?) -> Void) {
        taskManager.fetchMyDayEventTasks(in: range, completion: completion)
    }

    static func searchActiveTasks(containText text: String, completion: @escaping ([HabitTask]?) -> Void) {
        taskManager.searchActiveTasks(containText: text,
                                             completion: completion)
    }

    static func fetchActiveTasks(completion: @escaping ([HabitTask]?) -> Void) {
        taskManager.fetchActiveTasks(completion: completion)
    }

    static func fetchArchivedTasks(completion: @escaping ([HabitTask]?) -> Void) {
        taskManager.fetchArchivedTasks(completion: completion)
    }

    static func activeTasks() -> [HabitTask] {
        taskManager.getActiveTasks()
    }

    static var hasArchivedTask: Bool {
        return archivedTasksCount() != 0
    }

    static func archivedTasks() -> [HabitTask] {
        taskManager.getArchivedTasks()
    }

    static func archivedTasksCount() -> Int {
        taskManager.getArchivedTasksCount()
    }

    // MARK: Task Mutations

    static func createTask(with editingTask: HabitEditingTask) {
        taskManager.createTask(with: editingTask)
    }

    static func updateTask(_ task: HabitTask, with editingTask: HabitEditingTask) {
        taskManager.updateTask(task, with: editingTask)
    }

    static func deleteTask(_ task: HabitTask) {
        taskManager.deleteTask(task)
    }

    static func reorderTask(in tasks: [HabitTask], fromIndex: Int, toIndex: Int) {
        taskManager.reorderTask(in: tasks, fromIndex: fromIndex, toIndex: toIndex)
    }

    static func setArchived(_ isArchived: Bool, for task: HabitTask) {
        taskManager.setArchived(isArchived, for: task)
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
        CDHabitRecord.fetchAll(matching: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }
    
    static func fetchRecords(in dateRange: DateRange,
                             completion: @escaping([CDHabitRecord]?)->Void) {
        let condition = CDHabitRecord.condition(in: dateRange)
        let predicate = NSPredicate.predicate(with: condition)
        CDHabitRecord.fetchAll(matching: predicate) { results in
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
        CDHabitRecord.fetchAll(matching: predicate) { results in
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
            guard let task = HabitTask(content: taskContent) else {
                continue
            }
            
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
        recordProcessor.completeAll(for: task, on: date)
    }

    static func updateRecord(
        amount: Int64,
        inputType: HabitRecordInputType,
        for task: HabitTask,
        on date: Date
    ) {
        recordProcessor.updateRecord(amount: amount, inputType: inputType, for: task, on: date)
    }

    /// 添加或更改备注
    static func addLog(_ logInfo: HabitRecordLogInfo?, for task: HabitTask, on date: Date) {
        recordProcessor.addLog(logInfo, for: task, on: date)
    }

    /// 跳过今天
    static func skip(with tag: ReasonTag, for task: HabitTask, on date: Date) {
        recordProcessor.skip(with: tag, for: task, on: date)
    }

    /// 取消跳过
    static func cancelSkip(for task: HabitTask, on date: Date) {
        recordProcessor.cancelSkip(for: task, on: date)
    }

    /// 标记为失败
    static func markAsFail(with tag: ReasonTag, for task: HabitTask, on date: Date) {
        recordProcessor.markAsFail(with: tag, for: task, on: date)
    }

    /// 取消失败
    static func cancelFail(for task: HabitTask, on date: Date) {
        recordProcessor.cancelFail(for: task, on: date)
    }

    /// 重置今日
    static func resetToday(of date: Date, for task: HabitTask) {
        recordProcessor.resetToday(of: date, for: task)
    }

    static func deleteRecords(in dateRange: DateRange) {
        recordProcessor.deleteRecords(in: dateRange)
    }
}
