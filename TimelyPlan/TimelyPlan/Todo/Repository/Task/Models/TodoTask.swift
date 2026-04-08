//
//  TodoTask.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation

class TodoTask: NSObject {

    var identifier: String
    var order: Int64 = 0
    var isAddedToMyDay: Bool = false
    var name: String?
    var note: String?
    
    /// 优先级
    var priority: TodoTaskPriority = .none
    
    /// 列表
    var list: TodoListFeature?
    
    
    
    var isAllDay: Bool = false
    var startDate: Date?
    var dueDate: Date?
    
    
    
    var schedule: TaskSchedule?
    
    var reminder: TaskReminder?
    var repeatRule: RepeatRule?

    var progress: TodoEditProgress?
    var tags: Set<TodoTag>?
    var creationDate: Date?
    var completionDate: Date?
    var modificationDate: Date?
    
    
    var isCompleted: Bool = false
    var isRemoved: Bool = false
    
    
    init(content: CDTodoTask) {
        self.identifier = content.identifiableKey
        self.order = content.order
        self.isAddedToMyDay = content.isAddedToMyDay
        self.name = content.name
        self.note = content.note
        self.priority = content.priority
        self.list = content.listFeature
        super.init()
    }
}

