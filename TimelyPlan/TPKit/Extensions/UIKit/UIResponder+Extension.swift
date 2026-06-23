//
//  UIResponder+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/9.
//

import Foundation
import UIKit

extension UIResponder {
    
    private struct AssociatedKeys {
        static var shouldShowDismissButton = "shouldShowDismissButton"
    }

    var shouldShowDismissButton: Bool {
        get {
            associated.get(&AssociatedKeys.shouldShowDismissButton) ?? false
        }
        
        set {
            associated.set(retain: &AssociatedKeys.shouldShowDismissButton, newValue)
        }
    }
    
    /// 获取当前第一响应者（全窗口安全搜索）
    static func currentFirstResponder() -> UIResponder? {
        // 优先搜索 keyWindow
        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in scene.windows where window.isKeyWindow {
                if let responder = window.tp_findFirstResponder() {
                    return responder
                }
            }
        }
        
        // 搜索非 keyWindow（如 UIRemoteKeyboardWindow）
        for scene in UIApplication.shared.connectedScenes.compactMap({ $0 as? UIWindowScene }) {
            for window in scene.windows where !window.isKeyWindow {
                if let responder = window.tp_findFirstResponder() {
                    return responder
                }
            }
        }
        return nil
    }
    
    static func resignCurrentFirstResponder() {
        if let responder = UIResponder.currentFirstResponder() {
            responder.resignFirstResponder()
        }
    }
    
    static func isCurrentFirstResponderDescendantView(of view: UIView) -> Bool {
        var isDescendant = false
        let responder = UIResponder.currentFirstResponder()
        if let aView = responder as? UIView, aView.isDescendant(of: view) {
            isDescendant = true
        }
        
        return isDescendant
    }
}

extension UIView {
    fileprivate func tp_findFirstResponder() -> UIResponder? {
        if self.isFirstResponder { return self }
        for subview in subviews {
            if let found = subview.tp_findFirstResponder() {
                return found
            }
        }
        return nil
    }
}
