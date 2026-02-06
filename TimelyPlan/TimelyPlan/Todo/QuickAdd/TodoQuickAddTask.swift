//
//  TodoQuickAddTask.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/22.
//

import Foundation

class TodoQuickAddTask: NSCopying {

    /// 所属列表
    var list: TodoList?
    
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
        return copy
    }
    
}

extension TodoQuickAddTask {
    
    /// 获取象限默认的快速添加任务
    static func defaultTask(for quadrant: Quadrant) -> TodoQuickAddTask {
        let rule = QuadrantSettingAgent.shared.filterRule(for: quadrant)
        let task = TodoQuickAddTask()
        task.schedule = rule.defaultSchedule
        task.list = rule.defaultList
        task.tags = rule.defaultTags
        task.progress = rule.defaultProgress
        task.isAddedToMyDay = rule.defaultAddedToMyDay
        task.priority = rule.defaultPriority ?? quadrant.defaultPriority
        return task
    }
}
