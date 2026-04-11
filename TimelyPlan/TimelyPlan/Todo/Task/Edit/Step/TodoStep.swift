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
