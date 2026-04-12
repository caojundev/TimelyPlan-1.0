//
//  TodoStep.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/11.
//

import Foundation

class TodoStep: NSObject {
    var id: String
    var content: String
    var isCompleted: Bool
    var isExpanded: Bool = true  // 默认展开，后续根据子步骤缩进推断
    var subSteps: [TodoStep] = []
    weak var parent: TodoStep?
    
    init(content: String,
         isCompleted: Bool) {
        self.id = UUID().uuidString
        self.content = content
        self.isCompleted = isCompleted
    }
    
    func insertSubStep(_ step: TodoStep, at index: Int) {
        if let oldParent = step.parent {
            oldParent.removeSubStep(step)
        }
            
        self.subSteps.insert(step, at: index)
        step.parent = self
    }
    
    func moveSubStep(_ step: TodoStep, to index: Int) {
        guard let fromIndex = subSteps.indexOf(step) else {
            return
        }
        
        subSteps.moveObject(fromIndex: fromIndex, toIndex: index)
    }
    
    func addSubStep(_ step: TodoStep) {
        self.insertSubStep(step, at: subSteps.count)
    }
    
    func removeSubStep(_ step: TodoStep) {
        guard self.subSteps.contains(step) else {
            return
        }
        
        self.subSteps.remove(step)
        step.parent = nil
    }
    
    func isAllSubStepsCompleted() -> Bool {
        guard subSteps.count > 0 else {
            return false
        }
        
        var isAllCompleted = true
        for subStep in subSteps {
            if !subStep.isCompleted {
                isAllCompleted = false
                break
            }
        }
        
        return isAllCompleted
    }
    
    func notCompletedSubSteps() -> [TodoStep]? {
        var results = [TodoStep]()
        for step in subSteps {
            if !step.isCompleted {
                results.append(step)
            }
        }
        
        if results.count > 0 {
            return results
        }
        
        return nil
    }
    
    /*
    func completeAllSubSteps() -> [TodoStep]? {
        var updatedSteps = [TodoStep]()
        for step in subSteps {
            if !step.isCompleted {
                step.isCompleted = true
                updatedSteps.append(step)
            }
        }
        
        if updatedSteps.count > 0 {
            return updatedSteps
        }
        
        return nil
    }
     */
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(id)
        hasher.combine(content)
        hasher.combine(isCompleted)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? TodoStep else { return false }
        if self === other { return true }
        return id == other.id &&
            content == other.content &&
            isCompleted == other.isCompleted
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return self.id as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return self.isEqual(object)
    }
}

// MARK: - Nestable
extension TodoStep: Nestable {
    
    static var allowMaxDepth: Int {
        return kTodoStepMaxDepth
    }
    
    var parentItem: Nestable? {
        return self.parent
    }
    
    var subItems: [Nestable]? {
        return self.subSteps
    }
    
    var orderedSubItems: [Nestable]? {
        return self.subSteps
    }
}
