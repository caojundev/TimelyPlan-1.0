//
//  HabitPeriodTaskFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

class HabitPeriodTaskFetcher {
    
    private let regularScheduler = HabitTimePlanRegularScheduler()
    
    func fetchScheduledPeriodTasks(on date: Date,
                                   activeTasks: [HabitTask],
                                   completion: @escaping([HabitPeriodTask]?)->Void) {
        /// 将任务归类
        var regularTasks: [HabitTask] = [] /// 定期任务
        var weekRandomTasks: [HabitTask] = []  /// 周随机任务
        var monthRandomTasks: [HabitTask] = []  /// 月随机任务
        for task in activeTasks {
            /// 判断指定日期是否在习惯的日期范围内
            guard task.dateRange.contains(date: date) else {
                continue
            }
            
            let timePlan = task.timePlan
            if timePlan.type == .regularly {
                /// 确定是否是计划日
                if regularScheduler.isScheduledDate(date,
                                                    withRule: timePlan.regularRule,
                                                    startDate: task.dateRange.startDate ?? .now) {
                    regularTasks.append(task)
                }
            } else if let rule = timePlan.randomRule, rule.frequency == .monthly {
                monthRandomTasks.append(task)
            } else {
                weekRandomTasks.append(task)
            }
        }
        
        let group = DispatchGroup()
        group.enter()
        /// 定期
        var regularPeriodTasks: [HabitPeriodTask] = []
        fetchRegularPeriodTasks(for: regularTasks, on: date) { results in
            regularPeriodTasks = results
            group.leave()
        }
        
        /// 周随机
        var weekRandomPeriodTasks: [HabitPeriodTask] = []
        
        /// 月随机
        var monthRandomPeriodTasks: [HabitPeriodTask] = []
        
        group.notify(queue: .main) {
            /// 合并任务
            let results = regularPeriodTasks + weekRandomPeriodTasks + monthRandomPeriodTasks
            completion(results)
        }
    }
    
    private func fetchRegularPeriodTasks(for regularHabitTasks: [HabitTask],
                                         on date: Date,
                                         completion: @escaping([HabitPeriodTask]) -> Void) {
        let period = HabitDatePeriod(date: date, mode: .day)
        let conditions = CDHabitRecord.conditions(forTasks: regularHabitTasks, onDate: date)
        let predicate = conditions.andPredicate()
        CDHabitRecord.findAll(with: predicate) { results in
            let groupedRecords = self.recordsGroupedByTask(with: results as? [CDHabitRecord])
            var periodTasks: [HabitPeriodTask] = []
            for regularHabitTask in regularHabitTasks {
                let records = groupedRecords?[regularHabitTask.identifier]
                let periodTask = HabitPeriodTask(habitTask: regularHabitTask, period: period)
                periodTask.records = records
                periodTasks.append(periodTask)
            }
            
            completion(periodTasks)
        }
    }
    
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
