//
//  HabitTaskBaseListGroupProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/11.
//

import Foundation

class HabitTaskBaseListGroupProvider {
    
    /// 当前列表任务
    var tasks: [HabitPeriodTask] = []
    
    let requestManager = TPRequestManager()
    
    /// 是否需要刷新任务
    private(set) var shouldRefresh = true
    
    func setNeedsRefresh(_ refresh: Bool = true) {
        self.shouldRefresh = refresh
    }
    
    func updateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date) {
        let periodTask = periodTask(for: task)
        periodTask?.updateRecord(record, on: date)
    }
    
    func deleteHabitRecord(for task: HabitTask, on date: Date) {
        let periodTask = periodTask(for: task)
        periodTask?.updateRecord(nil, on: date)
    }
    
    func deleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        let periodTask = periodTask(for: task)
        periodTask?.deleteRecords(in: period)
    }
    
    // MARK: - Helpers
    func periodTask(for habitTask: HabitTask) -> HabitPeriodTask? {
        for task in tasks {
            if task.habitTask.identifier == habitTask.identifier {
                return task
            }
        }
        
        return nil
    }
    
}
