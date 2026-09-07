//
//  CDGoalPlan+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation
import CoreData
import UIKit

extension CDGoalPlan: TPHexColorConvertible, SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    // MARK: - TPHexColorConvertible
    static var defaultColor: UIColor {
        return GoalConfig.goalPlanDefaultColor
    }
    
    /// 根据编辑目标计划创建新目标计划
    static func newGoalPlan(with editingPlan: GoalEditingPlan) -> CDGoalPlan {
        let goalPlan = CDGoalPlan.createEntity(in: .defaultContext)
        goalPlan.identifier = UUID().uuidString /// 新创建目标计划设置标识
        goalPlan.creationDate = .now
        goalPlan.update(with: editingPlan)
        return goalPlan
    }
    
    func update(with editingPlan: GoalEditingPlan) {
        self.name = editingPlan.name
        self.colorHex = editingPlan.color.hexString
        self.startDate = editingPlan.startDate
        self.endDate = editingPlan.endDate
        self.note = editingPlan.note
        self.modificationDate = .now
    }
    
    /// 添加任务到列表，自动设置排序因子
    func addTask(_ task: CDGoalTask, onTop: Bool = false) {
        let tasks = tasks?.allObjects as? [CDGoalTask]
        let order: Int64
        if onTop {
            let minOrder = tasks?.minOrder ?? 0
            order = minOrder - kOrderedStep
        } else {
            let maxOrder = tasks?.maxOrder ?? 0
            order = maxOrder + kOrderedStep
        }
        
        task.order = order
        self.addToTasks(task)
    }
    
}

// MARK: - 目标进度
extension CDGoalPlan {
    
    /// 根据目标任务重新计算并持久化当前目标的进度
    /// 计算规则：按任务权重对每个任务的进度分数取加权平均，结果限制在 0.0~1.0
    /// - Returns: 进度是否发生改变
    @discardableResult
    func updateProgress() -> Bool {
        let newProgress = CDGoalPlan.progress(of: tasks?.allObjects as? [CDGoalTask])
        guard abs(self.progress - newProgress) > 0.00001 else {
            return false
        }
        
        self.progress = newProgress
        return true
    }
    
    /// 计算一组目标任务的整体进度（按任务 weight 加权）
    static func progress(of cdTasks: [CDGoalTask]?) -> Double {
        guard let tasks = cdTasks, tasks.count > 0 else {
            return 0.0
        }
        
        var weightedSum = 0.0
        var weightSum = 0.0
        for task in tasks {
            /// 权重最小按 1 计，避免除数为 0
            let weight = Double(max(Int64(task.weight), 1))
            weightedSum += weight * taskProgress(of: task)
            weightSum += weight
        }
        
        guard weightSum > 0 else {
            return 0.0
        }
        
        return min(max(weightedSum / weightSum, 0.0), 1.0)
    }
    
    /// 单个任务进度（已完成任务计 1；无有效数值区间的未完成任务计 0；否则按 (current-initial)/(target-initial) 截断到 0~1）
    private static func taskProgress(of task: CDGoalTask) -> Double {
        if task.isCompleted {
            return 1.0
        }
        
        let initialValue = task.initialValue
        let targetValue = task.targetValue
        guard initialValue != targetValue else {
            return 0.0
        }
        
        let fraction = Double(task.currentValue - initialValue) / Double(targetValue - initialValue)
        return min(max(fraction, 0.0), 1.0)
    }
}

extension GoalPlan {
    
    /// 根据 CoreData 目标计划创建模型
    convenience init(content: CDGoalPlan) {
        self.init(identifier: content.identifier ?? UUID().uuidString,
                  order: content.order,
                  name: content.name,
                  color: content.color ?? GoalConfig.goalPlanDefaultColor,
                  startDate: content.startDate,
                  endDate: content.endDate,
                  note: content.note,
                  progress: content.progress,
                  isArchived: content.isArchived,
                  modificationDate: content.modificationDate)
    }
}

/// 获取目标计划
extension CDGoalPlan {
    
    // MARK: - Predicate
    static var activeGoalPlansPredicateCondition: PredicateCondition {
        return (GoalPlanKey.isArchived, .notEqual(true))
    }
    
    static var archivedGoalPlansPredicateCondition: PredicateCondition {
        return (GoalPlanKey.isArchived, .isTrue)
    }
    
    // MARK: - 异步获取
    static func fetchActiveGoalPlans(completion: @escaping([CDGoalPlan]?) -> Void) {
        let predicate = NSPredicate.predicate(with: activeGoalPlansPredicateCondition)
        CDGoalPlan.fetchAll(matching: predicate,
                            sortBy: ElementOrderKey,
                            ascending: true) { results in
            completion(results as? [CDGoalPlan])
        }
    }
    
    static func fetchArchivedGoalPlans(completion: @escaping([CDGoalPlan]?) -> Void) {
        let predicate = NSPredicate.predicate(with: archivedGoalPlansPredicateCondition)
        CDGoalPlan.fetchAll(matching: predicate,
                            sortBy: ElementOrderKey,
                            ascending: true) { results in
            completion(results as? [CDGoalPlan])
        }
    }
    
    // MARK: - 同步获取
    /// 获取特定标识的目标计划
    static func getGoalPlan(withIdentifier identifier: String) -> CDGoalPlan? {
        let condition: PredicateCondition = (GoalPlanKey.identifier, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        let goalPlan = CDGoalPlan.getFirst(matching: predicate, in: .defaultContext)
        return goalPlan
    }
    
    /// 同步获取所有目标计划
    static func getAllGoalPlans() -> [CDGoalPlan]? {
        let goalPlans: [CDGoalPlan]? = CDGoalPlan.getAll(sortBy: ElementOrderKey,
                                                          ascending: true,
                                                          in: .defaultContext)
        return goalPlans
    }
    
    /// 获取所有活动目标计划
    static func getActiveGoalPlans() -> [CDGoalPlan]? {
        return getGoalPlans(withCondition: activeGoalPlansPredicateCondition)
    }
    
    /// 获取所有已归档目标计划
    static func getArchivedGoalPlans() -> [CDGoalPlan]? {
        return getGoalPlans(withCondition: archivedGoalPlansPredicateCondition)
    }
    
    private static func getGoalPlans(withCondition condition: PredicateCondition) -> [CDGoalPlan]? {
        let predicate = NSPredicate.predicate(with: condition)
        let goalPlans: [CDGoalPlan]? = CDGoalPlan.getAll(matching: predicate,
                                                         sortBy: ElementOrderKey,
                                                         ascending: true,
                                                         in: .defaultContext)
        return goalPlans
    }
    
    /// 获取已归档目标计划数目
    static func numberOfArchivedGoalPlans() -> Int {
        let condition: PredicateCondition = (GoalPlanKey.isArchived, .isTrue)
        let predicate = NSPredicate.predicate(with: condition)
        let count = CDGoalPlan.countOfEntries(with: predicate, in: .defaultContext)
        return count
    }
    
    // MARK: - 异步搜索
    /// 搜索活动目标计划
    static func searchActiveGoalPlans(containText text: String,
                                      completion: (@escaping([CDGoalPlan]?) -> Void)) {
        let conditions: [PredicateCondition] = [(GoalPlanKey.isArchived, .isFalse),
                                                (GoalPlanKey.name, .contains(text))]
        let predicate = conditions.andPredicate()
        CDGoalPlan.fetchAll(matching: predicate, sortBy: ElementOrderKey, ascending: true) { results in
            let goalPlans = results as? [CDGoalPlan]
            completion(goalPlans)
        }
    }
}

extension Array where Element == CDGoalPlan {
    
    /// 所有标识
    var identifiers: [String] {
        var results = [String]()
        for goalPlan in self {
            if let identifier = goalPlan.identifier {
                results.append(identifier)
            }
        }
        
        return results
    }
    
    var toGoalPlans: [GoalPlan] {
        return self.map { GoalPlan(content: $0) }
    }
}
