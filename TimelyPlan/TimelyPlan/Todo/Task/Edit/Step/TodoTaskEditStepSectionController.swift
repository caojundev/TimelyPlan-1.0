//
//  TodoTaskEditStepSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation
import UIKit

class TodoTaskEditStepSectionController: TodoStepInlineEditSectionController {
    
    let interactor: TodoTaskEditInteractor
    
    var task: TodoTask {
        return interactor.task
    }
    
    init(interactor: TodoTaskEditInteractor) {
        self.interactor = interactor
        let steps = interactor.task.steps ?? []
        super.init(steps: steps)
        self.setupSeparatorFooterItem()
        self.setSeparatorHidden(true)
    }
    
    func setSeparatorHidden(_ isHidden: Bool) {
        self.footerItem.height = isHidden ? 0.0 : 1.0
    }

    func updateSteps() {
        self.steps = interactor.task.steps ?? []
    }

    override func stepsDidChange() {
        interactor.setSteps(steps)
    }
    
    override func convertStepToTask(_ step: TodoStep) {
        /// 删除步骤
        deleteStep(step)
        
        /// 创建新任务
        let quickAddTask = TodoQuickAddTask()
        quickAddTask.name = step.content
        quickAddTask.steps = step.subSteps
        quickAddTask.section = task.section
        TodoRepository.createTask(with: quickAddTask)
    }
}
