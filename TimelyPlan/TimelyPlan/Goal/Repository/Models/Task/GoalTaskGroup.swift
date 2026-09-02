//
//  GoalTaskGroup.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/2.
//

import Foundation

/// 目标任务分组
class GoalTaskGroup: NSObject, GroupRepresentable {
    
    /// 分组唯一标识
    let identifier: String
    
    /// 分组标题
    var title: String?
    
    /// 分组内目标任务
    var goalTasks: [GoalTask]?
    
    /// 分组内是否包含目标任务
    var hasTasks: Bool {
        if let goalTasks = goalTasks, goalTasks.count > 0 {
            return true
        }
        
        return false
    }
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    /// 获取索引处的目标任务
    func goalTask(at index: Int) -> GoalTask? {
        guard let goalTasks = goalTasks, goalTasks.count > 0, index < goalTasks.count else {
            return nil
        }
        
        return goalTasks[index]
    }
    
    func index(of goalTask: GoalTask) -> Int? {
        guard let goalTasks = goalTasks, goalTasks.count > 0 else {
            return nil
        }
        
        return goalTasks.firstIndex(of: goalTask)
    }
    
    // MARK: - GroupRepresentable
    var items: [ListDiffable]? {
        return self.goalTasks
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GoalTaskGroup else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? GoalTaskGroup else {
            return false
        }
        
        return identifier == object.identifier
    }
}

extension Array where Element == GoalTaskGroup {
    
    /// 所有标识
    var identifiers: [String] {
        return self.map { $0.identifier }
    }
    
    /// 所有目标任务
    var allGoalTasks: [GoalTask] {
        var results = [GoalTask]()
        for group in self {
            if let goalTasks = group.goalTasks, goalTasks.count > 0 {
                results.append(contentsOf: goalTasks)
            }
        }
        
        return results
    }
}
