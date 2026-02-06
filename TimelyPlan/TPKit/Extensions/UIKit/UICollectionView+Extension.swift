//
//  UICollectionView+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/14.
//

import Foundation
import UIKit

extension UICollectionView {

    private struct AssociatedKeys {
        static var placeholderView = "placeholderView"
        static var shouldShowPlaceholder = "shouldShowPlaceholder"
        static var didUpdateHandler = "didUpdateHandler"

        static var keyboardIntersectionBottom = "keyboardIntersectionBottom"
        static var keyboardBeginContentInset = "keyboardBeginContentInset"
        static var keyboardAutoAdjustContentInset = "keyboardAutoAdjustContentInset"
    }
    
    /// 占位视图
    var placeholderView: UIView? {
        get {
            return associated.get(&AssociatedKeys.placeholderView)
        }
        
        set {
            /// 移除旧视图
            if let placeholderView = placeholderView {
                placeholderView.removeFromSuperview()
            }
 
            associated.set(retain: &AssociatedKeys.placeholderView, newValue)
            self.tp_updatePlaceholder()
        }
    }
    
    /// 列表更新时的回调
    var didUpdateHandler: (() -> Void)? {
        get {
            return associated.get(&AssociatedKeys.didUpdateHandler)
        }
        
        set {
            associated.set(retain: &AssociatedKeys.didUpdateHandler, newValue)
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
    
    /// 键盘弹出前初始内容间距
    var keyboardBeginContentInset: UIEdgeInsets {
        get {
            let contentInset: UIEdgeInsets = associated.get(&AssociatedKeys.keyboardBeginContentInset) ?? .zero
            return contentInset
        }
        
        set {
            associated.set(retain: &AssociatedKeys.keyboardBeginContentInset, newValue)
            self.setNeedsLayout()
        }
    }

    /// 是否自动调整内容间距
    var keyboardAutoAdjustContentInset: Bool {
        get {
            let bAutoAdjust : Bool = associated.get(&AssociatedKeys.keyboardAutoAdjustContentInset) ?? false
            return bAutoAdjust
        }
        
        set {
            associated.set(retain: &AssociatedKeys.keyboardAutoAdjustContentInset, newValue)
        }
    }
    
    /// 键盘与collection相交区域底部高度
    private var keyboardIntersectionBottom: CGFloat {
        get {
            let value: CGFloat = associated.get(&AssociatedKeys.keyboardIntersectionBottom) ?? 0.0
            return value
        }
        
        set {
            associated.set(retain: &AssociatedKeys.keyboardIntersectionBottom, newValue)
        }
    }
    
    static func swizzleUICollectionViewMethods() {
        swizzleInstanceMethod(UICollectionView.self,
                              #selector(layoutSubviews),
                              #selector(tp_UICollectionViewLayoutSubviews))
        swizzleInstanceMethod(UICollectionView.self,
                              #selector(reloadData),
                              #selector(tp_reloadData))
        swizzleInstanceMethod(UICollectionView.self,
                              #selector(reloadSections(_:)),
                              #selector(tp_reloadSections(_:)))
        swizzleInstanceMethod(UICollectionView.self,
                              #selector(insertItems(at:)),
                              #selector(tp_insertItems(at:)))
        swizzleInstanceMethod(UICollectionView.self,
                              #selector(deleteItems(at:)),
                              #selector(tp_deleteItems(at:)))
        swizzleInstanceMethod(UICollectionView.self,
                              #selector(performBatchUpdates(_:completion:)),
                              #selector(tp_performBatchUpdates(_:completion:)))
    }
    
    @objc func tp_UICollectionViewLayoutSubviews() {
        self.tp_UICollectionViewLayoutSubviews()
        self.tp_updateFrameOfPlaceholderView()
        self.tp_updateContentInset()
    }
    
    private func tp_updateFrameOfPlaceholderView() {
        /// 布局占位视图
        if let placeholderView = self.placeholderView, placeholderView.isDescendant(of: self) {
            let placeholderHeight = self.frame.size.height - self.safeAreaInsets.bottom - self.keyboardIntersectionBottom
            let placeholderFrame = CGRect(x: 0, y: 0, width: self.frame.width, height: placeholderHeight)
            placeholderView.frame = placeholderFrame
            placeholderView.layoutIfNeeded()
        }
    }
    
    private func tp_updateContentInset() {
        guard keyboardAutoAdjustContentInset else {
            return
        }

        var contentInset = keyboardBeginContentInset
        if contentInset.bottom < keyboardIntersectionBottom {
            contentInset.bottom = keyboardIntersectionBottom
        }
        
        self.contentInset = contentInset
    }

    @objc func tp_reloadData() {
        self.tp_reloadData()
        self.tp_update()
    }
    
    @objc func tp_reloadSections(_ sections: IndexSet) {
        self.tp_reloadSections(sections)
        self.tp_update()
    }
    
    @objc func tp_insertItems(at indexPaths: [IndexPath]) {
        self.tp_insertItems(at: indexPaths)
        self.tp_update()
    }
    
    @objc func tp_deleteItems(at indexPaths: [IndexPath]) {
        self.tp_deleteItems(at: indexPaths)
        self.tp_update()
    }
    
    @objc func tp_performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)?) {
        self.tp_performBatchUpdates(updates, completion: completion)
        self.tp_update()
    }
    
    /// 是否有行
    var hasItem: Bool {
        var hasRow = false
        let sectionsCount = self.dataSource?.numberOfSections?(in: self) ?? 0
        if sectionsCount > 0 {
            for i in 0..<sectionsCount {
                let itemsCount = self.dataSource?.collectionView(self, numberOfItemsInSection: i) ?? 0
                if itemsCount > 0 {
                    hasRow = true
                    break
                }
            }
        }
        
        return hasRow
    }
    
    func tp_update(){
        tp_updatePlaceholder()
        didUpdateHandler?()
    }
    
    func tp_updatePlaceholder() {
        var bShowPlaceholder = false
        if let shouldShowPlaceholder = self.shouldShowPlaceholder {
            bShowPlaceholder = shouldShowPlaceholder()
        } else {
            bShowPlaceholder = !hasItem
        }
        
        if bShowPlaceholder {
            self.tp_showPlaceholderView()
        } else {
            self.tp_hidePlaceholderView()
        }
    }
    
    private func tp_showPlaceholderView() {
        if let placeholderView = placeholderView {
            self.addSubview(placeholderView)
            self.tp_updateFrameOfPlaceholderView()
        }
    }
    
    private func tp_hidePlaceholderView() {
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
        guard let collectionSuperview = self.superview,
              let userInfo = notification.userInfo,
                let frameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let offsetY: CGFloat = 0.0
        /// 根据y间距调整键盘 frame 信息
        var keyboardFrame = frameValue.cgRectValue
        keyboardFrame.origin.y -= offsetY
        keyboardFrame.size.height += offsetY
        
        let convertedKeyboardFrame = collectionSuperview.convert(keyboardFrame, fromViewOrWindow: nil)
        let intersectionFrame = convertedKeyboardFrame.intersection(self.frame)
        self.keyboardIntersectionBottom = intersectionFrame.height
        tp_animateUpdateFrameOfPlaceholder()
        tp_updateContentInset()
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardIntersectionBottom = 0.0
        tp_animateUpdateFrameOfPlaceholder()
        tp_updateContentInset()
    }

    private func tp_animateUpdateFrameOfPlaceholder() {
        if isPlaceholderShown {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: .beginFromCurrentState, animations: {
                self.tp_updateFrameOfPlaceholderView()
            }, completion: nil)
        }
    }

}
