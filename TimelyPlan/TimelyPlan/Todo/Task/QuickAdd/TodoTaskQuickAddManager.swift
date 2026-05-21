//
//  TodoTaskQuickAddManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/26.
//

import Foundation
import UIKit

struct TodoQuickAddOptions: Codable {
    
    /// 显示更多设置
    var showMoreSetting: Bool = true

    /// 禁止连续添加
    var forbidContinuousAdd: Bool = false
}

class TodoTaskQuickAddManager: TPKeyboardAwareControllerDelegate {
    
    /// 草稿任务
    private(set) var draftTask: TodoQuickAddTask?

    /// 输入视图 frame 改变
    var inputViewFrameDidChange: ((UIView?) -> Void)?
    
    /// 容器视图控制器
    weak var containerViewController: UIViewController?
    
    private let options: TodoQuickAddOptions
    
    init(containerViewController: UIViewController, options: TodoQuickAddOptions? = nil) {
        var viewController = containerViewController
        if let navigationController = containerViewController.navigationController {
            viewController = navigationController
        }
        
        self.options = options ?? TodoQuickAddOptions()
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

        let originTask = task ?? TodoQuickAddTask()
        var editingTask: TodoQuickAddTask
        if let draftTask = draftTask {
            editingTask = draftTask
        } else {
            editingTask = originTask
        }
        
        let addController = TodoTaskQuickAddController(containerViewController: vc,
                                                       originTask: originTask,
                                                       editingTask: editingTask,
                                                       options: options)
        addController.delegate = self
        addController.beginEditing()
        self.addController = addController
    }
    
    func dismiss() {
        addController?.endEditing()
        addController = nil
    }

    /// 清除草稿任务
    func clearDraftTask() {
        self.draftTask = nil
    }
    
    // MARK: - TPKeyboardAwareControllerDelegate
    func keyboardAwareControllerWillShowInputView(controller: TPKeyboardAwareController) {
        /// 清除草稿任务
        self.draftTask = nil
    }
    
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
