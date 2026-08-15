//
//  TodoTaskEditStepSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/30.
//

import Foundation
import UIKit

class TodoTaskEditStepSectionController: TodoStepEditSectionController {
    
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
    
    // MARK: - 任务步骤菜单操作
    func performTaskStepBulkMenuAction(with type: TodoTaskStepBulkMenuActionType) {
        print(type)
        switch type {
        case .importSteps:
            importSteps()
        case .copyStepsAsMarkdown:
            copyStepsAsMarkdown()
        case .deleteCompletedSteps:
            confirmCompletedStepsDeletion()
        }
    }
    
    private func importSteps() {
        TodoPresenter.showStepImporter { steps in
            self.steps.append(contentsOf: steps)
            self.adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
            self.stepsDidChange()
        }
    }
    
    private func copyStepsAsMarkdown() {
        guard let steps = interactor.task.steps, steps.count > 0 else {
            return
        }
        
        if let markdown = steps.markdown(forceExpanded: true), markdown.count > 0 {
            UIPasteboard.general.string = markdown
            let message = resGetString("All steps copied as Markdown")
            TPFeedbackQueue.common.postFeedback(text: message, position: .top)
        }
    }
    
    func confirmCompletedStepsDeletion() {
        guard self.steps.completedCount() > 0 else {
            return
        }
        
        let deleteAction = TPAlertAction(type: .destructive, title: resGetString("Delete")) { action in
            self.deleteCompletedSteps()
        }
        
        let cancelAction = TPAlertAction(type: .cancel, title: resGetString("Cancel"))
        let message = resGetString("All completed steps and their substeps will be permanently deleted.")
        let alertController = TPAlertController(title: resGetString("Delete Completed Steps"),
                                                message: message,
                                                actions: [cancelAction, deleteAction])
        alertController.show()
    }
    
    
    private func deleteCompletedSteps() {
        var steps = steps
        let completedSteps = steps.getAllCompletedSteps()
        for completedStep in completedSteps {
            if let parent = completedStep.parent {
                parent.removeSubStep(completedStep)
            } else {
                steps.remove(completedStep)
            }
        }
    
        self.steps = steps
        adapter?.performSectionUpdate(forSectionObject: self, rowAnimation: .top)
        stepsDidChange()
    }

}
