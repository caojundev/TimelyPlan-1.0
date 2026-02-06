//
//  TodoTask+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/2/27.
//

import Foundation

extension TodoTask {
    
    /// 按order顺序排列的步骤
    func orderedSteps() -> [TodoStep]? {
        return steps?.orderedElements() as? [TodoStep]
    }
    
    /// 添加步骤到任务，自动设置排序因子
    func addStep(_ step: TodoStep, onTop: Bool = false) {
        let orderedSteps = self.orderedSteps() ?? []
        let order: Int64
        if onTop {
            order = orderedSteps.minOrder - kOrderedStep
        } else {
            order = orderedSteps.maxOrder + kOrderedStep
        }
        
        step.order = order
        addToSteps(step)
    }
}

extension TodoTask: Sortable {
    
    /// 是否是重复任务
    var isRecurringTask: Bool {
        guard dateInfo != nil, let repeatRule = repeatRule else {
            return false
        }

        return repeatRule.type != RepeatType.none
    }
    
    var dateInfo: TaskDateInfo? {
        get {
            guard let startDate = startDate, let endDate = dueDate else {
                return nil
            }
        
            return TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: isAllDay)
        }
        
        set {
            self.startDate = newValue?.startDate
            self.dueDate = newValue?.endDate
            self.isAllDay = newValue?.isAllDay ?? true
        }
        
    }

    /// 获取任务计划
    var schedule: TaskSchedule? {
        get {
            guard let dateInfo = dateInfo else {
                return nil
            }
            
            let schedule = TaskSchedule(dateInfo: dateInfo, reminder: reminder, repeatRule: repeatRule)
            return schedule
        }
        
        set {
            /// 保存计划数据
            self.dateInfo = newValue?.dateInfo
            self.reminder = newValue?.reminder
            self.repeatRule = newValue?.repeatRule
        }
    }
    
    /// 优先级
    var priority: TodoTaskPriority {
        get {
            let rawValue = Int(self.priorityRawValue)
            let priority = TodoTaskPriority(rawValue: rawValue) ?? .none
            return priority
        }
        
        set {
            self.priorityRawValue = Int32(newValue.rawValue)
        }
    }
}

// MARK: - Types
extension TodoTask {
    
    /// 任务状态
    var status: TodoTaskStaus {
        return isCompleted ? .completed : .todo
    }
    
    /// 开始日期类型
    var startDateType: TodoTaskStartDateType {
        return TodoTaskStartDateType.type(of: self.startDate)
    }

    /// 截止日期类型
    var dueDateType: TodoTaskDueDateType {
        return TodoTaskDueDateType.type(of: self.dueDate)
    }
}

// MARK: - Attributed Info
extension TodoTask {
    
    /// 计划信息
    var attributedScheduleInfo: ASAttributedString? {
        return schedule?.attributedInfo()
    }
    
    /// 我的一天信息
    func attributedMyDayInfo() -> ASAttributedString? {
        guard isAddedToMyDay else {
            return nil
        }
        
        if let image = resGetImage("todo_task_addToMyDay_24") {
            let info: ASAttributedString = .string(image: image,
                                                   imageSize: .size(3),
                                                   imageColor: .secondaryLabel)
            return info
        }
        
        return nil
    }
    
    /// 备注信息
    func attributedNoteInfo() -> ASAttributedString? {
        guard let note = note, note.count > 0 else {
            return nil
        }
        
        if let image = resGetImage("todo_task_note_24") {
            let info: ASAttributedString = .string(image: image,
                                                   imageSize: .size(3),
                                                   imageColor: .secondaryLabel)
            return info
        }
        
        return nil
    }
    
    /// 步骤信息
    var attributedStepInfo: ASAttributedString? {
        guard let steps = steps as? Set<TodoStep>, steps.count > 0 else {
            return nil
        }
    
        let completedCount = steps.completedCount
        let format = resGetString("%ld of %ld")
        let trailingText = String(format: format, completedCount, steps.count)
        
        guard let checkmarkImage = resGetImage("checkmark_12") else {
            return trailingText.attributedString
        }
        
        let info: ASAttributedString = .string(image: checkmarkImage,
                                               imageSize: .size(3),
                                               imageColor: .secondaryLabel,
                                               trailingText: trailingText,
                                               separator: nil)
        return info
    }
    
    /// 步骤信息
    var attributedProgressInfo: ASAttributedString? {
        return progress?.attributedProgressInfo
    }
    
    /// 标签信息
    var attributedTagInfo: ASAttributedString? {
        guard let tags = tags as? Set<TodoTag>, tags.count > 0 else {
            return nil
        }

        let orderedTags = tags.orderedElements()
        return orderedTags.attributedInfo()
    }
}

extension Array where Element == TodoTask {
    
    /// 获取所有任务的标签集合
    func allTags() -> Set<TodoTag> {
        var results = Set<TodoTag>()
        for task in self {
            if let tags = task.tags as? Set<TodoTag> {
                results = results.union(tags)
            }
        }
        
        return results
    }
}

// MARK: - Tag
extension TodoTask {
    
    /// 获取标签数组
    var tagsArray: [TodoTag]? {
        if let tagsSet = tags as? Set<TodoTag>, tagsSet.count > 0 {
            return Array(tagsSet)
        }
        
        return nil
    }
    
    /// 更新标签，支持移除和添加标签集合
    func updateTags(removeTags: Set<TodoTag>?, addTags: Set<TodoTag>?) {
        if let removeTags = removeTags {
            removeFromTags(removeTags as NSSet)
        }
        
        if let addTags = addTags {
            addToTags(addTags as NSSet)
        }
    }
}

// MARK: - Progress
extension TodoTask {
    
    /// 移除进度
    @discardableResult
    func removeProgress() -> Bool {
        guard let progress = progress else {
            return false
        }
        
        self.progress = nil
        self.modificationDate = .now
        progress.managedObjectContext?.delete(progress)
        return true
    }
    
}
