//
//  TodoTaskQuickAddManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/26.
//

import Foundation
import UIKit

class TodoTaskQuickAddManager: TPKeyboardAwareControllerDelegate {
    
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
        if addController == controller {
            /// 将控制器设置为空
            addController = nil
        }
    }
    
}
