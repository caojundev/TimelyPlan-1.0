//
//  TPKeyboardAwareController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/4.
//

import Foundation
import UIKit

class TPKeyboardAwareView: UIView {
    
    /// 内容尺寸改变回调
    var contentSizeDidChange: (() -> Void)?
    
    /// 内容尺寸
    var contentSize: CGSize = .zero {
        didSet {
            if contentSize != oldValue {
                contentSizeDidChange?()
            }
        }
    }
}

protocol TPKeyboardAwareControllerDelegate: AnyObject {
    
    func keyboardAwareController(controller: TPKeyboardAwareController,
                                 inputViewFrameDidChange fromFrame: CGRect)
    
    func keyboardAwareControllerDidHideInputView(controller: TPKeyboardAwareController)
}

extension TPKeyboardAwareControllerDelegate {
    func keyboardAwareController(controller: TPKeyboardAwareController,
                                 inputViewFrameDidChange fromFrame: CGRect) {}
    
    func keyboardAwareControllerDidHideInputView(controller: TPKeyboardAwareController) {}
}

class TPKeyboardAwareController: NSObject {
    
    /// 代理对象
    weak var delegate: TPKeyboardAwareControllerDelegate?
    
    /// 内容视图
    private(set) var inputView: TPKeyboardAwareView?

    /// 遮罩视图
    private lazy var maskView: UIView = {
        let view = UIView()
        view.backgroundColor = Color(0x000000, 0.4)
        view.alpha = 1.0
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMaskView))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        view.addGestureRecognizer(gesture)
        return view
    }()

    /// 键盘尺寸
    private var keyboardFrame: CGRect?
    
    /// 容器视图控制器
    private weak var containerViewController: UIViewController?

    init(containerViewController: UIViewController) {
        self.containerViewController = containerViewController
        super.init()
        addFrameObserver()
        addKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
        removeFrameObserver()
    }
    
    /// 子类重写创建新的输入视图
    func newInputView() -> TPKeyboardAwareView? {
        return nil
    }
    
    // MARK: - Observer
    func addFrameObserver() {
        containerViewController?.view.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }

    func removeFrameObserver() {
        containerViewController?.view.removeObserver(self, forKeyPath: "frame")
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        adjustInputViewForKeyboard()
    }
    
    private func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillShow(_:)),
                                             name: UIResponder.keyboardWillShowNotification,
                                             object: nil)
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(keyboardWillHide(_:)),
                                             name: UIResponder.keyboardWillHideNotification,
                                             object: nil)
    }

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let inputView = inputView, inputView.isDescendantFirstResponder,
              let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            self.keyboardFrame = keyboardFrame
        } else {
            self.keyboardFrame = nil
        }
        
        self.adjustInputViewForKeyboard()
    }
      
    @objc private func keyboardWillHide(_ notification: Notification) {
        self.keyboardFrame = nil
        self.adjustInputViewForKeyboard()
    }
    
    private func adjustInputViewForKeyboard() {
        guard let inputView = inputView, inputView.superview != nil,
              let containerView = containerViewController?.view else {
            return
        }
        
        maskView.frame = containerView.bounds
        
        /// 输入视图布局
        let oldFrame = inputView.frame
        let contentSize = inputView.contentSize
        inputView.width = containerView.width

        if let keyboardFrame = keyboardFrame {
            let convertedContainerFrame = containerView.convert(containerView.bounds, toViewOrWindow: nil)
            let intersectionFrame = keyboardFrame.intersection(convertedContainerFrame)
            inputView.height = contentSize.height
            inputView.bottom = containerView.height - intersectionFrame.height
            
            maskView.isUserInteractionEnabled = true
            maskView.alpha = 1.0
        } else {
            inputView.height = contentSize.height
            inputView.top = containerView.height
            maskView.isUserInteractionEnabled = false
            maskView.alpha = 0.0
        }
        
        if inputView.frame != oldFrame {
            inputViewFrameDidChange(fromFrame: oldFrame)
        }
    }
    
    // MARK: - Event Response
    @objc func didTapMaskView() {
        hideInputView()
    }
    
    /// 输入视图Frame改变
    func inputViewFrameDidChange(fromFrame: CGRect) {
        delegate?.keyboardAwareController(controller: self, inputViewFrameDidChange: fromFrame)
    }
    
    func showInputView() {
        guard let containerView = containerViewController?.view else {
            return
        }

        if inputView == nil {
            inputView = newInputView()
            inputView?.contentSizeDidChange = { [weak self] in
                self?.adjustInputViewForKeyboard()
            }
        }
        
        guard let inputView = inputView else {
            return
        }
        
        maskView.alpha = 0.0
        containerView.addSubview(maskView)
        containerView.addSubview(inputView)
        adjustInputViewForKeyboard()
        containerView.layoutIfNeeded()
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseInOut) {
            self.adjustInputViewForKeyboard()
        }
    }
    
    func hideInputView() {
        guard let containerView = containerViewController?.view, let inputView = inputView else {
            return
        }
        
        /// inputView 置为 nil
        self.inputView = nil
        
        if inputView.isDescendantFirstResponder {
            UIResponder.resignCurrentFirstResponder()
        }
    
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       options: .curveEaseInOut) {
            self.maskView.alpha = 0.0
            inputView.top = containerView.bounds.height
        } completion: { _ in
            inputView.removeFromSuperview()
            self.maskView.removeFromSuperview()
            self.delegate?.keyboardAwareControllerDidHideInputView(controller: self)
        }
    }
}
