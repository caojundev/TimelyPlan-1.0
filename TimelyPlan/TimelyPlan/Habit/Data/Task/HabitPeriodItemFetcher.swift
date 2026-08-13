//
//  HabitPeriodItemFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation
import CoreData

class HabitPeriodItemFetcher {
    
    private let scheduler = TaskTimePlanRegularScheduler()
    
    func fetchPeriodItems(for tasks: [HabitTask],
                          in period: HabitDatePeriod,
                          includeSamples: Bool,
                          completion: @escaping([HabitPeriodItem])->Void) {
        let conditions: [PredicateCondition]
        if period.mode == .day {
            conditions = CDHabitRecord.conditions(forTasks: tasks, onDate: period.date)
        } else {
            conditions = CDHabitRecord.conditions(forTasks: tasks, inPeriod: period)
        }
        
        let predicate = conditions.andPredicate()
        CDHabitRecord.fetchAll(matching: predicate) { results in
            let groupedRecords = self.recordsGroupedByTask(with: results as? [CDHabitRecord],
                                                           includeSamples: includeSamples)
            var periodItems: [HabitPeriodItem] = []
            for task in tasks {
                let item = HabitPeriodItem(habitTask: task, period: period)
                item.records = groupedRecords?[task.identifier]
                periodItems.append(item)
            }
            
            completion(periodItems)
        }
    }
    
    func fetchScheduledPeriodItems(for tasks: [HabitTask],
                                   in period: HabitDatePeriod,
                                   includeSamples: Bool,
                                   completion: @escaping([HabitPeriodItem])->Void) {
        var scheduledTasks: [HabitTask] = []
        for task in tasks {
            /// 任务时间范围与时间段有重叠
            guard task.dateRange.intersects(with: period.dateRange) else {
                continue
            }
            
            let hasScheduledDate = !period.enumerateDates { date in
                let isScheduled = scheduler.isScheduledDate(date,
                                                            withRule: task.timePlan.regularRule,
                                                            dateRange: task.dateRange)
                if isScheduled {
                    /// 中断循环
                    return false
                }
                
                return true
            }

            if hasScheduledDate {
                scheduledTasks.append(task)
            }
        }
            
        fetchPeriodItems(for: scheduledTasks,
                         in: period,
                            includeSamples: includeSamples,
                            completion: completion)
    }
    
    func fetchScheduledPeriodItems(for tasks: [HabitTask],
                                   on date: Date,
                                   includeSamples: Bool,
                                   completion: @escaping([HabitPeriodItem]?)->Void) {
        var scheduledTasks: [HabitTask] = []
        for task in tasks {
            let isScheduled = scheduler.isScheduledDate(date,
                                                        withRule: task.timePlan.regularRule,
                                                        dateRange: task.dateRange)
            if isScheduled {
                scheduledTasks.append(task)
            }
        }

        let period = HabitDatePeriod(date: date, mode: .day)
        fetchPeriodItems(for: scheduledTasks, in: period, includeSamples: includeSamples) { results in
            completion(results)
        }
    }
    
    
    func getPeriodItem(for task: HabitTask,
                       in period: HabitDatePeriod,
                        includeSamples: Bool) -> HabitPeriodItem {
        let conditions = CDHabitRecord.conditions(forTask: task, inPeriod: period)
        let predicate = conditions.andPredicate()
        let results: [CDHabitRecord]? = CDHabitRecord.getAll(matching: predicate, in: .defaultContext)
        let periodItem = HabitPeriodItem(habitTask: task, period: period)
        periodItem.records = records(with: results, includeSamples: includeSamples)
        return periodItem
    }
    
    func fetchPeriodItem(for task: HabitTask,
                         in period: HabitDatePeriod,
                         includeSamples: Bool,
                         completion: @escaping(HabitPeriodItem)->Void) {
        let conditions = CDHabitRecord.conditions(forTask: task, inPeriod: period)
        let predicate = conditions.andPredicate()
        CDHabitRecord.fetchAll(matching: predicate) { results in
            let periodItem = HabitPeriodItem(habitTask: task, period: period)
            periodItem.records = self.records(with: results, includeSamples: includeSamples)
            completion(periodItem)
        }
    }
    
    /// 将获取的结果转换为 [DayIntegerKey: HabitRecord] 字典
    private func records(with results: [NSFetchRequestResult]?, includeSamples: Bool) -> [DayIntegerKey: HabitRecord]? {
        guard let results = results as? [CDHabitRecord] else {
            return nil
        }
        
        var records = [DayIntegerKey: HabitRecord]()
        for result in results {
            records[result.day] = HabitRecord(content: result, includeSamples: includeSamples)
        }
        
        return records
    }
    
    
    // MARK: - Helpers
    
    // 定义类型别名
    private typealias HabitRecordsByTask = [String: [Int32: HabitRecord]]
    
    private func recordsGroupedByTask(with results: [CDHabitRecord]?, includeSamples: Bool) -> HabitRecordsByTask? {
        guard let results = results else {
            return nil
        }
        
        var recordsGroupedByTask = [String: [Int32: HabitRecord]]()
        for result in results {
            guard let taskID = result.task?.identifier else {
                continue
            }
            
            var records = recordsGroupedByTask[taskID] ?? [:]
            let record = HabitRecord(content: result, includeSamples: includeSamples)
            records[result.day] = record
            recordsGroupedByTask[taskID] = records
        }
        
        return recordsGroupedByTask
    }
}
