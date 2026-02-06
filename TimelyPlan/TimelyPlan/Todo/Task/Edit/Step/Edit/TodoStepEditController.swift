//
//  TodoStepEditController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/4.
//

import Foundation
import UIKit

protocol TodoStepEditControllerDelegate: TPKeyboardAwareControllerDelegate {
    
    /// 点击Return
    func stepEditControllerDidEnterReturn(_ controller: TodoStepEditController)
}

class TodoStepEditController: TPKeyboardAwareController {
    
    /// 步骤添加位置
    var position: TodoStepAddPosition {
        get {
            return editView.position
        }
        
        set {
            editView.position = newValue
        }
    }
    
    var text: String? {
        get {
            return editView.textField.text
        }
        
        set {
            editView.textField.text = newValue
        }
    }
    
    lazy var editView: TodoStepEditView = {
        let view = TodoStepEditView()
        view.didEnterReturn = { [weak self] textField in
            self?.textFieldDidEnterReturn(textField)
        }
        
        return view
    }()
    
    override func newInputView() -> TPKeyboardAwareView? {
        return editView
    }
    
    override func didTapMaskView() {
        endEditing()
    }
    
    func beginEditing() {
        showInputView()
        editView.textField.becomeFirstResponder()
    }
    
    func endEditing() {
        editView.textField.resignFirstResponder()
        hideInputView()
    }
    
    func clearText() {
        editView.textField.text = nil
    }
    
    private func textFieldDidEnterReturn(_ textField: UITextField) {
        if let delegate = self.delegate as? TodoStepEditControllerDelegate {
            delegate.stepEditControllerDidEnterReturn(self)
        }
    }
}
