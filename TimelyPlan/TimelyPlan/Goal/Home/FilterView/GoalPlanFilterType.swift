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
        switch self {
        case .all:
            return true
        case .notStarted:
            return goalPlan.progress <= 0.0
        case .inProgress:
            return goalPlan.progress > 0.0 && goalPlan.progress < 1.0
        case .completed:
            return goalPlan.progress >= 1.0
        case .overdue:
            guard let endDate = goalPlan.endDate else {
                return false
            }
            return goalPlan.progress < 1.0 && endDate < Date()
        }
    }
}
