//
//  TodoTaskStepBulkMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/27.
//

import Foundation
import UIKit

class TodoTaskStepBulkMenuController: TPBaseMenuController<TodoTaskStepBulkMenuActionType> {
    
    let steps: [TodoStep]
    
    init(steps: [TodoStep]) {
        self.steps = steps
        super.init()
        self.menuContentWidth = 200.0
    }
    
    override func orderedMenuActionTypeLists() -> [Array<TodoTaskStepBulkMenuActionType>] {
        return [[.importSteps, .copyStepsAsMarkdown], [.deleteCompletedSteps]]
    }
    
    override func menuActionTypes() -> [TodoTaskStepBulkMenuActionType] {
        var types: [TodoTaskStepBulkMenuActionType] = [.importSteps]
        if steps.count > 0 {
            types.append(.copyStepsAsMarkdown)
        }
        
        if steps.completedCount() > 0 {
            types.append(.deleteCompletedSteps)
        }
        
        return types
    }
    
    override func updateMenuAction(_ action: TPMenuAction, for type: TodoTaskStepBulkMenuActionType) {
        if type == .copyStepsAsMarkdown {
            action.handleBeforeDismiss = true
        }
    }
}
