//
//  TodoFilterTaskUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/18.
//

import Foundation

class TodoFilterTaskUpdater {
    
    func changes(for task: TodoTask, with rule: TodoFilterRule) -> [TodoTaskChange]? {
        var changes = [TodoTaskChange]()
        for filterType in TodoFilterType.allCases {
            if let change = matchedChange(for: task, with: rule, of: filterType) {
                changes.append(change)
            }
        }
        
        return changes.count > 0 ? changes : nil
    }
    
    // MARK: - 任务改变
    func matchedChange(for task: TodoTask, with rule: TodoFilterRule, of type: TodoFilterType) -> TodoTaskChange? {
        switch type {
        case .date:
            return matchedDateChange(for: task, with: rule)
        case .list:
            return matchedListChange(for: task, with: rule)
        case .tag:
            return matchedTagChange(for: task, with: rule)
        case .priority:
            return matchedPriorityChange(for: task, with: rule)
        case .myDay:
            return matchedMyDayChange(for: task, with: rule)
        case .progress:
            return matchedProgressChange(for: task, with: rule)
        }
    }
    
    private func matchedDateChange(for task: TodoTask, with rule: TodoFilterRule) -> TodoTaskChange? {
        if isMatchFilterRule(rule, for: task, of: .date) {
            return nil
        }
        
        let oldSchedule = task.schedule
        var newSchedule: TaskSchedule?
        if let oldSchedule = oldSchedule {
            newSchedule = oldSchedule
            
            /// 调整开始日期
            if let dateRange = rule.dateRange,
                let newStartDate = TodoDateFilterValue.suitableStartDate(for: dateRange),
                var dateInfo = newSchedule?.dateInfo {
                dateInfo.setStartDate(newStartDate)
                newSchedule?.dateInfo = dateInfo
            }
        } else {
            newSchedule = rule.defaultSchedule
        }
        
        guard newSchedule != oldSchedule else {
            return nil
        }
        
        return .schedule(oldValue: oldSchedule, newValue: newSchedule)
    }
    
    private func matchedListChange(for task: TodoTask, with rule: TodoFilterRule) -> TodoTaskChange? {
        if isMatchFilterRule(rule, for: task, of: .list) {
            return nil
        }
        
        return .list(oldValue: task.list, newValue: rule.defaultList)
    }
    
    private func matchedTagChange(for task: TodoTask, with rule: TodoFilterRule) -> TodoTaskChange? {
        if isMatchFilterRule(rule, for: task, of: .tag) {
            return nil
        }
        
        var oldValue: Set<TodoTag>?
        if let tags = task.tags as? Set<TodoTag>, tags.count > 0 {
            oldValue = tags
        }
        
        
        return .tag(oldValue: oldValue, newValue: rule.defaultTags)
    }
    
    private func matchedPriorityChange(for task: TodoTask, with rule: TodoFilterRule) -> TodoTaskChange? {
        if isMatchFilterRule(rule, for: task, of: .priority) {
            return nil
        }
        
        guard let newValue = rule.defaultPriority else {
            return nil
        }
        
        return .priority(oldValue: task.priority, newValue: newValue)
    }
    
    private func matchedMyDayChange(for task: TodoTask, with rule: TodoFilterRule) -> TodoTaskChange? {
        if isMatchFilterRule(rule, for: task, of: .myDay) {
            return nil
        }
    
        return .myDay(oldValue: task.isAddedToMyDay, newValue: rule.defaultAddedToMyDay)
    }
    
    private func matchedProgressChange(for task: TodoTask, with rule: TodoFilterRule) -> TodoTaskChange? {
        if isMatchFilterRule(rule, for: task, of: .progress) {
            return nil
        }
        
        let oldProgress = task.editProgress
        var newProgress: TodoEditProgress?
        if let oldProgress = oldProgress {
            if rule.isProgressSetted {
                newProgress = oldProgress
                newProgress?.adjustCurrentValue(toMatch: rule.progressFilterValue?.specificValue)
            }
        } else {
            newProgress = rule.defaultProgress
        }
        
        guard newProgress != oldProgress else {
            return nil
        }
        
        return .progress(oldValue: oldProgress, newValue: newProgress)
    }
    
    // MARK: - 匹配过滤规则
    /// 是否匹配过滤规则
    func isMatchFilterRule(_ rule: TodoFilterRule, for task: TodoTask) -> Bool {
        return TodoFilterType.allCases.allSatisfy { filterType in
            isMatchFilterRule(rule, for: task, of: filterType)
        }
    }
    
    /// 是否匹配过滤规则中的特定类型
    func isMatchFilterRule(_ rule: TodoFilterRule, for task: TodoTask, of type: TodoFilterType) -> Bool {
        guard let filterValue = rule.filterValue(for: type) else {
            /// 无过滤值表示匹配过滤规则
            return true
        }
        
        switch (type, filterValue) {
        case (.date, let value as TodoDateFilterValue):
            return isMatchDateFilterValue(value, for: task)
        case (.list, let value as TodoListFilterValue):
            return isMatchListFilterValue(value, for: task)
        case (.tag, let value as TodoTagFilterValue):
            return isMatchTagFilterValue(value, for: task)
        case (.priority, let value as TodoPriorityFilterValue):
            return isMatchPriorityFilterValue(value, for: task)
        case (.myDay, let value as TodoMyDayFilterValue):
            return isMatchMyDayFilterValue(value, for: task)
        case (.progress, let value as TodoProgressFilterValue):
            return isMatchProgressFilterValue(value, for: task)
        default:
            return false
        }
    }
    
    private func isMatchDateFilterValue(_ value: TodoDateFilterValue, for task: TodoTask) -> Bool {
        guard let dateRange = value.dateRange() else {
            return true
        }
        
        guard let dateInfo = task.dateInfo else {
            /// 无日期信息，不匹配
            return false
        }
        
        /// 判断日期信息是否在过滤范围
        return dateRange.contains(date: dateInfo.startDate) || dateRange.contains(date: dateInfo.endDate)
    }
    
    private func isMatchProgressFilterValue(_ value: TodoProgressFilterValue, for task: TodoTask) -> Bool {
        guard let filterType = value.filterType else {
            return true
        }
        
        guard let progress = task.progress else {
            return filterType == .notSetted
        }
        
        /// 当前任务已设置进度
        guard let specificValue = value.specificValue else {
            return filterType == .setted
        }
        
        /// 判断进度是否匹配指定过滤值
        let editProgress = progress.editProgress
        return editProgress.isMatchFilterSpecificValue(specificValue)
    }
    
    private func isMatchListFilterValue(_ value: TodoListFilterValue, for task: TodoTask) -> Bool {
        guard let list = task.list else {
            /// 收件箱
            return value.includeInbox ?? false
        }
        
        /// 判断列表是否在
        if let listID = list.identifier {
            let identifiers = value.identifiers ?? []
            return identifiers.contains(listID)
        }
        
        return false
    }

    private func isMatchTagFilterValue(_ value: TodoTagFilterValue, for task: TodoTask) -> Bool {
        guard let taskTags = task.tags as? Set<TodoTag>, taskTags.count > 0 else {
            return value.includeNoTag ?? false
        }
        
        let identifiers = value.identifiers ?? []
        return taskTags.contains { tag in
            identifiers.contains(tag.identifier ?? "")
        }
    }
    
    private func isMatchPriorityFilterValue(_ value: TodoPriorityFilterValue, for task: TodoTask) -> Bool {
        guard let priorities = value.priorities, priorities.count > 0 else {
            return true
        }
        
        return priorities.contains(task.priority)
    }
    
    private func isMatchMyDayFilterValue(_ value: TodoMyDayFilterValue, for task: TodoTask) -> Bool {
        return (value == .added && task.isAddedToMyDay) || (value == .notAdded && !task.isAddedToMyDay)
    }
}
