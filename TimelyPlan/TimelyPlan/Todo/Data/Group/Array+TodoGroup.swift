//
//  Array+TodoGroup.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/27.
//

import Foundation

extension Array where Element == TodoTask {

    /// 未归类分组
    func noneClassifiedTaskGroups(showCompleted: Bool = true) -> [TodoGroup] {
        let type = TodoGroupType.none
        let group = TodoGroup(identifier: type.identifier)
        group.isExpanded = true /// 展开
        group.isHeaderHidden = true /// 未归类分组，不显示头视图
        group.title = type.title
        group.tasks = showCompleted ? self : self.todoTasks()
        return [group]
    }
    
    /// 按列表归类分组
    func listClassifiedTaskGroups(showCompleted: Bool = true,
                                  shouldCollapse: ((TodoGroup) -> Bool)?) -> [TodoGroup] {
        let result = self.listClassifiedTasks(showCompleted: showCompleted)
        var groups = [TodoGroup]()
        
        /// 收件箱
        if let inboxTasks = result.inboxTasks {
            let smartList = TodoSmartList.inbox
            let group = TodoGroup(identifier: smartList.identifier!)
            group.isExpanded = !(shouldCollapse?(group) ?? false)
            group.title = smartList.title
            group.tasks = inboxTasks
            groups.append(group)
        }
        
        let dic = result.listTasksDic
        let orderedUserLists = todo.orderedLists()
        let sortedLists = result.listTasksDic.keys.sorted { lList, rList in
            guard let lIndex = orderedUserLists.firstIndex(of: lList),
                  let rIndex = orderedUserLists.firstIndex(of: rList) else {
                return true
            }
            
            return lIndex < rIndex
        }
        
        for list in sortedLists {
            let group = TodoListGroup(list: list)
            group.isExpanded = !(shouldCollapse?(group) ?? false)
            group.tasks = dic[list]
            groups.append(group)
        }
        
        return groups
    }
    
    /// 按完成状态归类分组
    func statusClassifiedTaskGroups(showCompleted: Bool = true,
                                    shouldCollapse: ((TodoGroup) -> Bool)?) -> [TodoGroup] {
        let dic = statusClassifiedTasks(showCompleted: showCompleted)
        var groups = [TodoGroup]()
        TodoTaskStaus.allCases.forEach { status in
            let group = TodoGroup(identifier: status.identifier)
            group.isExpanded = !(shouldCollapse?(group) ?? false)
            group.title = status.title
            group.tasks = dic[status]
            groups.append(group)
        }

        return groups
    }
       
    /// 按开始日期归类分组
    func startDateClassifiedTaskGroups(showCompleted: Bool = true,
                                       shouldCollapse: ((TodoGroup) -> Bool)?) -> [TodoGroup] {
        let dic = startDateClassifiedTasks(showCompleted: showCompleted)
        var groups = [TodoGroup]()
        TodoTaskStartDateType.allCases.forEach { type in
            let group = TodoGroup(identifier: type.identifier)
            group.isExpanded = !(shouldCollapse?(group) ?? false)
            group.title = type.title
            group.tasks = dic[type]
            groups.append(group)
        }

        return groups
    }
    
    /// 按截止日期归类分组
    func dueDateClassifiedTaskGroups(showCompleted: Bool = true,
                                     shouldCollapse: ((TodoGroup) -> Bool)?) -> [TodoGroup] {
        let dic = dueDateClassifiedTasks(showCompleted: showCompleted)
        var groups = [TodoGroup]()
        TodoTaskDueDateType.allCases.forEach { type in
            let group = TodoGroup(identifier: type.identifier)
            group.isExpanded = !(shouldCollapse?(group) ?? false)
            group.title = type.title
            group.tasks = dic[type]
            groups.append(group)
        }
    
        return groups
    }
    
    /// 按优先级归类分组
    func priorityClassifiedTaskGroups(showCompleted: Bool = true,
                                      shouldCollapse: ((TodoGroup) -> Bool)?) -> [TodoGroup] {
        let dic = priorityClassifiedTasks(showCompleted: showCompleted)
        var groups = [TodoGroup]()
        TodoTaskPriority.priorities.forEach { priority in
            let group = TodoGroup(identifier: priority.identifier)
            group.isExpanded = !(shouldCollapse?(group) ?? false)
            group.title = priority.title
            group.tasks = dic[priority]
            groups.append(group)
        }
    
        return groups
    }
    
    
    // MARK: - 归类任务字典
    
    // 将任务按列表归类并存储在字典中
    typealias TodoListClassifiedTasksResult = (inboxTasks: [TodoTask]?,
                                               listTasksDic: [TodoList: Array<Element>])
    func listClassifiedTasks(showCompleted: Bool = true) -> TodoListClassifiedTasksResult {
        /// 收件箱任务
        var inboxTasks: [TodoTask] = []
        var listTasksDic: [TodoList: Array<Element>] = [:]
        for task in self {
            if task.isRemoved || (!showCompleted && task.isCompleted) {
                continue
            }
            
            guard let list = task.list else {
                /// 任务无列表，添加到收件箱
                inboxTasks.append(task)
                continue
            }
            
            if listTasksDic[list] == nil {
                listTasksDic[list] = []
            }
            
            listTasksDic[list]?.append(task)
        }
        
        return (inboxTasks.count > 0 ? inboxTasks : nil, listTasksDic)
    }

    // 将待办任务按完成状态归类并存储在字典中
    func statusClassifiedTasks(showCompleted: Bool = true) -> [TodoTaskStaus: Array<Element>] {
        var tasks: [TodoTaskStaus: Array<Element>] = [:]
        TodoTaskStaus.allCases.forEach { status in
            tasks[status] = []
        }
        
        for task in self {
            if !showCompleted && task.isCompleted {
                continue
            }
            
            if task.isCompleted {
                tasks[.completed]?.append(task)
            } else {
                tasks[.todo]?.append(task)
            }
        }
        
        return tasks
    }
    
    /// 将待办任务按开始日期类型归类并存储在字典中
    func startDateClassifiedTasks(showCompleted: Bool = true) -> [TodoTaskStartDateType: Array<Element>] {
        var tasks: [TodoTaskStartDateType: Array<Element>] = [:]
        TodoTaskStartDateType.allCases.forEach { type in
            tasks[type] = []
        }
        
        for task in self {
            if !showCompleted && task.isCompleted {
                continue
            }
            
            tasks[task.startDateType]?.append(task)
        }
        
        return tasks
    }
    
    /// 将待办任务按截止日期类型归类并存储在字典中
    func dueDateClassifiedTasks(showCompleted: Bool = true) -> [TodoTaskDueDateType: Array<Element>] {
        var tasks: [TodoTaskDueDateType: Array<Element>] = [:]
        TodoTaskDueDateType.allCases.forEach { type in
            tasks[type] = []
        }
        
        for task in self {
            if !showCompleted && task.isCompleted {
                continue
            }
            
            tasks[task.dueDateType]?.append(task)
        }
        
        return tasks
    }
    
    /// 将待办任务按优先级归类并存储在字典中
    func priorityClassifiedTasks(showCompleted: Bool = true) -> [TodoTaskPriority: Array<Element>] {
        var tasks: [TodoTaskPriority: Array<Element>] = [:]
        TodoTaskPriority.allCases.forEach { priority in
            tasks[priority] = []
        }
        
        for task in self {
            if !showCompleted && task.isCompleted {
                continue
            }
            
            tasks[task.priority]?.append(task)
        }
        
        return tasks
    }

    
    // MARK: - 获取任务数组
    
    /// 获取列表中所有待办任务
    func todoTasks() -> [TodoTask] {
        var tasks = [TodoTask]()
        for task in self {
            if task.isCompleted {
                continue
            }
            
            tasks.append(task)
        }
        
        return tasks
    }
    
}
