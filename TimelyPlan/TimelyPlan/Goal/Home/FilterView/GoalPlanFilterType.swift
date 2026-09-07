//
//  GoalPlanFilterType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/6.
//

import Foundation

/// 目标计划筛选类型
enum GoalPlanFilterType: Int, TPMenuRepresentable {
    case all          /// 所有
    case notStarted   /// 未开始
    case inProgress   /// 进行中
    case completed    /// 已完成
    case overdue      /// 已逾期
    
    /// 标题
    var title: String {
        switch self {
        case .all:
            return resGetString("All")
        case .notStarted:
            return resGetString("Not Started")
        case .inProgress:
            return resGetString("In Progress")
        case .completed:
            return resGetString("Completed")
        case .overdue:
            return resGetString("Overdue")
        }
    }
    
    /// 目标计划是否匹配该筛选状态
    func matches(_ goalPlan: GoalPlan) -> Bool {
        let isCompleted = goalPlan.progress >= 1.0
        
        switch self {
        case .all:
            return true
        case .completed:
            return isCompleted
        case .notStarted:
            guard !isCompleted, let startDate = goalPlan.startDate else {
                return false
            }

            return startDate > Date()
        case .overdue:
            guard !isCompleted, let endDate = goalPlan.endDate else {
                return false
            }
            
            return endDate < Date()
        case .inProgress:
            guard !isCompleted else {
                return false
            }
            
            let dateRange = DateRange(startDate: goalPlan.startDate, endDate: goalPlan.endDate)
            return dateRange.contains(date: .now)
        }
    }
    
}
