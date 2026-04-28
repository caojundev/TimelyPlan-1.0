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
        
        return subSteps.allSatisfy { $0.isCompleted }
    }
    
    func notCompletedSubSteps() -> [TodoStep]? {
        let allSubSteps = subSteps.flatten()
        let results = allSubSteps.filter { !($0.isCompleted) }
        return results.isEmpty ? nil : results
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(id)
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

extension TodoStep {
    
    /// 扁平化遍历所有步骤（包括自己和所有子步骤）
    func flatten() -> [TodoStep] {
        var result: [TodoStep] = [self]
        for subStep in subSteps {
            result.append(contentsOf: subStep.flatten())
        }
        return result
    }
    
    /// 获取所有步骤的总数
    func totalCount() -> Int {
        return flatten().count
    }
    
    /// 获取已完成的步骤数
    func completedCount() -> Int {
        return flatten().filter { $0.isCompleted }.count
    }
}

extension Array where Element == TodoStep {
    /// 扁平化数组中所有步骤
    func flatten() -> [TodoStep] {
        return self.flatMap { $0.flatten() }
    }
    
    /// 获取所有步骤的总数
    func totalCount() -> Int {
        return flatten().count
    }
    
    /// 获取已完成的步骤数
    func completedCount() -> Int {
        return flatten().filter { $0.isCompleted }.count
    }
    
    func markdown() -> String? {
        let parser = TodoStepParser()
        return parser.toMarkdown(self)
    }
}
