//
//  GoalRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

/// 目标计划变更
enum GoalPlanChange {
    case create(GoalPlan)
    case update(GoalPlan)
    case delete(GoalPlan)
    case move(GoalPlan)
    case archive(GoalPlan)
    case unarchive(GoalPlan)
}

class GoalRepository {
    
    /// 数据变更回调
    static var goalPlansDidChange: ((GoalPlanChange?) -> Void)?
    
    /// 内存中的活动目标计划
    private static var activeGoalPlans: [GoalPlan] = []
    
    /// 内存中的已归档目标计划
    private static var archivedGoalPlans: [GoalPlan] = []
    
    // MARK: - 获取
    /// 获取所有活动目标计划
    static func getActiveGoalPlans() -> [GoalPlan] {
        return activeGoalPlans.sorted { $0.order < $1.order }
    }
    
    /// 获取所有已归档目标计划
    static func getArchivedGoalPlans() -> [GoalPlan] {
        return archivedGoalPlans.sorted { $0.order < $1.order }
    }
    
    // MARK: - 处理目标计划
    /// 创建目标计划
    static func createGoalPlan(with editingPlan: GoalEditingPlan) {
        let goalPlan = GoalPlan()
        applyEditingPlan(editingPlan, to: goalPlan)
        goalPlan.order = nextOrder(in: activeGoalPlans)
        activeGoalPlans.append(goalPlan)
        goalPlansDidChange?(.create(goalPlan))
    }
    
    /// 更新目标计划
    static func updateGoalPlan(_ goalPlan: GoalPlan, with editingPlan: GoalEditingPlan) {
        applyEditingPlan(editingPlan, to: goalPlan)
        goalPlansDidChange?(.update(goalPlan))
    }
    
    /// 归档目标计划
    static func archiveGoalPlan(_ goalPlan: GoalPlan) {
        guard !goalPlan.isArchived else {
            return
        }
        
        goalPlan.isArchived = true
        if let index = activeGoalPlans.firstIndex(of: goalPlan) {
            activeGoalPlans.remove(at: index)
        }
        archivedGoalPlans.append(goalPlan)
        goalPlansDidChange?(.archive(goalPlan))
    }
    
    /// 取消归档目标计划
    static func unarchiveGoalPlan(_ goalPlan: GoalPlan) {
        guard goalPlan.isArchived else {
            return
        }
        
        goalPlan.isArchived = false
        if let index = archivedGoalPlans.firstIndex(of: goalPlan) {
            archivedGoalPlans.remove(at: index)
        }
        activeGoalPlans.append(goalPlan)
        goalPlansDidChange?(.unarchive(goalPlan))
    }
    
    /// 删除目标计划
    static func deleteGoalPlan(_ goalPlan: GoalPlan) {
        let removed: GoalPlan?
        if activeGoalPlans.contains(goalPlan) {
            removed = activeGoalPlans.removeFirst(of: goalPlan)
        } else {
            removed = archivedGoalPlans.removeFirst(of: goalPlan)
        }
        
        if removed != nil {
            goalPlansDidChange?(.delete(goalPlan))
        }
    }
    
    /// 移动到顶部
    static func moveGoalPlanToTop(_ goalPlan: GoalPlan) {
        guard let index = activeGoalPlans.firstIndex(of: goalPlan) else {
            return
        }
        
        activeGoalPlans.remove(at: index)
        activeGoalPlans.insert(goalPlan, at: 0)
        reorderOrders(in: activeGoalPlans)
        goalPlansDidChange?(.move(goalPlan))
    }
    
    /// 移动到底部
    static func moveGoalPlanToBottom(_ goalPlan: GoalPlan) {
        guard let index = activeGoalPlans.firstIndex(of: goalPlan) else {
            return
        }
        
        activeGoalPlans.remove(at: index)
        activeGoalPlans.append(goalPlan)
        reorderOrders(in: activeGoalPlans)
        goalPlansDidChange?(.move(goalPlan))
    }
    
    /// 重排目标计划
    static func reorderGoalPlan(in goalPlans: [GoalPlan], fromIndex: Int, toIndex: Int) {
        guard fromIndex < goalPlans.count, toIndex < goalPlans.count else {
            return
        }
        
        /// 将存储中的活动目标计划按照传入顺序重新排列
        let identifiers = goalPlans.map { $0.identifier }
        activeGoalPlans = activeGoalPlans.sorted {
            (identifiers.firstIndex(of: $0.identifier) ?? 0) < (identifiers.firstIndex(of: $1.identifier) ?? 0)
        }
        reorderOrders(in: activeGoalPlans)
        goalPlansDidChange?(.move(goalPlans[safe: toIndex] ?? goalPlans[fromIndex]))
    }
    
    // MARK: - Helpers
    /// 将编辑数据应用到目标计划
    private static func applyEditingPlan(_ editingPlan: GoalEditingPlan, to goalPlan: GoalPlan) {
        goalPlan.name = editingPlan.name
        goalPlan.color = editingPlan.color
        goalPlan.startDate = editingPlan.startDate
        goalPlan.endDate = editingPlan.endDate
        goalPlan.note = editingPlan.note
    }
    
    /// 计算下一个排序值
    private static func nextOrder(in goalPlans: [GoalPlan]) -> Int64 {
        return (goalPlans.map { $0.order }.max() ?? 0) + 1
    }
    
    /// 重新计算排序值
    private static func reorderOrders(in goalPlans: [GoalPlan]) {
        for (index, goalPlan) in goalPlans.enumerated() {
            goalPlan.order = Int64(index)
        }
    }
}

private extension Array where Element == GoalPlan {
    
    /// 移除并返回第一个匹配的元素
    mutating func removeFirst(of element: GoalPlan) -> GoalPlan? {
        guard let index = self.firstIndex(of: element) else {
            return nil
        }
        
        return self.remove(at: index)
    }
}

extension Collection {
    
    /// 安全下标访问
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
