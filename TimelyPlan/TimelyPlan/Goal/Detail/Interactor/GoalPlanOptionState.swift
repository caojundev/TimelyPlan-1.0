//
//  GoalPlanOptionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation

struct GoalPlanOptionState: Codable {
    
    /// 分组类型
    var groupType: TodoGroupType?
    
    /// 排序
    var sort: TodoSort?
    
    func validatedGroupType(for configuration: GoalPlanConfiguration) -> TodoGroupType {
        return configuration.validatedGroupType(self.groupType)
    }
    
    func validatedSort(for configuration: GoalPlanConfiguration) -> TodoSort {
        return configuration.validatedSort(self.sort ?? TodoSort())
    }
}
