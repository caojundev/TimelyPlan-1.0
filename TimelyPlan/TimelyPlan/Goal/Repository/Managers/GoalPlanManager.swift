//
//  GoalPlanManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation
import CoreData

class GoalPlanManager {
    
    /// 数据更新器
    let updater = GoalPlanProcessorUpdater()
    
    /// 默认上下文对象
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    // MARK: - 异步获取目标计划
    func fetchActiveGoalPlans(completion: @escaping([GoalPlan]?) -> Void) {
        CDGoalPlan.fetchActiveGoalPlans { results in
            completion(results?.toGoalPlans)
        }
    }
    
    func fetchArchivedGoalPlans(completion: @escaping([GoalPlan]?) -> Void) {
        CDGoalPlan.fetchArchivedGoalPlans { results in
            completion(results?.toGoalPlans)
        }
    }
    
    // MARK: - 同步获取目标计划
    /// 获取所有目标计划
    func getAllGoalPlans() -> [GoalPlan]? {
        return CDGoalPlan.getAllGoalPlans()?.toGoalPlans
    }
    
    /// 获取所有活动目标计划
    func getActiveGoalPlans() -> [GoalPlan]? {
        return CDGoalPlan.getActiveGoalPlans()?.toGoalPlans
    }
    
    /// 获取所有已归档目标计划
    func getArchivedGoalPlans() -> [GoalPlan]? {
        return CDGoalPlan.getArchivedGoalPlans()?.toGoalPlans
    }
    
    /// 获取已归档目标计划数目
    func numberOfArchivedGoalPlans() -> Int {
        return CDGoalPlan.numberOfArchivedGoalPlans()
    }
    
    /// 搜索活动目标计划
    func searchActiveGoalPlans(containText text: String,
                               completion: (@escaping([GoalPlan]?) -> Void)) {
        CDGoalPlan.searchActiveGoalPlans(containText: text) { results in
            completion(results?.toGoalPlans)
        }
    }
    
    /// 获取特定标识的目标计划
    func getGoalPlan(withIdentifier identifier: String) -> GoalPlan? {
        if let content = CDGoalPlan.getGoalPlan(withIdentifier: identifier) {
            return GoalPlan(content: content)
        }
        
        return nil
    }
    
    // MARK: - 处理目标计划
    /// 创建目标计划
    func createGoalPlan(with editingPlan: GoalEditingPlan) {
        let content = CDGoalPlan.newGoalPlan(with: editingPlan)
        content.order = CDGoalPlan.maximumOrder + kOrderedStep
        
        let goalPlan = GoalPlan(content: content)
        updater.didCreateGoalPlan(goalPlan)
        HandyRecord.updateChangeCount()
    }
    
    @discardableResult
    /// 更新目标计划
    func updateGoalPlan(_ goalPlan: GoalPlan,
                        with editingPlan: GoalEditingPlan) -> GoalPlan? {
        if goalPlan.isSamePlan(as: editingPlan) {
            return nil
        }
        
        if let content = CDGoalPlan.getGoalPlan(withIdentifier: goalPlan.identifier) {
            content.update(with: editingPlan)
            updater.didUpdateGoalPlan(goalPlan)
            HandyRecord.updateChangeCount()
            return GoalPlan(content: content)
        }
        
        return nil
    }
    
    /// 删除目标计划
    func deleteGoalPlan(_ goalPlan: GoalPlan) {
        if let content = CDGoalPlan.getGoalPlan(withIdentifier: goalPlan.identifier) {
            context.delete(content)
            updater.didDeleteGoalPlan(goalPlan)
            HandyRecord.updateChangeCount()
        }
    }
    
    /// 设置归档状态
    func setArchived(_ isArchived: Bool, for goalPlan: GoalPlan) {
        guard goalPlan.isArchived != isArchived else {
            return
        }
        
        if let content = CDGoalPlan.getGoalPlan(withIdentifier: goalPlan.identifier) {
            content.isArchived = isArchived
            
            let updatedGoalPlan = GoalPlan(content: content)
            if isArchived {
                updater.didArchiveGoalPlan(updatedGoalPlan)
            } else {
                updater.didUnarchiveGoalPlan(updatedGoalPlan)
            }
            HandyRecord.updateChangeCount()
        }
    }
    
    /// 重排目标计划
    func reorderGoalPlan(in goalPlans: [GoalPlan], fromIndex: Int, toIndex: Int) {
        var goalPlans = goalPlans
        goalPlans.moveObject(fromIndex: fromIndex, toIndex: toIndex)
        CDGoalPlan.syncOrders(for: goalPlans)
        HandyRecord.updateChangeCount()
    }
}
