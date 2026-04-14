//
//  Array+TodoGroup.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/27.
//

import Foundation

extension TodoTask {
    
    /// 任务状态
    var status: TodoTaskStaus {
        return isCompleted ? .completed : .todo
    }
    
    /// 开始日期类型
    var startDateType: TodoTaskStartDateType {
        return TodoTaskStartDateType.type(of: self.schedule?.dateInfo?.startDate)
    }

    /// 截止日期类型
    var dueDateType: TodoTaskDueDateType {
        return TodoTaskDueDateType.type(of: self.schedule?.dateInfo?.endDate)
    }
}

extension Array where Element == TodoTask {

    /// 未归类分组
    func noneClassifiedTaskGroups() -> [TodoGroup] {
        let type = TodoGroupType.none
        let group = TodoGroup(identifier: type.identifier)
        group.isHeaderHidden = true /// 未归类分组，不显示头视图
        group.title = type.title
        group.tasks = self
        return [group]
    }
    
    /// 按列表归类分组
    func listClassifiedTaskGroups() -> [TodoGroup] {
        let result = self.listClassifiedTasks()
        var groups = [TodoGroup]()
        
        /// 收件箱
        if let inboxTasks = result.inboxTasks, inboxTasks.count > 0 {
            let smartList = TodoSmartList.inbox
            let group = TodoGroup(identifier: smartList.identifier)
            group.title = smartList.title
            group.tasks = inboxTasks
            groups.append(group)
        }
        
//        let dic = result.listTasksDic
//        let orderedUserLists = todo.orderedLists()
//        let sortedLists = result.listTasksDic.keys.sorted { lList, rList in
//            guard let lIndex = orderedUserLists.firstIndex(of: lList),
//                  let rIndex = orderedUserLists.firstIndex(of: rList) else {
//                return true
//            }
//
//            return lIndex < rIndex
//        }
//
//        for list in sortedLists {
//            let group = TodoListGroup(list: list)
//            group.tasks = dic[list]
//            groups.append(group)
//        }
//
        
        return groups
    }
    
    /// 按完成状态归类分组
    func statusClassifiedTaskGroups() -> [TodoGroup] {
        let dic = statusClassifiedTasks()
        var groups = [TodoGroup]()
        TodoTaskStaus.allCases.forEach { status in
            if let tasks = dic[status], tasks.count > 0 {
                let group = TodoGroup(identifier: status.identifier)
                group.title = status.title
                group.tasks = tasks
                groups.append(group)
            }
        }

        return groups
    }
       
    /// 按开始日期归类分组
    func startDateClassifiedTaskGroups() -> [TodoGroup] {
        let dic = startDateClassifiedTasks()
        var groups = [TodoGroup]()
        TodoTaskStartDateType.allCases.forEach { type in
            if let tasks = dic[type], tasks.count > 0 {
                let group = TodoGroup(identifier: type.identifier)
                group.title = type.title
                group.tasks = tasks
                groups.append(group)
            }
        }

        return groups
    }
    
    /// 按截止日期归类分组
    func dueDateClassifiedTaskGroups() -> [TodoGroup] {
        let dic = dueDateClassifiedTasks()
        var groups = [TodoGroup]()
        TodoTaskDueDateType.allCases.forEach { type in
            if let tasks = dic[type], tasks.count > 0 {
                let group = TodoGroup(identifier: type.identifier)
                group.title = type.title
                group.tasks = tasks
                groups.append(group)
            }
        }
    
        return groups
    }
    
    /// 按优先级归类分组
    func priorityClassifiedTaskGroups() -> [TodoGroup] {
        let dic = priorityClassifiedTasks()
        var groups = [TodoGroup]()
        TodoTaskPriority.priorities.forEach { priority in
            if let tasks = dic[priority], tasks.count > 0 {
                let group = TodoGroup(identifier: priority.identifier)
                group.title = priority.title
                group.tasks = tasks
                groups.append(group)
            }
        }
    
        return groups
    }
    
    
    // MARK: - 归类任务字典
    
    // 将任务按列表归类并存储在字典中
    typealias TodoListClassifiedTasksResult = (inboxTasks: [TodoTask]?,
                                               listTasksDic: [TodoListFeature: Array<Element>])
    func listClassifiedTasks() -> TodoListClassifiedTasksResult {
        /// 收件箱任务
        var inboxTasks: [TodoTask] = []
        var listTasksDic: [TodoListFeature: Array<Element>] = [:]
        for task in self {
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
    func statusClassifiedTasks() -> [TodoTaskStaus: Array<Element>] {
        var tasks: [TodoTaskStaus: Array<Element>] = [:]
        TodoTaskStaus.allCases.forEach { status in
            tasks[status] = []
        }
        
        for task in self {
            if task.isCompleted {
                tasks[.completed]?.append(task)
            } else {
                tasks[.todo]?.append(task)
            }
        }
        
        return tasks
    }
    
    /// 将待办任务按开始日期类型归类并存储在字典中
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
    
    /// 将待办任务按截止日期类型归类并存储在字典中
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
    
    /// 将待办任务按优先级归类并存储在字典中
    func priorityClassifiedTasks() -> [TodoTaskPriority: Array<Element>] {
        var tasks: [TodoTaskPriority: Array<Element>] = [:]
        TodoTaskPriority.allCases.forEach { priority in
            tasks[priority] = []
        }
        
        for task in self {
            tasks[task.priority]?.append(task)
        }
        
        return tasks
    }
}
