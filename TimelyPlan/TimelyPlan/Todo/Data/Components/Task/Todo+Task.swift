//
//  Todo+Task.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/28.
//

import Foundation
import CoreData

/// 待办任务键值
struct TodoTaskKey {
    static var priority = "priorityRawValue"
    static var isAddedToMyDay = "isAddedToMyDay"
    static var progress = "progress"
    static var tags = "tags"
    static var list = "list"
    static var order = "order"
    static var isCompleted = "isCompleted"
    static var isRemoved = "isRemoved"
    static var creationDate = "creationDate"
    static var modificationDate = "modificationDate"
    static var startDate = "startDate"
    static var dueDate = "dueDate"
}

/// 任务操作
extension Todo {
    
    /// 创建任务
    func createTodoTask(with quickAddTask: TodoQuickAddTask) {
        taskManager.createTodoTask(with: quickAddTask)
    }

    func updateTask(_ task: TodoTask, withChanges changes: [TodoTaskChange]) {
        taskManager.updateTask(task, withChanges: changes)
    }
    
    // MARK: - 记录
    func updateTask(_ task: TodoTask, inputValue: Int64, inputType: TodoRecordInputType) {
        if inputType == .update {
            taskManager.updateTask(task, currentValue: inputValue)
        } else {
            var incrementValue = inputValue
            if inputType == .negative {
                incrementValue = -inputValue
            }
            
            taskManager.updateTask(task, incrementValue: incrementValue)
        }
    }
    
    func updateTask(_ task: TodoTask, incrementValue: Int64) {
        taskManager.updateTask(task, incrementValue: incrementValue)
    }
    
    func updateTask(_ task: TodoTask, currentValue: Int64) {
        taskManager.updateTask(task, currentValue: currentValue)
    }
    
    func updateTask(_ task: TodoTask, editProgress: TodoEditProgress?) {
        taskManager.updateTask(task, editProgress: editProgress)
    }

    /// 更新任务
    func updateTask(_ task: TodoTask, tags: Set<TodoTag>?) {
        taskManager.updateTask(task, tags: tags)
    }
    
    func updateTask(_ task: TodoTask, name: String?) {
        taskManager.updateTask(task, name: name)
    }

    func updateTask(_ task: TodoTask, schedule: TaskSchedule?) {
        taskManager.updateTask(task, schedule: schedule)
    }
    

    func updateTask(_ task: TodoTask, note: String?) {
        taskManager.updateTask(task, note: note)
    }
    
    func updateTask(_ task: TodoTask, priority: TodoTaskPriority) {
        updateTasks([task], priority: priority)
    }
    
    func updateTask(_ task: TodoTask,  isAddedToMyDay: Bool) {
        updateTasks([task], isAddedToMyDay: isAddedToMyDay)
    }
      
    func updateTasks(_ tasks: [TodoTask], isAddedToMyDay: Bool) {
        taskManager.updateTasks(tasks, isAddedToMyDay: isAddedToMyDay)
    }
    
    func updateTasks(_ tasks: [TodoTask], priority: TodoTaskPriority) {
        taskManager.updateTasks(tasks, priority: priority)
    }

    /// 完成任务
    func setCompleted(_ isCompleted: Bool, for task: TodoTask) {
        setCompleted(isCompleted, for: [task])
    }
    
    func setCompleted(_ isCompleted: Bool, for tasks: [TodoTask]) {
        taskManager.setCompleted(isCompleted, for: tasks)
    }
    
    /// 移动任务
    func moveTodoTask(_ task: TodoTask, toList: TodoList?) {
        moveTodoTasks([task], toList: toList)
    }
    
    func moveTodoTasks(_ tasks: [TodoTask], toList: TodoList?) {
        taskManager.moveTodoTasks(tasks, toList: toList)
    }
    
    /// 将任务移动到废纸篓
    func moveToTrash(with tasks: [TodoTask]) {
        taskManager.moveToTrash(with: tasks)
    }
    
    /// 恢复废纸篓中的任务
    func restoreTrashTask(_ task: TodoTask) {
        restoreTrashTasks([task])
    }
    
    func restoreTrashTasks(_ tasks: [TodoTask]) {
        taskManager.restoreTrashTasks(tasks)
    }
    
    /// 清空废纸篓
    func emptyTrash() {
        taskManager.emptyTrash()
    }
    
    /// 彻底删除
    func deleteTask(_ task: TodoTask) {
        deleteTasks([task])
    }
    
    func deleteTasks(_ tasks: [TodoTask]) {
        taskManager.deleteTasks(tasks)
    }
    
    /// 任务排序
    func reorderTask(_ sourceTask: TodoTask,
                     postion: TodoTaskInsertPosition,
                     targetTask: TodoTask,
                     in list: TodoList?) -> Bool {
        taskManager.reorderTask(sourceTask, postion: postion, targetTask: targetTask, in: list)
    }
}

extension Todo {

    /// 同步获取列表任务分组
    func getTaskGroups(for list: TodoListRepresentable,
                       with configuration: TodoListConfiguration,
                       shouldCollapse: ((TodoGroup) -> Bool)? = nil) -> [TodoGroup] {
        return taskManager.getTaskGroups(for: list, with: configuration, shouldCollapse: shouldCollapse)
    }
    
    /// 获取列表中任务数目
    func numberOfTasks(in list: TodoListRepresentable) -> Int {
        return taskManager.numberOfTasks(in: list)
    }
    
    /// 获取特定标签下的任务数量，并可以选择是否包含已完成的任务。
    func taskCount(for tag: TodoTag, includeCompleted: Bool = true) -> Int {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.tags, .anyEqual(tag)),
            (TodoTaskKey.isRemoved, .isFalse),
        ]
        
        if !includeCompleted {
            conditions.append((TodoTaskKey.isCompleted, .isFalse))
        }
        
        let predicate = conditions.andPredicate()
        let count = TodoTask.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
}
