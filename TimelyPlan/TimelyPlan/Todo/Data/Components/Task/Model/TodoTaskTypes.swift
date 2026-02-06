//
//  TodoTaskTypes.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/20.
//

import Foundation

/// 任务排序时插入位置
enum TodoTaskInsertPosition {
    case before
    case after
}

/// 检查类型
enum TodoTaskCheckType {
    case normal
    case increase
    case decrease
}

/// 任务状态
enum TodoTaskStaus: String, TPMenuRepresentable {
    case todo      /// 待办
    case completed /// 已完成
    
    var identifier: String {
        return String(describing: TodoTaskStaus.self) + self.rawValue.capitalized
    }
}

/// 开始日期类型
enum TodoTaskStartDateType: String, TPMenuRepresentable {
    case started  /// 已开始
    case today    /// 今日
    case tomorrow /// 明日
    case upcoming /// 即将到来（一周）
    case later    /// 稍后
    case unassigned /// 未安排
    
    var identifier: String {
        return String(describing: TodoTaskStartDateType.self) + self.rawValue.capitalized
    }
    
    /// 根据开始日期获取其类型
    static func type(of startDate: Date?) -> TodoTaskStartDateType {
        guard let startDate = startDate else {
            return .unassigned
        }
        
        let today = Date.startOfToday
        if startDate < today {
            return .started /// 今日之前表示已开始
        }
        
        if startDate.isInSameDayAs(today) {
            return .today
        }
            
        let tomorrow = today.dateByAddingDays(1)!
        if startDate.isInSameDayAs(tomorrow) {
            return .tomorrow
        }

        let laterDate = today.dateByAddingDays(7)!
        if startDate >= laterDate {
            return .later
        }
        
        return .upcoming
    }
}

/// 截止日期类型
enum TodoTaskDueDateType: String, TPMenuRepresentable {
    case overdue  /// 已逾期
    case today    /// 今日
    case tomorrow /// 明日
    case upcoming /// 即将到来（一周）
    case later    /// 稍后
    case unassigned /// 未安排
    
    var identifier: String {
        return String(describing: TodoTaskDueDateType.self) + self.rawValue.capitalized
    }
    
    /// 根据截止日期获取其类型
    static func type(of dueDate: Date?) -> TodoTaskDueDateType {
        guard let dueDate = dueDate else {
            return .unassigned
        }
        
        let today = Date.startOfToday
        if dueDate < today {
            return .overdue /// 已逾期
        }
        
        if dueDate.isInSameDayAs(today) {
            return .today
        }
            
        /// 明日
        let tomorrow = today.dateByAddingDays(1)!
        if dueDate.isInSameDayAs(tomorrow) {
            return .tomorrow
        }
        
        let laterDate = today.dateByAddingDays(7)!
        if dueDate >= laterDate {
            return .later
        }
        
        return .upcoming
    }
}
