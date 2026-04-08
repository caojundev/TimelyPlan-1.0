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
    static var priority = "priorityRawValue"
    static var isAddedToMyDay = "isAddedToMyDay"
    static var tags = "tags"
    static var list = "list"
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

extension CDTodoTask {
    
    static var allInboxTaskPredicate: NSPredicate {
        let condition: PredicateCondition = (TodoTaskKey.list, .isEmpty)
        return NSPredicate.predicate(with: condition)
    }
    
    /// 收件箱任务谓词
    private func activeInboxTaskPredicate(showCompleted: Bool = true) -> NSPredicate {
        var conditions: [PredicateCondition] = [
            (TodoTaskKey.list, .isEmpty),
            (TodoTaskKey.isRemoved, .isFalse)
        ]
        
        if !showCompleted {
            conditions.append((TodoTaskKey.isCompleted, .isFalse))
        }
        
        return conditions.andPredicate()
    }
}

extension Array where Element == CDTodoTask {
    
    var tasks: [TodoTask] {
        self.map{ TodoTask(content: $0) }
    }
}
