//
//  HabitRecord+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/5.
//

import Foundation
import CoreData

typealias HabitHourlyCheckinResults = [Int: Int]

extension CDHabitRecord {
    
    /// 记录所对应的日期
    var date: Date {
        if let date = Date.dateFromDayIntegerKey(day) {
            return date
        }
        
        return .now
    }
    
    /// 原因emoji字符
    var reasonEmoji: Character? {
        if let reason = reason, let emoji = reason.first {
            return emoji
        }
        
        return nil
    }
    
    /// 样本值数组
    var sampleValues: [HabitSample]? {
        guard let samples = samples?.allObjects as? [CDHabitSample] else {
            return nil
        }
        
        return samples.map { HabitSample(content: $0) }
    }
    
    /// 创建新记录
    static func newRecord(forTask task: HabitTask, onDate date: Date) -> CDHabitRecord {
        let record = CDHabitRecord.createEntity(in: .defaultContext)
        record.day = date.dayIntegerKey
        record.task = CDHabitTask.getTask(with: task.identifier)
        return record
    }
}

// MARK: - Predicate
struct HabitRecordKey {
    static let day     = "day"
    static let amount  = "amount"
    static let isFailed  = "isFailed"
    static let isSkipped = "isSkipped"
    static let taskIdentifier = "task.identifier"
}

extension CDHabitRecord {
    
    static func condition(forTasks tasks: [HabitTask]) -> PredicateCondition {
        return (HabitRecordKey.taskIdentifier, .belongsTo(tasks.identifiers))
    }
    
    static func condition(forTask task: HabitTask) -> PredicateCondition {
        return (HabitRecordKey.taskIdentifier, .equal(task.identifier))
    }

    static func condition(onDate date: Date) -> PredicateCondition {
        return (HabitRecordKey.day, .equal(date.dayIntegerKey))
    }

    static func condition(fromDate: Date, toDate: Date) -> PredicateCondition {
        let fromDay = fromDate.dayIntegerKey
        let toDay = toDate.dayIntegerKey
        return (HabitRecordKey.day, .between(fromDay, toDay))
    }
    
    static func condition(in dateRange: DateRange) -> PredicateCondition {
        let fromDay = dateRange.startDate?.dayIntegerKey ?? 0
        let toDay = dateRange.endDate?.dayIntegerKey ?? Int32.max
        return (HabitRecordKey.day, .between(fromDay, toDay))
    }
    
    static func condition(forPeriod period: HabitDatePeriod) -> PredicateCondition {
        return condition(in: period.dateRange)
    }
    
    static func condition(amountGreaterThanOrEqual amount: Int) -> PredicateCondition {
        return (HabitRecordKey.amount, .greaterThanOrEqual(amount))
    }

    // MARK: - Conditions
    static func conditions(forTasks tasks: [HabitTask],
                           onDate date: Date) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTasks: tasks),
            condition(onDate: date)
        ]
        
        return conditions
    }

    static func conditions(forTasks tasks: [HabitTask],
                           inPeriod period: HabitDatePeriod) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTasks: tasks),
            condition(forPeriod: period)
        ]
        
        return conditions
    }

    static func conditions(forTask task: HabitTask,
                           inPeriod period: HabitDatePeriod) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTask: task),
            condition(forPeriod: period)
        ]
        
        return conditions
    }
    
    static func conditions(forTask task: HabitTask,
                           onDate date: Date) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTask: task),
            condition(onDate: date)
        ]
        
        return conditions
    }
    
    static func conditions(forTask task: HabitTask?,
                           fromDate: Date,
                           toDate: Date) -> [PredicateCondition] {
        var conditions: [PredicateCondition] = [
            condition(fromDate: fromDate, toDate: toDate)
        ]
        
        if let task = task {
            conditions.append(condition(forTask: task))
        }
        
        return conditions
    }
    
    static func conditions(forTask task: HabitTask,
                           fromDate: Date,
                           toDate: Date,
                           amountGreaterThanOrEqual amount: Int) -> [PredicateCondition] {
        var conditions = conditions(forTask: task, fromDate: fromDate, toDate: toDate)
        conditions.append(condition(amountGreaterThanOrEqual: amount))
        return conditions
    }
    
    static func conditions(forTask task: HabitTask,
                           amountGreaterThanOrEqual amount: Int) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTask: task),
            condition(amountGreaterThanOrEqual: amount)
        ]
        
        return conditions
    }
}

// MARK: - 获取数据
extension CDHabitRecord {
    
    // MARK: - 同步获取记录
    static func getRecord(for task: HabitTask, on date: Date) -> CDHabitRecord? {
        return getRecord(for: task, on: date, createIfNil: false)
    }
    
    static func getRecord(for task: HabitTask, on date: Date, createIfNil: Bool) -> CDHabitRecord? {
        let conditions = CDHabitRecord.conditions(forTask: task, onDate: date)
        let predicate = conditions.andPredicate()
        if let record = CDHabitRecord.getFirst(matching: predicate, in: .defaultContext) {
            return record
        }
        
        if createIfNil {
            return CDHabitRecord.newRecord(forTask: task, onDate: date)
        }
        
        return nil
    }
    
    static func getRecords(for task: HabitTask?, fromDate: Date, toDate: Date) -> [CDHabitRecord]? {
        let conditions = CDHabitRecord.conditions(forTask: task, fromDate: fromDate, toDate: toDate)
        let predicate = conditions.andPredicate()
        return CDHabitRecord.getAll(matching: predicate, in: .defaultContext)
    }
    
    // MARK: - 异步获取
    static func fetchDailyItemsGroupedByDay(in dateRange: DateRange,
                                            includeSamples: Bool = false,
                                            completion: @escaping (HabitGroupedDailyItems?) -> Void) {
        let condition = condition(in: dateRange)
        let predicate = NSPredicate.predicate(with: condition)
        fetchAll(matching: predicate) { results in
            let cdRecords = results as? [CDHabitRecord]
            let items = groupedDailyItems(with: cdRecords, includeSamples: includeSamples)
            completion(items)
        }
    }
    
    static func fetchRecord(for task: HabitTask,
                            on date: Date,
                            completion: @escaping (CDHabitRecord?) -> Void) {
        let conditions = conditions(forTask: task, onDate: date)
        let predicate = conditions.andPredicate()
        fetchFirst(matching: predicate) { result in
            completion(result as? CDHabitRecord)
        }
    }
    
    static func fetchRecords(for tasks: [HabitTask],
                             onDate date: Date,
                             completion: @escaping([CDHabitRecord]?) -> Void) {
        let conditions = CDHabitRecord.conditions(forTasks: tasks, onDate: date)
        let predicate = conditions.andPredicate()
        CDHabitRecord.fetchAll(matching: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }

    /// 获取指定日期范围内所有记录
    static func fetchRecords(for task: HabitTask,
                             in range: DateRange,
                             completion: @escaping([CDHabitRecord]?) -> Void) {
        guard let fromDate = range.startDate, let toDate = range.endDate else {
            completion(nil)
            return
        }
        
        fetchRecords(for: task,
                     fromDate: fromDate,
                     toDate: toDate,
                     completion: completion)
    }
    
    static func fetchRecords(for task: HabitTask,
                             fromDate: Date,
                             toDate: Date,
                             completion: @escaping([CDHabitRecord]?) -> Void) {
        let conditions = CDHabitRecord.conditions(forTask: task,
                                                  fromDate: fromDate,
                                                  toDate: toDate)
        let predicate = conditions.andPredicate()
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
    
    
    // MARK: -
    /// 删除对应任务在周期内所有记录
    static func deleteRecords(for task: HabitTask, within period: HabitDatePeriod) -> Bool {
        let dateRange = period.dateRange
        guard let fromDate = dateRange.startDate, let toDate = dateRange.endDate else {
            return false
        }

        return deleteRecords(for: task, fromDate: fromDate, toDate: toDate)
    }
    
    /// 删除对应任务从fromDate到toDate之间所有记录
    static func deleteRecords(for task: HabitTask?, fromDate: Date, toDate: Date)  -> Bool {
        guard let records = getRecords(for: task, fromDate: fromDate, toDate: toDate), records.count > 0 else {
            return false
        }
        
        NSManagedObjectContext.defaultContext.deleteObjects(records)
        return true
    }
    
}
