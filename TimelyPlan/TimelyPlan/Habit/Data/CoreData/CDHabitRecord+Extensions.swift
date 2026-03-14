//
//  HabitRecord+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/5.
//

import Foundation

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
    
    /// 创建新记录
    static func newRecord(forTask task: CDHabitTask, onDate date: Date) -> CDHabitRecord {
        let record = CDHabitRecord.createEntity(in: .defaultContext)
        record.day = date.dayIntegerKey
        record.task = task
        return record
    }
    
    /// 获取样本的时间偏移
    var sampleTimeOffsets: Set<Duration>? {
        guard let samples = samples?.allObjects as? [CDHabitSample] else {
            return nil
        }
        
        var offsets = Set<Duration>()
        for sample in samples {
            guard let date = sample.date else {
                continue
            }
            
            offsets.insert(date.offset())
        }
     
        if offsets.count > 0 {
            return offsets
        }
        
        return nil
    }

}

// MARK: - Predicate
struct HabitRecordKey {
    static let task    = "task"
    static let day     = "day"
    static let amount  = "amount"
    static let isFailed  = "isFailed"
    static let isSkipped = "isSkipped"
}

extension CDHabitRecord {
    
    static func condition(forTasks tasks: [CDHabitTask]) -> PredicateCondition {
        return (HabitRecordKey.task, .belongsTo(tasks))
    }
    
    static func condition(forTask task: CDHabitTask) -> PredicateCondition {
        return (HabitRecordKey.task, .equal(task))
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
        let tasks = tasks.map { return $0.content }
        return conditions(forTasks: tasks, onDate: date)
    }
    
    static func conditions(forTasks tasks: [CDHabitTask],
                           onDate date: Date) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTasks: tasks),
            condition(onDate: date)
        ]
        
        return conditions
    }
    
    static func conditions(forTasks tasks: [HabitTask],
                           inPeriod period: HabitDatePeriod) -> [PredicateCondition] {
        let tasks = tasks.map { return $0.content }
        return conditions(forTasks: tasks, inPeriod: period)
    }
    
    static func conditions(forTasks tasks: [CDHabitTask],
                           inPeriod period: HabitDatePeriod) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTasks: tasks),
            condition(forPeriod: period)
        ]
        
        return conditions
    }
    
    static func conditions(forTask task: HabitTask,
                           inPeriod period: HabitDatePeriod) -> [PredicateCondition] {
        return conditions(forTask: task.content, inPeriod: period)
    }
    
    static func conditions(forTask task: CDHabitTask,
                           inPeriod period: HabitDatePeriod) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTask: task),
            condition(forPeriod: period)
        ]
        
        return conditions
    }
    
    static func conditions(forTask task: CDHabitTask,
                           onDate date: Date) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTask: task),
            condition(onDate: date)
        ]
        
        return conditions
    }
    
    static func conditions(forTask task: CDHabitTask,
                           fromDate: Date,
                           toDate: Date) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTask: task),
            condition(fromDate: fromDate, toDate: toDate)
        ]
        
        return conditions
    }
    
    static func conditions(forTask task: CDHabitTask,
                           fromDate: Date,
                           toDate: Date,
                           amountGreaterThanOrEqual amount: Int) -> [PredicateCondition] {
        var conditions = conditions(forTask: task, fromDate: fromDate, toDate: toDate)
        conditions.append(condition(amountGreaterThanOrEqual: amount))
        return conditions
    }
    
    static func conditions(forTask task: CDHabitTask,
                           amountGreaterThanOrEqual amount: Int) -> [PredicateCondition] {
        let conditions: [PredicateCondition] = [
            condition(forTask: task),
            condition(amountGreaterThanOrEqual: amount)
        ]
        
        return conditions
    }
}
