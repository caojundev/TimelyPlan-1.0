//
//  GoalRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

class GoalRepository {
    
    // MARK: - 数据管理器
    private static let manager = GoalPlanManager()
    
    /// 添加更新器代理对象
    static func addUpdater(_ updater: AnyObject) {
        manager.updater.addDelegate(updater)
    }
    
    // MARK: - 获取
    /// 获取所有活动目标计划
    static func getActiveGoalPlans() -> [GoalPlan] {
        return manager.getActiveGoalPlans() ?? []
    }
    
    /// 获取所有已归档目标计划
    static func getArchivedGoalPlans() -> [GoalPlan] {
        return manager.getArchivedGoalPlans() ?? []
    }
    
    /// 异步获取所有活动目标计划
    static func fetchActiveGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        manager.fetchActiveGoalPlans(completion: completion)
    }
    
    /// 异步获取所有已归档目标计划
    static func fetchArchivedGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        manager.fetchArchivedGoalPlans(completion: completion)
    }
    
    // MARK: - 处理目标计划
    /// 创建目标计划
    static func createGoalPlan(with editingPlan: GoalEditingPlan) {
        manager.createGoalPlan(with: editingPlan)
    }
    
    /// 更新目标计划
    static func updateGoalPlan(_ goalPlan: GoalPlan, with editingPlan: GoalEditingPlan) {
        manager.updateGoalPlan(goalPlan, with: editingPlan)
    }
    
    /// 归档目标计划
    static func archiveGoalPlan(_ goalPlan: GoalPlan) {
        manager.setArchived(true, for: goalPlan)
    }
    
    /// 取消归档目标计划
    static func unarchiveGoalPlan(_ goalPlan: GoalPlan) {
        manager.setArchived(false, for: goalPlan)
    }
    
    /// 删除目标计划
    static func deleteGoalPlan(_ goalPlan: GoalPlan) {
        manager.deleteGoalPlan(goalPlan)
    }
    
    /// 重排目标计划
    static func reorderGoalPlan(in goalPlans: [GoalPlan], fromIndex: Int, toIndex: Int) {
        manager.reorderGoalPlan(in: goalPlans, fromIndex: fromIndex, toIndex: toIndex)
    }
}
