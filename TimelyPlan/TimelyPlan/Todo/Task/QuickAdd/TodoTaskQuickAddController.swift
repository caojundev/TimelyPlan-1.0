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
    
    /// 源任务
    let task: TodoQuickAddTask
    
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
        let quickAddTask = quickAddView.editTask
        guard quickAddTask.isValid else {
            return
        }
        
        todo.createTask(with: quickAddTask)
        
        /// 重置任务
        quickAddView.reset(with: task)
        
        if !TodoSetting.shared.quickAddContinuously {
            endEditing()
        }
    }
}
