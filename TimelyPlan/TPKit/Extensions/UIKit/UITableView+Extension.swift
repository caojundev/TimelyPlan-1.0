//
//  UITableView+Extension.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/15.
//

import Foundation
import UIKit

extension UITableView {
    
    private struct AssociatedKeys {
        static var placeholderView = "placeholderView"
        static var keyboardIntersectionBottom = "keyboardIntersectionBottom"
        static var shouldShowPlaceholder = "shouldShowPlaceholder"
    }
    
    /// 占位视图
    var placeholderView: UIView? {
        get {
            return associated.get(&AssociatedKeys.placeholderView)
        }
        
        set {
            associated.set(retain: &AssociatedKeys.placeholderView, newValue)
        }
    }
    
    var shouldShowPlaceholder: (() -> Bool)? {
        get {
            return associated.get(&AssociatedKeys.shouldShowPlaceholder)
        }
        
        set {
            associated.set(retain: &AssociatedKeys.shouldShowPlaceholder, newValue)
        }
    }
    
    /// 键盘与tableView相交区域底部高度
    private var keyboardIntersectionBottom: CGFloat {
        get {
            let value: CGFloat = associated.get(&AssociatedKeys.keyboardIntersectionBottom) ?? 0.0
            return value
        }
        
        set {
            associated.set(retain: &AssociatedKeys.keyboardIntersectionBottom, newValue)
        }
    }
    
    static func swizzleUITableViewMethods() {
        swizzleInstanceMethod(UITableView.self,
                              #selector(layoutSubviews),
                              #selector(tf_UITableViewLayoutSubviews))
        swizzleInstanceMethod(UITableView.self,
                              #selector(reloadData),
                              #selector(tf_reloadData))
        swizzleInstanceMethod(UITableView.self,
                              #selector(reloadSections(_:with:)),
                              #selector(tf_reloadSections(_:with:)))
        swizzleInstanceMethod(UITableView.self,
                              #selector(insertSections(_:with:)),
                              #selector(tf_insertSections(_:with:)))
        swizzleInstanceMethod(UITableView.self,
                              #selector(deleteSections(_:with:)),
                              #selector(tf_deleteSections(_:with:)))
        swizzleInstanceMethod(UITableView.self,
                              #selector(insertRows(at:with:)),
                              #selector(tf_insertRows(at:with:)))
        swizzleInstanceMethod(UITableView.self,
                              #selector(deleteRows(at:with:)),
                              #selector(tf_deleteRows(at:with:)))
        swizzleInstanceMethod(UITableView.self,
                              #selector(performBatchUpdates(_:completion:)),
                              #selector(tf_performBatchUpdates(_:completion:)))
    }
    
    
    @objc func tf_UITableViewLayoutSubviews() {
        self.tf_UITableViewLayoutSubviews()
        self.tf_updateFrameOfPlaceholderView()
    }
    
    private func tf_updateFrameOfPlaceholderView() {
        /// 布局占位视图
        if let placeholderView = self.placeholderView, placeholderView.isDescendant(of: self) {
            let placeholderHeight = self.frame.height - self.keyboardIntersectionBottom
            let placeholderFrame = CGRect(x: 0,
                                          y: 0,
                                          width: self.frame.width,
                                          height: placeholderHeight)
            placeholderView.frame = placeholderFrame
            placeholderView.layoutIfNeeded()
        }
    }

    @objc func tf_reloadData() {
        self.tf_reloadData()
        self.tf_updatePlaceholder()
    }
    
    @objc func tf_reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        self.tf_reloadSections(sections, with: animation)
        tf_updatePlaceholder()
    }
    
    @objc func tf_insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        self.tf_insertSections(sections, with: animation)
        tf_updatePlaceholder()
    }
    
    @objc func tf_deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        self.tf_deleteSections(sections, with: animation)
        tf_updatePlaceholder()
    }
    
    @objc func tf_insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        self.tf_insertRows(at: indexPaths, with: animation)
        tf_updatePlaceholder()
    }
    
    @objc func tf_deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        self.tf_deleteRows(at: indexPaths, with: animation)
        tf_updatePlaceholder()
    }
    
    @objc func tf_performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        self.tf_performBatchUpdates(updates, completion: completion)
        tf_updatePlaceholder()
    }
    
    /// 是否有行
    var hasRow: Bool {
        var hasRow = false
        let sectionsCount = self.dataSource?.numberOfSections?(in: self) ?? 0
        if sectionsCount > 0 {
            for i in 0..<sectionsCount {
                let itemsCount = self.dataSource?.tableView(self, numberOfRowsInSection: i) ?? 0
                if itemsCount > 0 {
                    hasRow = true
                    break
                }
            }
        }
        
        return hasRow
    }
    
    func tf_updatePlaceholder() {
        var bShowPlaceholder = false
        if let shouldShowPlaceholder = self.shouldShowPlaceholder {
            bShowPlaceholder = shouldShowPlaceholder()
        } else {
            bShowPlaceholder = !hasRow
        }
        
        if bShowPlaceholder {
            self.tf_showPlaceholderView()
        } else {
            self.tf_hidePlaceholderView()
        }
    }
    
    private func tf_showPlaceholderView() {
        if let placeholderView = placeholderView {
            self.addSubview(placeholderView)
        }
    }
    
    private func tf_hidePlaceholderView() {
        placeholderView?.removeFromSuperview()
    }
    
    private var isPlaceholderShown: Bool {
        if let placeholderView = placeholderView, placeholderView.isDescendant(of: self) {
            return true
        }
        
        return false
    }
    
    // MARK: - 键盘
    func addKeyboardNotification() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    func removeKeyboardNotification() {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        guard let tableSuperview = self.superview,
              let userInfo = notification.userInfo,
                let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let offsetY: CGFloat = 0.0
        /// 根据y间距调整键盘 frame 信息
        var keyboardFrame = frameValue.cgRectValue
        keyboardFrame.origin.y -= offsetY
        keyboardFrame.size.height += offsetY
        
        let convertedKeyboardFrame = tableSuperview.convert(keyboardFrame, fromViewOrWindow: nil)
        let intersectionFrame = convertedKeyboardFrame.intersection(self.frame)
        self.keyboardIntersectionBottom = intersectionFrame.height
        self.tf_animateUpdateFrameOfPlaceholder()
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardIntersectionBottom = 0.0
        self.tf_animateUpdateFrameOfPlaceholder()
    }

    private func tf_animateUpdateFrameOfPlaceholder() {
        if isPlaceholderShown {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .beginFromCurrentState, animations: {
                self.tf_updateFrameOfPlaceholderView()
            }, completion: nil)
        }
    }
}
