//
//  FocusTimerStepEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/18.
//

import Foundation
import UIKit

class FocusTimerStepEditViewController: TPContainerViewController {
    
    /// 结束步骤编辑
    var didEndEditing: ((FocusTimerStep) -> Void)?
    
    /// 是否连续可以添加下一步
    var canContinuousAddNextStep: (() -> Bool)?
    
    /// 编辑类型
    let editType: EditType
    
    /// 初始步骤
    var originStep: FocusTimerStep?
    
    /// 当前编辑的步骤
    private var editingStep: FocusTimerStep {
        return editingViewController.step
    }
    
    private var editingViewController: FocusTimerStepEditContentViewController!
    
    /// 继续添加下一步按钮
    private var continueAddButton: TPDefaultButton?
    
    /// 移除键盘通知观察者
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    init(step: FocusTimerStep? = nil) {
        self.editType = step == nil ? .create : .modify
        self.originStep = step
        super.init(nibName: nil, bundle: nil)
        let step = step ?? FocusTimerStep()
        self.editingViewController = newEditViewController(with: step)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if editType == .create {
            self.title = resGetString("New Step")
        } else {
            self.title = resGetString("Edit Step")
        }
        
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        self.contentViewController = editingViewController
        
        setupContinueAddButton()
        setupKeyboardNotifications()
        updateDoneButtonEnabled()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let continueAddButton = continueAddButton else {
            return
        }
        
        continueAddButton.sizeToFit()
        continueAddButton.right = view.width - 16.0
        if keyboardHeight == 0.0 {
            continueAddButton.bottom = view.safeLayoutFrame().maxY - 16.0
        } else {
            continueAddButton.bottom = view.height - keyboardHeight - 5.0
        }
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        self.didEndEditing?(editingViewController.step)
        dismiss(animated: true, completion: nil)
    }
    
    /// 设置继续添加按钮
    private func setupContinueAddButton() {
        guard editType == .create else {
            return
        }
        
        let button = TPDefaultButton()
        button.cornerRadius = .greatestFiniteMagnitude
        button.padding = UIEdgeInsets(horizontal: 24.0, vertical: 16.0)
        button.title = resGetString("继续添加下一步")
        button.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        
        // 添加阴影效果
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        // 设置按钮点击事件
        button.addTarget(self, action: #selector(continueAddButtonTapped), for: .touchUpInside)
        view.addSubview(button)
        
        self.continueAddButton = button
    }
    
    /// 设置键盘通知
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    private var keyboardHeight: CGFloat = 0.0
    
    /// 键盘将要显示
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        self.keyboardHeight = keyboardFrame.height
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    /// 键盘将要隐藏
    @objc private func keyboardWillHide(_ notification: Notification) {
        self.keyboardHeight = 0.0
        let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval ?? 0.25
        let animationCurve = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt ?? 0
        UIView.animate(withDuration: animationDuration, delay: 0, options: UIView.AnimationOptions(rawValue: animationCurve), animations: {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        })
    }
    
    /// 继续添加按钮点击事件
    @objc private func continueAddButtonTapped() {
        // 先保存当前编辑的内容
        self.didEndEditing?(editingViewController.step)
        
        let step = FocusTimerStep()
        let editingVC = newEditViewController(with: step)
        self.editingViewController = editingVC
        self.setContentViewController(editingVC, withAnimationStyle: .rightToLeft)
        self.updateDoneButtonEnabled()
    }
    
    /// 更新完成按钮可用状态
    private func updateDoneButtonEnabled() {
        let isEnabled = !editingViewController.isEmptyName
        doneBarButtonItem.isEnabled = isEnabled
        
        let canAdd = canContinuousAddNextStep?() ?? false
        var alpha: CGFloat = 0.0
        if canAdd {
            alpha = isEnabled ? 1.0 : 0.0
        }
        
        self.continueAddButton?.isEnabled = canAdd && isEnabled
        UIView.animate(withDuration: 0.2) {
            self.continueAddButton?.alpha = alpha
        }
    }
    
    private func newEditViewController(with step: FocusTimerStep) -> FocusTimerStepEditContentViewController {
        let vc = FocusTimerStepEditContentViewController(step: step)
        vc.didChangeStepName = { [weak self] in
            self?.updateDoneButtonEnabled()
        }
        
        return vc
    }
    
}
