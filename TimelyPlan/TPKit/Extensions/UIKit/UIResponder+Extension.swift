//
//  UIResponder+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/9.
//

import Foundation
import UIKit
fileprivate weak var _currentFirstResponder: UIResponder?

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
    
    static func currentFirstResponder() -> UIResponder? {
        _currentFirstResponder = nil
        UIApplication.shared.sendAction(#selector(findFirstResponder),
                                        to: nil,
                                        from: nil,
                                        for: nil)
        return _currentFirstResponder
    }
    
    @objc private func findFirstResponder() {
        _currentFirstResponder = self
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
