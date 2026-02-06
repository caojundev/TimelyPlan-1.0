//
//  UIViewController+CustomTransition.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/9.
//

import Foundation

extension UIViewController {
    
    fileprivate struct Constants {
        static var customTransitioningDelegateKey = "customTransitioningDelegateKey"
    }
    
    /// 强引用自定义的过渡代理对象
    var customTransitioningDelegate: UIViewControllerTransitioningDelegate? {
        
        get {
            let delegate = objc_getAssociatedObject(self, &Constants.customTransitioningDelegateKey)
            return delegate as? UIViewControllerTransitioningDelegate
        }

        set {
            objc_setAssociatedObject(self,
                                   &Constants.customTransitioningDelegateKey,
                                   newValue,
                                   .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
