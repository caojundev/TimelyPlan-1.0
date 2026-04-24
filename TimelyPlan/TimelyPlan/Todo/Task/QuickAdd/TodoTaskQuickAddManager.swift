//
//  TodoTaskQuickAddManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/26.
//

import Foundation
import UIKit

class TodoTaskQuickAddManager: TPKeyboardAwareControllerDelegate {
    
    /// 草稿任务
    var draftTask: TodoQuickAddTask?
    
    /// 输入视图 frame 改变
    var inputViewFrameDidChange: ((UIView?) -> Void)?
    
    /// 容器视图控制器
    weak var containerViewController: UIViewController?
    
    init(containerViewController: UIViewController) {
        var viewController = containerViewController
        if let navigationController = containerViewController.navigationController {
            viewController = navigationController
        }
        
        self.containerViewController = viewController
    }
    
    private var addController: TodoTaskQuickAddController?
    
    func show(with task: TodoQuickAddTask? = nil) {
        if let addController = addController {
            addController.endEditing()
        }
        
        guard let vc = containerViewController else {
            return
        }

        let task = task ?? TodoQuickAddTask()
        let addController = TodoTaskQuickAddController(containerViewController: vc, task: task)
        addController.delegate = self
        addController.beginEditing()
        self.addController = addController
    }
    
    func dismiss() {
        addController?.endEditing()
        addController = nil
    }

    // MARK: - TPKeyboardAwareControllerDelegate
    func keyboardAwareControllerDidHideInputView(controller: TPKeyboardAwareController) {
        if controller == self.addController {
            var task: TodoQuickAddTask?
            if TodoSetting.shared.quickAddKeepContentWhenHidden {
                if let editingTask = self.addController?.editingTask, editingTask.isValid {
                    task = editingTask
                }
            }
            
            self.draftTask = task
            
            /// 将控制器设置为空
            self.addController = nil
        }
        
        inputViewFrameDidChange?(controller.inputView)
    }
    
    func keyboardAwareControllerDidShowInputView(controller: TPKeyboardAwareController) {
        inputViewFrameDidChange?(controller.inputView)
    }
    
    func keyboardAwareController(controller: TPKeyboardAwareController, inputViewFrameDidChange fromFrame: CGRect) {
        inputViewFrameDidChange?(controller.inputView)
    }
}
