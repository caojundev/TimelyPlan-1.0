//
//  TodoTask+FilterRule.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/7.
//

import Foundation

extension TodoQuickAddTask {
    
     /// 判断任务是否匹配给定的过滤规则
     func matches(filterRule: TodoFilterRule) -> Bool {
         // 如果过滤规则无效（没有任何过滤条件），则认为匹配
         guard filterRule.isValid else {
             return true
         }
         
         // 检查日期过滤
         if let dateFilterValue = filterRule.dateFilterValue {
             guard matches(dateFilter: dateFilterValue) else {
                 return false
             }
         }
         
         // 检查列表过滤
         if let listFilterValue = filterRule.listFilterValue {
             guard matches(listFilter: listFilterValue) else {
                 return false
             }
         }
         
         // 检查标签过滤
         if let tagFilterValue = filterRule.tagFilterValue {
             guard matches(tagFilter: tagFilterValue) else {
                 return false
             }
         }
         
         // 检查"我的一天"过滤
         if let myDayFilterValue = filterRule.myDayFilterValue {
             guard matches(myDayFilter: myDayFilterValue) else {
                 return false
             }
         }
         
         // 检查进度过滤
         if let progressFilterValue = filterRule.progressFilterValue {
             guard matches(progressFilter: progressFilterValue) else {
                 return false
             }
         }
         
         // 检查优先级过滤
         if let priorityFilterValue = filterRule.priorityFilterValue {
             guard matches(priorityFilter: priorityFilterValue) else {
                 return false
             }
         }
         
         // 所有过滤条件都满足
         return true
     }
     
     // MARK: - 私有辅助方法
     
     private func matches(dateFilter filterValue: TodoDateFilterValue) -> Bool {
         // 获取任务的开始日期
         guard let taskStartDate = schedule?.dateInfo?.startDate else {
             // 如果任务没有开始日期，则不匹配日期过滤
             return false
         }
         
         // 获取过滤规则的日期范围
         guard let dateRange = filterValue.dateRange() else {
             // 如果过滤规则没有有效的日期范围，则认为匹配
             return true
         }
         
         // 检查任务开始日期是否在指定的日期范围内
         guard let rangeStartDate = dateRange.startDate,
               let rangeEndDate = dateRange.endDate else {
             return true
         }
         
         return taskStartDate >= rangeStartDate && taskStartDate <= rangeEndDate
     }
     
     private func matches(listFilter filterValue: TodoListFilterValue) -> Bool {
         // 如果包含收件箱且任务没有所属列表，则匹配
         if let includeInbox = filterValue.includeInbox, includeInbox {
             if list == nil {
                 return true
             }
         }
         
         // 检查任务是否属于指定的列表
         guard let identifiers = filterValue.identifiers, !identifiers.isEmpty else {
             // 如果没有指定列表标识符，但包含了收件箱，已经处理过了
             // 否则，如果任务有列表但不匹配任何指定列表，则不匹配
             return list == nil ? (filterValue.includeInbox ?? false) : false
         }
         
         // 检查任务列表是否在指定的列表中
         if let taskList = list {
             return identifiers.contains(taskList.identifier)
         }
         
         // 任务没有列表，但过滤器要求特定列表，所以不匹配
         return false
     }
     
     private func matches(tagFilter filterValue: TodoTagFilterValue) -> Bool {
         // 如果包含无标签且任务没有标签，则匹配
         if let includeNoTag = filterValue.includeNoTag, includeNoTag {
             if tags == nil || tags!.isEmpty {
                 return true
             }
         }
         
         // 检查任务是否有指定的标签
         guard let identifiers = filterValue.identifiers, !identifiers.isEmpty else {
             // 如果没有指定标签标识符，但包含了无标签选项，已经处理过了
             return tags == nil || tags!.isEmpty ? (filterValue.includeNoTag ?? false) : false
         }
         
         // 检查任务标签是否与指定标签有交集
         if let taskTags = tags, !taskTags.isEmpty {
             // 将任务标签转换为标识符集合
             let taskTagIdentifiers = Set(taskTags.compactMap { $0.identifier })
             let filterTagIdentifiers = Set(identifiers)
             
             // 如果有共同的标签，则匹配
             return !taskTagIdentifiers.intersection(filterTagIdentifiers).isEmpty
         }
         
         // 任务没有标签，但过滤器要求特定标签，所以不匹配
         return false
     }
     
     private func matches(myDayFilter filterValue: TodoMyDayFilterValue) -> Bool {
         switch filterValue {
         case .added:
             return isAddedToMyDay
         case .notAdded:
             return !isAddedToMyDay
         }
     }
     
     private func matches(progressFilter filterValue: TodoProgressFilterValue) -> Bool {
         guard let filterType = filterValue.filterType else {
             return true
         }
         
         switch filterType {
         case .notSetted:
             // 检查进度是否未设置
             return progress == nil
         case .setted:
             // 检查进度是否已设置
             guard let taskProgress = progress else {
                 return false
             }
             
             // 如果有具体的进度值要求
             if let specificValue = filterValue.specificValue,
                let comparisonOperator = specificValue.comparisonOperator {
                 let targetPercentage = specificValue.getPercentage()
                 let progressPercentage = Int(taskProgress.completionFraction * 100)
                
                 switch comparisonOperator {
                 case .greaterThan:
                     return progressPercentage > targetPercentage
                 case .greaterOrEqual:
                     return progressPercentage >= targetPercentage
                 case .lessThan:
                     return progressPercentage < targetPercentage
                 case .lessOrEqual:
                     return progressPercentage <= targetPercentage
                 case .equal:
                     return progressPercentage == targetPercentage
                 }
             }
             
             // 只要进度已设置就匹配
             return true
         }
     }
     
     private func matches(priorityFilter filterValue: TodoPriorityFilterValue) -> Bool {
         guard let priorities = filterValue.priorities, !priorities.isEmpty else {
             return true
         }
         
         // 检查任务优先级是否在指定的优先级列表中
         return priorities.contains(priority)
     }
}

extension TodoQuickAddTask {
    
    /// 是否匹配分组
    func matchesGroup(_ group: TodoGroup, groupType: TodoGroupType) -> Bool {
        switch groupType {
        case .startDate:
            if let dateType = TodoTaskStartDateType(identifier: group.identifier) {
                guard matches(startDateType: dateType) else {
                    return false
                }
            }
        case .dueDate:
            if let dateType = TodoTaskDueDateType(identifier: group.identifier) {
                guard matches(dueDateType: dateType) else {
                    return false
                }
            }
        case .priority:
            if let priority = TodoTaskPriority(identifier: group.identifier) {
                guard matches(priority: priority) else {
                    return false
                }
            }
        default:
            break
        }
        
        return true
    }
    
    private func matches(startDateType: TodoTaskStartDateType) -> Bool {
        let startDate = schedule?.dateInfo?.startDate
        let dateType = TodoTaskStartDateType.type(of: startDate)
        return dateType == startDateType
    }
    
    private func matches(dueDateType: TodoTaskDueDateType) -> Bool {
        let dueDate = schedule?.dateInfo?.endDate
        let dateType = TodoTaskDueDateType.type(of: dueDate)
        return dateType == dueDateType
    }
    
    private func matches(priority: TodoTaskPriority) -> Bool {
        return self.priority == priority
    }

}
