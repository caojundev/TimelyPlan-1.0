//
//  TodoTaskStepBulkMenuProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/27.
//

import Foundation

class TodoTaskStepBulkMenuProcessor {
    
    var didEndImporting: (([TodoStep]) -> Void)?
    
    /// 删除已完成步骤后的回调（参数为删除后剩余的步骤）
    var didEndDeletingCompletedSteps: (([TodoStep]) -> Void)?
     
    private var steps: [TodoStep]
    
    init(steps: [TodoStep]) {
        self.steps = steps
    }
    
    // MARK: - 任务步骤菜单操作
    func performMenuAction(with type: TodoTaskStepBulkMenuActionType) {
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
            self.didEndImporting?(steps)
        }
    }

    private func copyStepsAsMarkdown() {
        guard steps.count > 0 else {
            return
        }
        
        if let markdown = steps.markdown(forceExpanded: true), markdown.count > 0 {
            UIPasteboard.general.string = markdown
            let message = resGetString("All steps copied as Markdown")
            TPFeedbackQueue.common.postFeedback(text: message, position: .top)
        }
    }

    func confirmCompletedStepsDeletion() {
        guard steps.completedCount() > 0 else {
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
        
        // 通知外部（用于刷新 UI、持久化等）
        didEndDeletingCompletedSteps?(steps)
    }
}
