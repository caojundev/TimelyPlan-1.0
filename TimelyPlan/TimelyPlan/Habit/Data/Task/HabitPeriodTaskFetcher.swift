//
//  HabitPeriodTaskFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

class HabitPeriodTaskFetcher {
    
    private let scheduler = HabitTimePlanScheduler()
    
    func fetchPeriodTasks(for habitTasks: [HabitTask],
                          in period: HabitDatePeriod,
                          completion: @escaping([HabitPeriodTask])->Void) {
        let conditions: [PredicateCondition]
        if period.mode == .day {
            conditions = CDHabitRecord.conditions(forTasks: habitTasks, onDate: period.date)
        } else {
            conditions = CDHabitRecord.conditions(forTasks: habitTasks, inPeriod: period)
        }
        
        let predicate = conditions.andPredicate()
        CDHabitRecord.findAll(with: predicate) { results in
            let groupedRecords = self.recordsGroupedByTask(with: results as? [CDHabitRecord])
            var periodTasks: [HabitPeriodTask] = []
            for habitTask in habitTasks {
                let periodTask = HabitPeriodTask(habitTask: habitTask, period: period)
                periodTask.records = groupedRecords?[habitTask.identifier]
                periodTasks.append(periodTask)
            }
            
            completion(periodTasks)
        }
    }
    
    func fetchScheduledPeriodTasks(on date: Date,
                                   activeTasks: [HabitTask],
                                   completion: @escaping([HabitPeriodTask]?)->Void) {
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
        fetchPeriodTasks(for: scheduledTasks, in: period) { results in
            completion(results)
        }
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
