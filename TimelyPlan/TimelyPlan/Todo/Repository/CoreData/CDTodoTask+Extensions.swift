//
//  CDTodoTask+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/8.
//

import Foundation
import CoreData

/// 待办任务键值
struct TodoTaskKey {
    static var identifier = "identifier"
    static var list = "list"
    static var listIdentifier = "list.identifier"
    static var priority = "priorityRawValue"
    static var isAddedToMyDay = "isAddedToMyDay"
    static var tags = "tags"
    static var order = "order"
    static var isCompleted = "isCompleted"
    static var isRemoved = "isRemoved"
    static var creationDate = "creationDate"
    static var modificationDate = "modificationDate"
    static var startDate = "startDate"
    static var dueDate = "dueDate"
    static var progress = "progress"
}

extension CDTodoTask: SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    var priority: TodoTaskPriority {
        return TodoTaskPriority(rawValue: Int(priorityRawValue)) ?? .none
    }
    
    var listFeature: TodoListFeature? {
        return self.list?.feature
    }
    
    static func createTodoTask(with quickAddTask: TodoQuickAddTask, onTop: Bool = true) -> CDTodoTask {
        let task = CDTodoTask.createEntity(in: .defaultContext)
        task.identifier = UUID().uuidString
        task.name = quickAddTask.name
        if quickAddTask.isNoteEnabled {
            task.note = quickAddTask.note
        }
    
        task.isAddedToMyDay = quickAddTask.isAddedToMyDay
        task.priorityRawValue = Int16(quickAddTask.priority.rawValue)
        task.creationDate = .now
        task.modificationDate = .now
        
        /// 处理标签
        if let tags = quickAddTask.tags, let cdTags = CDTodoTag.getTags(for: tags) {
            task.addToTags(Set(cdTags) as NSSet)
        }
    
        if let list = quickAddTask.list, let cdList = CDTodoList.coreDataList(for: list) {
            /// 添加到用户列表
            cdList.addTask(task, onTop: onTop)
        } else {
            /// 添加到收件箱
            if onTop {
                task.order = inboxMinOrder - kOrderedStep
            } else {
                task.order = inboxMaxOrder + kOrderedStep
            }
        }
 
        #warning("处理计划和进度")
        /*
        // task.schedule = quickAddTask.schedule
        if let progress = quickAddTask.progress {
//            task.progress = .newProgress(with: editProgress)
        }
        */
        
        return task
    }
    
    /// 收件箱最小排序因子
    static var inboxMinOrder: Int64 {
        return minimumOrder(with: allInboxTaskPredicate)
    }
    
    /// 收件箱最大排序因子
    static var inboxMaxOrder: Int64 {
        return maximumOrder(with: allInboxTaskPredicate)
    }
}

// MARK: - 处理任务
extension CDTodoTask {

    /// 移动任务到新列表
    static func moveTasks(_ tasks: [TodoTask], to list: TodoList?) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask],
              cdTasks.count > 0 else {
            return false
        }
        
        var cdToList: CDTodoList? = nil
        if let toList = list {
            cdToList = CDTodoList.getItem(withIdentifier: toList.identifier)
        }
        
        for cdTask in cdTasks {
            let cdFromList = cdTask.list
            if cdFromList == cdToList {
                continue
            }
            
            cdFromList?.removeFromTasks(cdTask)
            cdToList?.addTask(cdTask)
        }
        
        return true
    }
    
    /// 将任务移动到废纸篓
    static func moveTasksToTrash(_ tasks: [TodoTask]) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask], cdTasks.count > 0 else {
            return false
        }
        
        for cdTask in cdTasks {
            cdTask.isRemoved = true
        }
        
        return true
    }
        
    /// 恢复废纸篓中的任务
    static func restoreTrashTask(_ task: TodoTask) -> Bool  {
        return restoreTrashTasks([task])
    }
    
    static func restoreTrashTasks(_ tasks: [TodoTask]) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask], cdTasks.count > 0 else {
            return false
        }
        
        for cdTask in cdTasks {
            cdTask.isRemoved = false
        }
        
        return true
    }
    
    /// 清空废纸篓
    static func emptyTrash(completion: @escaping(Bool) -> Void) {
        fetchTrashTasks { tasks in
            guard let tasks = tasks, tasks.count > 0 else {
                completion(false)
                return
            }
            
            for task in tasks {
                task.list?.removeFromTasks(task)
            }
            
            NSManagedObjectContext.defaultContext.deleteObjects(tasks)
            completion(true)
        }
    }
    
    static func deleteTasks(_ tasks: [TodoTask]) -> Bool {
        guard let cdTasks = getIdentifiableItems(with: tasks) as? [CDTodoTask], cdTasks.count > 0 else {
            return false
        }
        
        NSManagedObjectContext.defaultContext.deleteObjects(cdTasks)
        return true
    }
    
}


// MARK: - 获取任务
extension CDTodoTask {
    
    /// 获取废纸篓任务
    static func fetchTrashTasks(completion: @escaping([CDTodoTask]?) -> Void) {
        findAll(with: trashTaskPredicate) { results in
            completion(results as? [CDTodoTask])
        }
    }
    
}

// MARK: - 谓词
extension CDTodoTask {
    // MARK: - 用户清单任务
    /// 用户清单活动任务
    static func userListActiveTaskPredicate(for list: TodoList,
                                             showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.listIdentifier, .equal(list.identifier)),
            notRemovedCondition
        ]
        
        if !showCompleted {
            conditions.append(notShowCompletedCondition)
        }
        
        return conditions.andPredicate()
    }
    
    // MARK: - 收件箱
    /// 所有收件箱任务
    static var allInboxTaskPredicate: NSPredicate {
        let condition: PredicateCondition = (TodoTaskKey.list, .isEmpty)
        return NSPredicate.predicate(with: condition)
    }
    
    /// 收件箱活动任务
    static func activeInboxTaskPredicate(showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.list, .isEmpty),
            notRemovedCondition
        ]
        
        if !showCompleted {
            conditions.append(notShowCompletedCondition)
        }
        
        return conditions.andPredicate()
    }
    
    // MARK: - 废纸篓
    static var trashTaskPredicate: NSPredicate {
        let conditions: [PredicateCondition] = [
            (TodoTaskKey.isRemoved, .isTrue)
        ]
        
        return conditions.andPredicate()
    }
    
    // MARK: - Conditions
    static var notRemovedCondition: PredicateCondition {
        return (TodoTaskKey.isRemoved, .isFalse)
    }
    
    static var notShowCompletedCondition: PredicateCondition {
        return (TodoTaskKey.isCompleted, .isFalse)
    }
}

extension Array where Element == CDTodoTask {
    
    var tasks: [TodoTask] {
        self.map{ TodoTask(content: $0) }
    }
}
