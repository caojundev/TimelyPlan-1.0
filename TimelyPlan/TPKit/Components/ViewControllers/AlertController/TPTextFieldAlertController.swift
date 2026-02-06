//
//  TPTextFieldAlertController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/28.
//

import Foundation
import UIKit

class TPTextFieldWrapperView: UIView {
    
    /// 文本视图
    lazy var textField: TPTextField = {
        let textField = TPTextField()
        textField.font = BOLD_SYSTEM_FONT
        textField.textColor = .secondaryLabel
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .none
        textField.returnKeyType = .done
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(textField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textField.frame = layoutFrame()
    }
    
}

class TPTextFieldAlertController: TPAlertController,
                                  UITextFieldDelegate {

    /// 当前文本
    var text: String? {
        get {
            return textField.text?.whitespacesAndNewlinesTrimmedString
        }
        
        set {
            textField.text = newValue
            updateDoneActionEnabled()
        }
    }
    
    var placeholder: String? {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    /// 点击键盘return后是否结束编辑
    var completeAfterReturn: Bool = true

    /// 开始编辑时是否选择所有文本
    var selectAllAtBeginning: Bool = true
    
    /// 文本编辑结束
    var didEndEditingText: ((String?) -> Void)?
    
    /// 文本封装视图
    lazy var wrapperView: TPTextFieldWrapperView = {
        let wrapperView = TPTextFieldWrapperView()
        wrapperView.padding = UIEdgeInsets(left: 12.0, right: 12.0)
        wrapperView.textField.delegate = self
        wrapperView.textField.addTarget(self,
                                        action: #selector(textFieldEditingChanged(_:)),
                                        for: .editingChanged)
        return wrapperView
    }()
    
    /// 文本视图
    var textField: TPTextField {
        return wrapperView.textField
    }
    
    convenience init() {
        self.init(title: nil, message: nil, style: .alert, actions: nil)
    }
    
    convenience init(title: String?, completion: ((String?) -> Void)?) {
        self.init(title: title, message: nil, style: .alert, actions: nil)
        self.didEndEditingText = completion
    }
    
    override init(title: String?, message: String?, style: TPAlertController.Style, actions: [TPAlertAction]?) {
        super.init(title: title, message: message, style: style, actions: actions)
        self.additionalView = wrapperView
        self.additionalSize = CGSize(width: .greatestFiniteMagnitude, height: 55.0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDoneActionEnabled()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        wrapperView.backgroundColor = .secondarySystemBackground
        wrapperView.layer.cornerRadius = 12.0
    }

    override func handleFirstAppearance() {
        super.handleFirstAppearance()
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    
    override func clickDone() {
        TPImpactFeedback.impactWithSoftStyle()
        /// 取消第一响应者
        UIResponder.resignCurrentFirstResponder()
        if doneAlertAction.handleBeforeDismiss {
            didEndEditing()
            dismiss(animated: true, completion: nil)
        } else {
            dismiss(animated: true) {
                self.didEndEditing()
            }
        }
    }
   
    func didEndEditing() {
        if let text = self.text, text.count > 0 {
            didEndEditingText?(text)
        }
    }
    
    func updateDoneActionEnabled() {
        var isEnabled = false
        if let text = self.text, text.count > 0 {
            isEnabled = true
        }
        
        doneAlertAction.isEnabled = isEnabled
    }
    
    // MARK: - Event Response
    @objc func textFieldEditingChanged(_ textField: UITextField) {
        updateDoneActionEnabled()
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if completeAfterReturn && doneAction.isEnabled {
            clickDone()
        }
        
        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if selectAllAtBeginning {
            textField.perform(#selector(UITextField.selectAll(_:)),
                              with: textField,
                              afterDelay: 0.1)
        }
    }
}
