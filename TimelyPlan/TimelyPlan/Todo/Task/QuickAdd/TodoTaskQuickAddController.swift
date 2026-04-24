//
//  TodoTaskQuickAddController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/20.
//

import Foundation
import UIKit

class TodoTaskQuickAddController: TPKeyboardAwareController,
                                  TodoTaskQuickAddViewDelegate {
    
    /// 添加视图
    let addView: TodoTaskQuickAddView
    
    var editingTask: TodoQuickAddTask {
        return addView.editTask
    }
    
    /// 源任务
    private let task: TodoQuickAddTask
    
    init(containerViewController: UIViewController, task: TodoQuickAddTask) {
        self.task = task
        self.addView = TodoTaskQuickAddView(task: task)
        super.init(containerViewController: containerViewController)
        self.maskBackgroundColor = .clear
        self.addView.delegate = self
    }
    
    override func newInputView() -> TPKeyboardAwareView? {
        return addView
    }
    
    func beginEditing() {
        showInputView()
        addView.beginNameEditing()
    }
    
    func endEditing() {
        hideInputView()
    }
    
    // MARK: - TodoTaskQuickAddViewDelegate
    func todoTaskQuickAddViewDidClickSend(_ quickAddView: TodoTaskQuickAddView) {
        NotificationCenter.default.post(name: .hidePopoverView, object: nil)
        let quickAddTask = editingTask
        guard quickAddTask.isValid else {
            return
        }
        
        todo.createTask(with: quickAddTask)
        quickAddView.reset(with: task)
        if !TodoSetting.shared.quickAddContinuously {
            endEditing()
        }
    }
}
