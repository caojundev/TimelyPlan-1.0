//
//  HabitPeriodTaskOrganizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/10.
//

import Foundation

class HabitPeriodTaskOrganizer {
    
    /// 根据 timeOption 对任务数组进行分组
    /// - Parameter tasks: 习惯任务数组
    /// - Returns: 按 timeOption 分组的 HabitTaskGroup 数组
    static func group(by timeOptions: [HabitTimeOption],
                      from tasks: [HabitPeriodTask],
                      with filterType: HabitTaskFilterType = .all) -> [HabitTaskGroup] {
        var groups: [HabitTaskGroup] = []
        
        // 第一步：遍历一次 tasks，按 timeOption 归类到字典中
        var tasksByOption: [HabitTimeOption: [HabitPeriodTask]] = [:]
        for task in tasks {
            let option = task.habitTask.timeOption
            if tasksByOption[option] == nil {
                tasksByOption[option] = []
            }
            
            if isTask(task, matching: filterType) {
                tasksByOption[option]?.append(task)
            }
        }
        
        // 第二步：遍历指定的 timeOptions，创建对应的分组
        for option in timeOptions {
            if let filteredTasks = tasksByOption[option], !filteredTasks.isEmpty {
                let group = HabitTaskGroup(identifier: option.identifier)
                group.name = option.title
                group.iconName = option.iconName
                group.tasks = filteredTasks
                groups.append(group)
            }
        }
        
        return groups
    }
    
    static func isTask(_ task: HabitPeriodTask, matching filterType: HabitTaskFilterType) -> Bool {
        if filterType == .all {
            return true
        }
        
        let date = task.period.date
        let status = task.status(on: date)
        switch status {
        case .notStarted, .inProgress:
            return filterType == .todo
        case .completed:
            return filterType == .completed
        case .skipped(_):
            return filterType == .skipped
        case .failed(_):
            return filterType == .failed
        }
    }
    
    /// 根据所有可能的 timeOption 对任务数组进行分组
    /// - Parameter tasks: 习惯任务数组
    /// - Returns: 按 timeOption 分组的 HabitTaskGroup 数组
    static func groupAll(from tasks: [HabitPeriodTask],
                         with filterType: HabitTaskFilterType) -> [HabitTaskGroup] {
        return group(by: HabitTimeOption.allCases, from: tasks, with: filterType)
    }
}
