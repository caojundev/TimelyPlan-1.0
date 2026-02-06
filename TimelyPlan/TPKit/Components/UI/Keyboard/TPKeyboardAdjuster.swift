//
//  TPKeyboardAdjuster.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/1.
//

import Foundation
import UIKit

class TPKeyboardAdjuster {

    /// 绑定的滚动视图
    private weak var scrollView: UIScrollView!
    
    /// 键盘区域
    private var keyboardFrame: CGRect?
    
    var offsetY: CGFloat = 20.0
    
    var initialContentInset: UIEdgeInsets = .zero
    
    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                addKeyboardNotification()
            } else {
                removeKeyboardNotification()
            }
        }
    }
    
    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
    }
    
    deinit {
        if isEnabled {
            removeKeyboardNotification()
        }
    }
    
    private func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardDidShow(_:)),
                                               name: UIResponder.keyboardDidShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
    
    private func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        guard scrollView.isDescendantFirstResponder else {
            return
        }
        
        self.keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        self.adjustForKeyboard()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard scrollView.isDescendantFirstResponder else {
            return
        }
        
        self.keyboardFrame = nil
        self.adjustForKeyboard()
    }
  
    @objc func adjustForKeyboard() {
        guard let keyboardFrame = keyboardFrame else {
            scrollView.contentInset = initialContentInset
            return
        }

        var adjustedKeyboardRect = keyboardFrame
        adjustedKeyboardRect.origin.y -= offsetY
        adjustedKeyboardRect.size.height = .greatestFiniteMagnitude

        /// 当前视图与键盘相交的矩形
        let scrollRect = scrollView.convert(scrollView.bounds, toViewOrWindow: nil)
        let intersectionRect = scrollRect.intersection(adjustedKeyboardRect)
        if !intersectionRect.isNull {
            let intersectionHeight = intersectionRect.height
            var inset = initialContentInset
            if inset.bottom < intersectionHeight {
                inset.bottom = intersectionHeight
            }

            scrollView.contentInset = inset
        }
    }
}
