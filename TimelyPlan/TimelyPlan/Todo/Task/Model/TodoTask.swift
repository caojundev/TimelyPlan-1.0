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
    
    var name: String?
    var note: String?
    var startDate: Date?
    var dueDate: Date?
    
    var isAddedToMyDay: Bool = false
    
    var isAllDay: Bool = false
    
    var isCompleted: Bool = false
    
    var isRemoved: Bool = false
    
    var priority: TodoTaskPriority = .none
    
    var schedule: TaskSchedule?
    
    var reminder: TaskReminder?
    var repeatRule: RepeatRule?

    var list: TodoList?
    
    var progress: TodoEditProgress?
    
    var tags: Set<TodoTag>?
    
    var creationDate: Date?
    var completionDate: Date?
    var modificationDate: Date?
    
    override init() {
        self.identifier = UUID().uuidString
        super.init()
    }
}

