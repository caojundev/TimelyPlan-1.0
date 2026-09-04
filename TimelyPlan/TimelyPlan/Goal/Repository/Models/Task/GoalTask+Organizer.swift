//
//  GoalTask+Organizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/4.
//

import Foundation

// MARK: - 目标任务分组归类

extension GoalTask {
    
    /// 任务状态
    var status: TodoTaskStaus {
        return isCompleted ? .completed : .todo
    }
    
    /// 开始日期类型
    var startDateType: TodoTaskStartDateType {
        return TodoTaskStartDateType.type(of: self.startDate)
    }
    
    /// 截止日期类型（目标任务使用结束日期作为截止日期）
    var dueDateType: TodoTaskDueDateType {
        return TodoTaskDueDateType.type(of: self.endDate)
    }
    
    /// 完成日期类型
    var completionDateType: TodoTaskCompletionDateType? {
        guard let completionDate = self.completionDate, completionDate < Date().endOfDay() else {
            return nil
        }
        
        return TodoTaskCompletionDateType.type(for: completionDate)
    }
    
    /// 权重选项（权重值超出 1～10 时返回 nil）
    var weightOption: GoalTaskWeightOption? {
        return GoalTaskWeightOption.option(for: weight)
    }
}

extension Array where Element == GoalTask {
    
    /// 未归类分组
    func noneClassifiedTaskGroups() -> [GoalTaskGroup] {
        let type = TodoGroupType.none
        let group = GoalTaskGroup(identifier: type.identifier)
        group.title = type.title
        group.goalTasks = self
        return [group]
    }
    
    /// 按完成状态归类分组
    func statusClassifiedTaskGroups() -> [GoalTaskGroup] {
        let dic = statusClassifiedTasks()
        var groups = [GoalTaskGroup]()
        TodoTaskStaus.allCases.forEach { status in
            if let tasks = dic[status], tasks.count > 0 {
                let group = GoalTaskGroup(identifier: status.identifier)
                group.title = status.title
                group.goalTasks = tasks
                groups.append(group)
            }
        }
        
        return groups
    }
    
    /// 按开始日期归类分组
    func startDateClassifiedTaskGroups() -> [GoalTaskGroup] {
        let dic = startDateClassifiedTasks()
        var groups = [GoalTaskGroup]()
        TodoTaskStartDateType.allCases.forEach { type in
            if let tasks = dic[type], tasks.count > 0 {
                let group = GoalTaskGroup(identifier: type.identifier)
                group.title = type.title
                group.goalTasks = tasks
                groups.append(group)
            }
        }
        
        return groups
    }
    
    /// 按截止日期归类分组
    func dueDateClassifiedTaskGroups() -> [GoalTaskGroup] {
        let dic = dueDateClassifiedTasks()
        var groups = [GoalTaskGroup]()
        TodoTaskDueDateType.allCases.forEach { type in
            if let tasks = dic[type], tasks.count > 0 {
                let group = GoalTaskGroup(identifier: type.identifier)
                group.title = type.title
                group.goalTasks = tasks
                groups.append(group)
            }
        }
        
        return groups
    }
    
    /// 按完成日期归类分组
    func completionDateClassifiedTaskGroups() -> [GoalTaskGroup] {
        let dic = completionDateClassifiedTasks()
        var groups = [GoalTaskGroup]()
        TodoTaskCompletionDateType.allCases.forEach { type in
            if let tasks = dic[type], tasks.count > 0 {
                let group = GoalTaskGroup(identifier: type.identifier)
                group.title = type.title
                group.goalTasks = tasks
                groups.append(group)
            }
        }
        
        return groups
    }
    
    /// 按权重归类分组（目标任务无优先级概念，以权重替代）
    func weightClassifiedTaskGroups() -> [GoalTaskGroup] {
        let dic = weightClassifiedTasks()
        var groups = [GoalTaskGroup]()
        for option in GoalTaskWeightOption.allCases.reversed() {
            if let tasks = dic[option], tasks.count > 0 {
                let group = GoalTaskGroup(identifier: option.groupIdentifier)
                group.title = option.groupTitle
                group.goalTasks = tasks
                groups.append(group)
            }
        }
        
        return groups
    }
    
    // MARK: - 归类任务字典
    
    /// 按完成状态归类
    func statusClassifiedTasks() -> [TodoTaskStaus: Array<Element>] {
        var tasks: [TodoTaskStaus: Array<Element>] = [:]
        TodoTaskStaus.allCases.forEach { status in
            tasks[status] = []
        }
        
        for task in self {
            tasks[task.status]?.append(task)
        }
        
        return tasks
    }
    
    /// 按开始日期类型归类
    func startDateClassifiedTasks() -> [TodoTaskStartDateType: Array<Element>] {
        var tasks: [TodoTaskStartDateType: Array<Element>] = [:]
        TodoTaskStartDateType.allCases.forEach { type in
            tasks[type] = []
        }
        
        for task in self {
            tasks[task.startDateType]?.append(task)
        }
        
        return tasks
    }
    
    /// 按截止日期类型归类
    func dueDateClassifiedTasks() -> [TodoTaskDueDateType: Array<Element>] {
        var tasks: [TodoTaskDueDateType: Array<Element>] = [:]
        TodoTaskDueDateType.allCases.forEach { type in
            tasks[type] = []
        }
        
        for task in self {
            tasks[task.dueDateType]?.append(task)
        }
        
        return tasks
    }
    
    /// 按完成日期类型归类
    func completionDateClassifiedTasks() -> [TodoTaskCompletionDateType: Array<Element>] {
        var tasks: [TodoTaskCompletionDateType: Array<Element>] = [:]
        TodoTaskCompletionDateType.allCases.forEach { type in
            tasks[type] = []
        }
        
        for task in self {
            if let dateType = task.completionDateType {
                tasks[dateType]?.append(task)
            }
        }
        
        return tasks
    }
    
    /// 按权重归类
    func weightClassifiedTasks() -> [GoalTaskWeightOption: Array<Element>] {
        var tasks: [GoalTaskWeightOption: Array<Element>] = [:]
        for task in self {
            guard let option = task.weightOption else {
                continue
            }
            
            tasks[option, default: []].append(task)
        }
        
        return tasks
    }
}

// MARK: - 权重分组信息

extension GoalTaskWeightOption {
    
    /// 分组标识
    var groupIdentifier: String {
        return String(describing: GoalTaskWeightOption.self) + "\(rawValue)"
    }
    
    /// 分组标题
    var groupTitle: String {
        return String(format: resGetString("Weight %ld"), rawValue)
    }
}

// MARK: - 目标任务排序

extension TodoSort {
    
    /// 目标任务排序描述
    var goalTaskSortDescriptor: SortDescriptor<GoalTask> {
        let order: SortOrder = self.order == .ascending ? .forward : .reverse
        let descriptor: SortDescriptor<GoalTask>
        switch type {
        case .manually:
            descriptor = SortDescriptor(\GoalTask.order, order: .forward)
        case .creationDate:
            descriptor = SortDescriptor(\GoalTask.creationDate, order: order)
        case .modificationDate:
            descriptor = SortDescriptor(\GoalTask.modificationDate, order: order)
        case .completionDate:
            descriptor = SortDescriptor(\GoalTask.completionDate, order: order)
        case .startDate:
            descriptor = SortDescriptor(\GoalTask.startDate, order: order)
        case .dueDate:
            descriptor = SortDescriptor(\GoalTask.endDate, order: order)
        }
        
        return descriptor
    }
}
