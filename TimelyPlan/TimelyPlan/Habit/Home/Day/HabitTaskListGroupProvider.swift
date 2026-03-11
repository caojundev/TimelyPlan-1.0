//
//  HabitTaskListGroupProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/11.
//

import Foundation

class HabitTaskListGroupProvider {
    
    /// 当前列表任务
    private var tasks: [HabitPeriodTask] = []
    
    private let requestManager = TPRequestManager()
    
    /// 是否需要刷新任务
    private var shouldRefresh = true
    
    func setNeedsRefresh() {
        self.shouldRefresh = true
    }
    
    func fetchGroups(on date: Date,
                     with filterType: HabitTaskFilterType,
                     completion: @escaping ([HabitTaskGroup]?) -> Void) {
        loadTasksIfNeeded(on: date) { tasks in
            guard let tasks = tasks else {
                completion(nil)
                return
            }
            
            let groups = HabitPeriodTaskOrganizer.groupAll(from: tasks, with: filterType)
            completion(groups)
        }
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
    
    private func loadTasksIfNeeded(on date: Date,
                                   completion: @escaping ([HabitPeriodTask]?) -> Void) {
        guard self.shouldRefresh else {
            print("⛱️ 无需重新加载")
            completion(self.tasks)
            return
        }

        /// 刷新任务列表
        let requestID = requestManager.executeRequest()
        TimelyPlan.habit.fetchScheduledPeriodTasks(on: date) { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion(nil)
                print("❌ 加载失败.....")
                return
            }
            
            self.tasks = tasks ?? []
            self.shouldRefresh = false
            completion(self.tasks)
            print("✅ 加载成功.....")
        }
    }
    
    // MARK: - Helpers
    private func periodTask(for habitTask: HabitTask) -> HabitPeriodTask? {
        for task in tasks {
            if task.habitTask.identifier == habitTask.identifier {
                return task
            }
        }
        
        return nil
    }
    
}
