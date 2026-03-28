//
//  HabitPeriodItemOrganizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/10.
//

import Foundation

class HabitPeriodItemOrganizer {
    
    /// 根据 timeOption 对任务数组进行分组
    /// - Parameter tasks: 习惯任务数组
    /// - Returns: 按 timeOption 分组的 HabitTaskGroup 数组
    static func group(by timeOptions: [HabitTimeOption],
                      from periodItems: [HabitPeriodItem],
                      with filterType: HabitTaskFilterType = .all) -> [HabitTaskGroup] {
        var groups: [HabitTaskGroup] = []
        
        // 第一步：遍历一次 tasks，按 timeOption 归类到字典中
        var tasksByOption: [HabitTimeOption: [HabitPeriodItem]] = [:]
        for periodItem in periodItems {
            let option = periodItem.habitTask.timeOption
            if tasksByOption[option] == nil {
                tasksByOption[option] = []
            }
            
            if isPeriodItem(periodItem, matching: filterType) {
                tasksByOption[option]?.append(periodItem)
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
    
    static func isPeriodItem(_ periodItem: HabitPeriodItem, matching filterType: HabitTaskFilterType) -> Bool {
        if filterType == .all {
            return true
        }
        
        let date = periodItem.period.date
        let status = periodItem.status(on: date)
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
    static func groupAll(from periodItems: [HabitPeriodItem],
                         with filterType: HabitTaskFilterType) -> [HabitTaskGroup] {
        return group(by: HabitTimeOption.allCases, from: periodItems, with: filterType)
    }
}
