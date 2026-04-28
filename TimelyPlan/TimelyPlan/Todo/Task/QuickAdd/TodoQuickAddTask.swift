//
//  TodoQuickAddTask.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/22.
//

import Foundation

class TodoQuickAddTask: NSCopying {

    /// 所属列表
    var list: TodoListRepresentable?
    
    /// 名称
    var name: String?
    
    /// 备注
    var note: String?
    
    /// 是否允许备注
    var isNoteEnabled: Bool = false
    
    /// 添加到我的一天
    var isAddedToMyDay: Bool = false
    
    /// 优先级
    var priority: TodoTaskPriority = .none
    
    /// 计划
    var schedule: TaskSchedule?
    
    /// 进度
    var progress: TodoEditProgress?
    
    /// 标签
    var tags: Set<TodoTag>?

    /// 步骤
    var steps: [TodoStep]?
    
    /// 是否已完成
    var isCompleted: Bool = false

    /// 是否有效
    var isValid: Bool {
        var isValid = false
        if let name = name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
            isValid = true
        }
        
        return isValid
    }
    
    /// 是否是计划任务
    var isScheduled: Bool {
        if let schedule = schedule, schedule.isScheduled {
            return true
        }
        
        return false
    }
    
    /// 是否逾期
    var isOverdue: Bool {
        if let schedule = schedule, schedule.isOverdue {
            return true
        }
        
        return false
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = TodoQuickAddTask()
        copy.list = list
        copy.name = name
        copy.note = note
        copy.isNoteEnabled = isNoteEnabled
        copy.isAddedToMyDay = isAddedToMyDay
        copy.priority = priority
        copy.schedule = schedule
        copy.progress = progress
        copy.tags = tags
        if let markdown = steps?.markdown() {
            let parser = TodoStepParser()
            copy.steps = parser.parse(markdown)
        }
        
        copy.isCompleted = isCompleted
        
        return copy
    }
}
