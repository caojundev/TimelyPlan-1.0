//
//  GoalPlanOptionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation


struct GoalPlanOptionState: Codable {
    
    /// 分组类型
    var groupType: GoalTaskGroupType?
    
    /// 排序
    var sort: TodoSort?
    
    func validatedGroupType(for configuration: GoalPlanConfiguration) -> GoalTaskGroupType {
        return configuration.validatedGroupType(self.groupType)
    }
    
    func validatedSort(for configuration: GoalPlanConfiguration) -> TodoSort {
        return configuration.validatedSort(self.sort ?? TodoSort())
    }
}
