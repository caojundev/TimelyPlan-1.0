//
//  TodoStep+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation

/// 步骤改变
enum TodoStepChange {

    /// 名称
    case name(oldValue: String?, newValue: String?)
    
    /// 完成状态
    case completed(newValue: Bool)
}

extension TodoStep: Sortable {
    
    static func newStep(name: String? = nil) -> TodoStep {
        let newStep = TodoStep.createEntity(in: .defaultContext)
        newStep.identifier = UUID().uuidString
        newStep.name = name
        return newStep
    }
    
    static func newStep(with originalStep: TodoStep) -> TodoStep {
        let newStep = TodoStep.createEntity(in: .defaultContext)
        newStep.identifier = UUID().uuidString
        newStep.name = originalStep.name
        newStep.order = originalStep.order
        newStep.isCompleted = originalStep.isCompleted
        newStep.completionDate = originalStep.completionDate
        return newStep
    }
}

extension Array where Element == TodoStep {
    
    /// 完成步骤数目
    var completedCount: Int {
        var count = 0
        for step in self {
            if step.isCompleted {
                count += 1
            }
        }
        
        return count
    }
    
    /// 所有步骤名称数组
    var allStepNames: [String]? {
        var names = [String]()
        for step in self {
            if let name = step.name, name.count > 0 {
                names.append(name)
            }
        }
        
        if names.count > 0 {
            return names
        }
        
        return nil
    }
    
    /// 已完成步骤名称数组
    var doneStepNames: [String]? {
        var names = [String]()
        for step in self {
            if step.isCompleted, let name = step.name, name.count > 0 {
                names.append(name)
            }
        }
        
        if names.count > 0 {
            return names
        }
        
        return nil
    }
    
    /// 已完成步骤
    var doneSteps: [TodoStep]? {
        var steps = [TodoStep]()
        for step in self {
            if step.isCompleted {
                steps.append(step)
            }
        }
        
        if steps.count > 0 {
            return steps
        }
        
        return nil
    }
    
    /// 是否有完成步骤
    var hasDoneStep: Bool {
        for step in self {
            if step.isCompleted, let name = step.name, name.count > 0 {
                return true
            }
        }
        
        return false
    }
    
    /// 未完成步骤名称数组
    var undoneStepNames: [String]? {
        var names = [String]()
        for step in self {
            if !step.isCompleted, let name = step.name, name.count > 0 {
                names.append(name)
            }
        }
        
        if names.count > 0 {
            return names
        }
        
        return nil
    }
    
    /// 是否有未完成步骤
    var hasUndoneStep: Bool {
        for step in self {
            if !step.isCompleted, let name = step.name, name.count > 0 {
                return true
            }
        }
        
        return false
    }
}

extension Set where Element == TodoStep {
    
    /// 完成步骤数目
    var completedCount: Int {
        return Array(self).completedCount
    }
    
}
