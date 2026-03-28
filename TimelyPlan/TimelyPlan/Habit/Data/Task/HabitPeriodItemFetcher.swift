//
//  HabitPeriodItemFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation
import CoreData

class HabitPeriodItemFetcher {
    
    private let scheduler = HabitTimePlanScheduler()
    
    func fetchPeriodItems(for tasks: [HabitTask],
                          in period: HabitDatePeriod,
                          completion: @escaping([HabitPeriodItem])->Void) {
        let conditions: [PredicateCondition]
        if period.mode == .day {
            conditions = CDHabitRecord.conditions(forTasks: tasks, onDate: period.date)
        } else {
            conditions = CDHabitRecord.conditions(forTasks: tasks, inPeriod: period)
        }
        
        let predicate = conditions.andPredicate()
        CDHabitRecord.findAll(with: predicate) { results in
            let groupedRecords = self.recordsGroupedByTask(with: results as? [CDHabitRecord])
            var periodItems: [HabitPeriodItem] = []
            for task in tasks {
                let item = HabitPeriodItem(habitTask: task, period: period)
                item.records = groupedRecords?[task.identifier]
                periodItems.append(item)
            }
            
            completion(periodItems)
        }
    }
    
    func fetchScheduledPeriodItems(on date: Date,
                                   activeTasks: [HabitTask],
                                   completion: @escaping([HabitPeriodItem]?)->Void) {
        /// 将任务归类
        var scheduledTasks: [HabitTask] = [] /// 定期任务
        for task in activeTasks {
            let isScheduled = scheduler.isScheduledDate(date,
                                                        timePlan: task.timePlan,
                                                        dateRange: task.dateRange)
            if isScheduled {
                scheduledTasks.append(task)
            }
        }

        let period = HabitDatePeriod(date: date, mode: .day)
        fetchPeriodItems(for: scheduledTasks, in: period) { results in
            completion(results)
        }
    }
    
    func fetchPeriodItem(for task: HabitTask,
                         in period: HabitDatePeriod,
                         completion: @escaping(HabitPeriodItem)->Void) {
        let conditions = CDHabitRecord.conditions(forTask: task, inPeriod: period)
        let predicate = conditions.andPredicate()
        CDHabitRecord.findAll(with: predicate) { results in
            let periodItem = HabitPeriodItem(habitTask: task, period: period)
            periodItem.records = self.records(with: results)
            completion(periodItem)
        }
    }
    
    /// 将获取的结果转换为 [DayIntegerKey: HabitRecord] 字典
    private func records(with results: [NSFetchRequestResult]?) -> [DayIntegerKey: HabitRecord]? {
        guard let results = results as? [CDHabitRecord] else {
            return nil
        }
        
        var records = [DayIntegerKey: HabitRecord]()
        for result in results {
            records[result.day] = HabitRecord(content: result)
        }
        
        return records
    }
    
    
    // MARK: - Helpers
    
    // 定义类型别名
    private typealias HabitRecordsByTask = [String: [Int32: HabitRecord]]
    
    private func recordsGroupedByTask(with results: [CDHabitRecord]?) -> HabitRecordsByTask? {
        guard let results = results else {
            return nil
        }
        
        var recordsGroupedByTask = [String: [Int32: HabitRecord]]()
        for result in results {
            guard let taskID = result.task?.identifier else {
                continue
            }
            
            var records = recordsGroupedByTask[taskID] ?? [:]
            let record = HabitRecord(content: result)
            records[result.day] = record
            recordsGroupedByTask[taskID] = records
        }
        
        return recordsGroupedByTask
    }
}
