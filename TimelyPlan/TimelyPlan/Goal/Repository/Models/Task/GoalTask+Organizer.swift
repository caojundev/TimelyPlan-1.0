//
//  GoalTask+Organizer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/4.
//

import Foundation

// MARK: - 目标任务分组归类

/// 目标任务完成状态（按是否勾选完成分组的粗状态）
enum GoalTaskCompletionStatus: String, CaseIterable {
    /// 待办（未完成）
    case todo
    /// 已完成
    case completed
    
    /// 分组标识
    var identifier: String {
        return String(describing: GoalTaskCompletionStatus.self) + self.rawValue.capitalized
    }
    
    /// 分组标题
    var title: String {
        switch self {
        case .todo:
            return resGetString("Todo")
        case .completed:
            return resGetString("Completed")
        }
    }
}

/// 目标任务的目标达成状态（按数值目标是否达成及执行进度分组的 4 种状态）
enum GoalTaskAchieveStatus: String, CaseIterable {
    /// 进行中
    case inProgress
    /// 未开始
    case notStarted
    /// 已达成（目标数值已经达到）
    case achieved
    /// 已逾期
    case overdue
    
    /// 分组标识
    var identifier: String {
        return String(describing: GoalTaskAchieveStatus.self) + self.rawValue.capitalized
    }
    
    /// 分组标题
    var title: String {
        switch self {
        case .inProgress:
            return resGetString("In Progress")
        case .notStarted:
            return resGetString("Not Started")
        case .achieved:
            return resGetString("Achieved")
        case .overdue:
            return resGetString("Overdue")
        }
    }
}

/// 目标任务权重分组类型（按权重 1~10 归类为高/中/低三档）
enum GoalTaskWeightGroupType: String, CaseIterable {
    /// 高权重（8～10）
    case high
    /// 中权重（4～7）
    case medium
    /// 低权重（1～3）
    case low
    
    /// 分组标识
    var identifier: String {
        return String(describing: GoalTaskWeightGroupType.self) + self.rawValue.capitalized
    }
    
    /// 分组标题
    var title: String {
        switch self {
        case .high:
            return resGetString("High Weight")
        case .medium:
            return resGetString("Medium Weight")
        case .low:
            return resGetString("Low Weight")
        }
    }
    
    /// 根据权重数值返回所在档位（权重越界时返回 nil）
    static func type(for weight: Int64) -> GoalTaskWeightGroupType? {
        switch weight {
        case 1...3:
            return .low
        case 4...7:
            return .medium
        case 8...10:
            return .high
        default:
            return nil
        }
    }
}

extension GoalTask {
    
    /// 完成状态（按是否勾选完成分组）
    var completionStatus: GoalTaskCompletionStatus {
        return isCompleted ? .completed : .todo
    }
    
    /// 目标达成状态（按数值目标是否达成及执行进度分组）
    var achieveStatus: GoalTaskAchieveStatus {
        if isProgressCompleted {
            return .achieved
        }
        
        /// 已过期且未达成目标视为逾期
        if let endDate = endDate, endDate < Date() {
            return .overdue
        }
        
        /// 开始时间在未来视为未开始
        if let startDate = startDate, startDate > Date() {
            return .notStarted
        }
        
        return .inProgress
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
    
    /// 权重分组档位（权重越界时返回 nil）
    var weightGroupType: GoalTaskWeightGroupType? {
        return GoalTaskWeightGroupType.type(for: weight)
    }
}

extension Array where Element == GoalTask {
    
    /// 未归类分组
    func noneClassifiedTaskGroups() -> [GoalTaskGroup] {
        let type = GoalTaskGroupType.none
        let group = GoalTaskGroup(identifier: type.identifier)
        group.title = type.title
        group.goalTasks = self
        return [group]
    }
    
    /// 按完成状态归类分组
    func statusClassifiedTaskGroups() -> [GoalTaskGroup] {
        let dic = statusClassifiedTasks()
        var groups = [GoalTaskGroup]()
        GoalTaskCompletionStatus.allCases.forEach { status in
            if let tasks = dic[status], tasks.count > 0 {
                let group = GoalTaskGroup(identifier: status.identifier)
                group.title = status.title
                group.goalTasks = tasks
                groups.append(group)
            }
        }
        
        return groups
    }
    
    /// 按目标达成状态归类分组
    func achievedClassifiedTaskGroups() -> [GoalTaskGroup] {
        let dic = achievedClassifiedTasks()
        var groups = [GoalTaskGroup]()
        GoalTaskAchieveStatus.allCases.forEach { status in
            if let tasks = dic[status], tasks.count > 0 {
                let group = GoalTaskGroup(identifier: status.identifier)
                group.title = status.title
                group.goalTasks = tasks
                groups.append(group)
            }
        }
        
        return groups
    }
 
    /// 按权重档位归类分组（高/中/低，最多三组）
    func weightClassifiedTaskGroups() -> [GoalTaskGroup] {
        let dic = weightClassifiedTasks()
        var groups = [GoalTaskGroup]()
        GoalTaskWeightGroupType.allCases.forEach { type in
            if let tasks = dic[type], tasks.count > 0 {
                let group = GoalTaskGroup(identifier: type.identifier)
                group.title = type.title
                group.goalTasks = tasks
                groups.append(group)
            }
        }
        
        return groups
    }
    
    // MARK: - 归类任务字典
    
    /// 按完成状态归类
    func statusClassifiedTasks() -> [GoalTaskCompletionStatus: Array<Element>] {
        var tasks: [GoalTaskCompletionStatus: Array<Element>] = [:]
        GoalTaskCompletionStatus.allCases.forEach { status in
            tasks[status] = []
        }
        
        for task in self {
            tasks[task.completionStatus]?.append(task)
        }
        
        return tasks
    }
    
    /// 按目标达成状态归类
    func achievedClassifiedTasks() -> [GoalTaskAchieveStatus: Array<Element>] {
        var tasks: [GoalTaskAchieveStatus: Array<Element>] = [:]
        GoalTaskAchieveStatus.allCases.forEach { status in
            tasks[status] = []
        }
        
        for task in self {
            tasks[task.achieveStatus]?.append(task)
        }
        
        return tasks
    }
    
    /// 按权重档位归类
    func weightClassifiedTasks() -> [GoalTaskWeightGroupType: Array<Element>] {
        var tasks: [GoalTaskWeightGroupType: Array<Element>] = [:]
        for task in self {
            guard let type = task.weightGroupType else {
                continue
            }
            
            tasks[type, default: []].append(task)
        }
        
        return tasks
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
