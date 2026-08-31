//
//  GoalRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

// MARK: - 目标计划处理器代理

protocol GoalPlanProcessorDelegate: AnyObject {
    
    /// 创建新目标计划
    func didCreateGoalPlan(_ goalPlan: GoalPlan)
    
    /// 更新目标计划
    func didUpdateGoalPlan(_ goalPlan: GoalPlan)
    
    /// 删除目标计划
    func didDeleteGoalPlan(_ goalPlan: GoalPlan)
    
    /// 移动目标计划（顶部/底部）
    func didMoveGoalPlan(_ goalPlan: GoalPlan)
    
    /// 归档目标计划
    func didArchiveGoalPlan(_ goalPlan: GoalPlan)
    
    /// 取消归档目标计划
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan)
    
    /// 通知目标计划的顺序发生改变
    func didReorderGoalPlan(in goalPlans: [GoalPlan],
                            fromIndex: Int,
                            toIndex: Int)
}

extension GoalPlanProcessorDelegate {
    
    func didCreateGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didUpdateGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didMoveGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {}
    
    func didReorderGoalPlan(in goalPlans: [GoalPlan],
                            fromIndex: Int,
                            toIndex: Int) {}
}

class GoalPlanProcessorUpdater: NSObject,
                                GoalPlanProcessorDelegate {
    
    func didCreateGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didCreateGoalPlan(goalPlan)
        }
    }
    
    func didUpdateGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didUpdateGoalPlan(goalPlan)
        }
    }
    
    func didDeleteGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didDeleteGoalPlan(goalPlan)
        }
    }
    
    func didMoveGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didMoveGoalPlan(goalPlan)
        }
    }
    
    func didArchiveGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didArchiveGoalPlan(goalPlan)
        }
    }
    
    func didUnarchiveGoalPlan(_ goalPlan: GoalPlan) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didUnarchiveGoalPlan(goalPlan)
        }
    }
    
    func didReorderGoalPlan(in goalPlans: [GoalPlan],
                            fromIndex: Int,
                            toIndex: Int) {
        notifyDelegates { (delegate: GoalPlanProcessorDelegate) in
            delegate.didReorderGoalPlan(in: goalPlans,
                                        fromIndex: fromIndex,
                                        toIndex: toIndex)
        }
    }
}

class GoalRepository {
    
    // MARK: - 更新器
    private static let updater = GoalPlanProcessorUpdater()
    
    /// 添加更新器代理对象
    static func addUpdater(_ updater: AnyObject) {
        self.updater.addDelegate(updater)
    }
    
    // MARK: - 内存数据源
    /// 内存中的活动目标计划
    private static var activeGoalPlans: [GoalPlan] = []
    
    /// 内存中的已归档目标计划
    private static var archivedGoalPlans: [GoalPlan] = []
    
    /// 是否已初始化测试数据
    private static var isSeeded = false
    
    // MARK: - 获取
    /// 获取所有活动目标计划
    static func getActiveGoalPlans() -> [GoalPlan] {
        seedIfNeeded()
        return activeGoalPlans.sorted { $0.order < $1.order }
    }
    
    /// 获取所有已归档目标计划
    static func getArchivedGoalPlans() -> [GoalPlan] {
        seedIfNeeded()
        return archivedGoalPlans.sorted { $0.order < $1.order }
    }
    
    /// 异步获取所有活动目标计划
    static func fetchActiveGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        DispatchQueue.global().async {
            let goalPlans = getActiveGoalPlans()
            DispatchQueue.main.async {
                completion(goalPlans)
            }
        }
    }
    
    /// 异步获取所有已归档目标计划
    static func fetchArchivedGoalPlans(completion: @escaping ([GoalPlan]?) -> Void) {
        DispatchQueue.global().async {
            let goalPlans = getArchivedGoalPlans()
            DispatchQueue.main.async {
                completion(goalPlans)
            }
        }
    }
    
    // MARK: - 处理目标计划
    /// 创建目标计划
    static func createGoalPlan(with editingPlan: GoalEditingPlan) {
        seedIfNeeded()
        let goalPlan = GoalPlan()
        applyEditingPlan(editingPlan, to: goalPlan)
        goalPlan.order = nextOrder(in: activeGoalPlans)
        activeGoalPlans.append(goalPlan)
        updater.didCreateGoalPlan(goalPlan)
    }
    
    /// 更新目标计划
    static func updateGoalPlan(_ goalPlan: GoalPlan, with editingPlan: GoalEditingPlan) {
        applyEditingPlan(editingPlan, to: goalPlan)
        updater.didUpdateGoalPlan(goalPlan)
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
        updater.didArchiveGoalPlan(goalPlan)
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
        updater.didUnarchiveGoalPlan(goalPlan)
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
            updater.didDeleteGoalPlan(goalPlan)
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
        updater.didMoveGoalPlan(goalPlan)
    }
    
    /// 移动到底部
    static func moveGoalPlanToBottom(_ goalPlan: GoalPlan) {
        guard let index = activeGoalPlans.firstIndex(of: goalPlan) else {
            return
        }
        
        activeGoalPlans.remove(at: index)
        activeGoalPlans.append(goalPlan)
        reorderOrders(in: activeGoalPlans)
        updater.didMoveGoalPlan(goalPlan)
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
        updater.didReorderGoalPlan(in: goalPlans,
                                   fromIndex: fromIndex,
                                   toIndex: toIndex)
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
    
    // MARK: - 测试数据
    /// 首次访问时填充测试数据
    private static func seedIfNeeded() {
        guard !isSeeded else {
            return
        }
        
        isSeeded = true
        activeGoalPlans = makeTestActiveGoalPlans()
        archivedGoalPlans = makeTestArchivedGoalPlans()
    }
    
    /// 生成测试活动目标计划
    private static func makeTestActiveGoalPlans() -> [GoalPlan] {
        let now = Date()
        let calendar = Calendar.current
        
        let goalPlans = [
            GoalPlan(identifier: "test-goal-1",
                     order: 0,
                     name: "学习 Swift",
                     color: GoalConfig.goalPlanDefaultColor,
                     startDate: now,
                     endDate: calendar.date(byAdding: .month, value: 3, to: now)),
            GoalPlan(identifier: "test-goal-2",
                     order: 1,
                     name: "阅读 12 本书",
                     color: GoalConfig.goalPlanColors[safe: 2] ?? GoalConfig.goalPlanDefaultColor,
                     startDate: calendar.date(byAdding: .month, value: -1, to: now),
                     endDate: calendar.date(byAdding: .month, value: 11, to: now)),
            GoalPlan(identifier: "test-goal-3",
                     order: 2,
                     name: "跑一场马拉松",
                     color: GoalConfig.goalPlanColors[safe: 5] ?? GoalConfig.goalPlanDefaultColor,
                     startDate: calendar.date(byAdding: .month, value: -2, to: now),
                     endDate: calendar.date(byAdding: .month, value: 6, to: now))
        ]
        
        return goalPlans
    }
    
    /// 生成测试已归档目标计划
    private static func makeTestArchivedGoalPlans() -> [GoalPlan] {
        let now = Date()
        let calendar = Calendar.current
        
        let goalPlans = [
            GoalPlan(identifier: "test-goal-archived-1",
                     order: 0,
                     name: "学习吉他",
                     color: GoalConfig.goalPlanColors[safe: 3] ?? GoalConfig.goalPlanDefaultColor,
                     startDate: calendar.date(byAdding: .year, value: -1, to: now),
                     endDate: calendar.date(byAdding: .month, value: -6, to: now),
                     isArchived: true)
        ]
        
        return goalPlans
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
