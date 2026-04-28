//
//  TodoTaskEnums.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/20.
//

import Foundation

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

// 待办任务完成日期类型枚举
enum TodoTaskCompletionDateType: String, TPMenuRepresentable {
    case today
    case yesterday
    case thisWeek
    case lastWeek
    case thisMonth
    case earlier
    
    var title: String {
        switch self {
        case .today: return resGetString("Today")
        case .yesterday: return resGetString("Yesterday")
        case .thisWeek: return resGetString("This Week")
        case .lastWeek: return resGetString("Last Week")
        case .thisMonth: return resGetString("This Month")
        case .earlier: return resGetString("Earlier")
        }
    }
    
    var identifier: String {
        return String(describing: TodoTaskCompletionDateType.self) + self.rawValue.capitalized
    }
    
    /// 根据完成日期获取日期类型
    /// - Parameters:
    ///   - completionDate: 任务完成的日期
    ///   - currentDate: 当前日期（默认为系统当前日期）
    /// - Returns: 对应的日期类型
    static func type(for completionDate: Date, currentDate: Date = Date()) -> TodoTaskCompletionDateType {
        let calendar = Calendar.current
        
        // 提取日期组件（忽略时间部分）
        let compCompletion = calendar.dateComponents([.year, .month, .day], from: completionDate)
        let compCurrent = calendar.dateComponents([.year, .month, .day], from: currentDate)
        guard let completionDay = calendar.date(from: compCompletion),
              let currentDay = calendar.date(from: compCurrent) else {
            return .earlier
        }
        
        // 1. 判断是否是今天
        if calendar.isDate(completionDay, inSameDayAs: currentDay) {
            return .today
        }
        
        // 2. 判断是否是昨天
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: currentDay),
           calendar.isDate(completionDay, inSameDayAs: yesterday) {
            return .yesterday
        }
        
        // 3. 判断是否是本周
        if calendar.isDate(completionDay, equalTo: currentDay, toGranularity: .weekOfYear) {
            return .thisWeek
        }
        
        // 4. 判断是否是上周
        if let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: currentDay),
           calendar.isDate(completionDay, equalTo: lastWeekStart, toGranularity: .weekOfYear) {
            return .lastWeek
        }
        
        // 5. 判断是否是本月
        if calendar.isDate(completionDay, equalTo: currentDay, toGranularity: .month) {
            return .thisMonth
        }
        
        // 6. 更早
        return .earlier
    }
}
