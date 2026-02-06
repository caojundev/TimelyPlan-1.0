//
//  UIControl+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/4.
//

import Foundation
import UIKit

/// 扩大控件响应面积
extension UIControl {
    
    private struct AssociatedKeys {
        static var hitTestEdgeInsets = "hitTestEdgeInsets"
    }

    var hitTestEdgeInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &AssociatedKeys.hitTestEdgeInsets) as? NSValue {
                return value.uiEdgeInsetsValue
            }
            return UIEdgeInsets.zero
        }
        
        set {
            let value = NSValue(uiEdgeInsets: newValue)
            objc_setAssociatedObject(self, &AssociatedKeys.hitTestEdgeInsets, value,.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitTestEdgeInsets = hitTestEdgeInsets
        if !isEnabled || isHidden || hitTestEdgeInsets == .zero {
            return super.point(inside: point, with: event)
        }

        let hitTestFrame = self.bounds.inset(by: hitTestEdgeInsets)
        return hitTestFrame.contains(point)
    }
}
