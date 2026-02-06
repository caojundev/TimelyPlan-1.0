//
//  UIViewController+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/14.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// 当前最顶层呈现的视图控制器
    static var topPresented: UIViewController? {
        var vc = UIWindow.keyWindow?.rootViewController
        while vc?.presentedViewController != nil {
            vc = vc?.presentedViewController
        }
        
        return vc
    }
    
    var topParent: UIViewController? {
        var result: UIViewController? = nil
        var parentVC = self.parent
        while parentVC != nil {
            result = parentVC
            parentVC = parentVC?.parent
        }
        
        return result
    }

    func setContentSize(_ size: CGSize, animated: Bool = false) {
        var viewController = self
        if let navigationController = navigationController {
            viewController = navigationController
        }
        
        guard viewController.preferredContentSize != size else {
            return
        }
        
        viewController.preferredContentSize = size
        let containerView = viewController.presentationController?.containerView
        if animated {
            CATransaction.begin()
            containerView?.superview?.animateLayout(withDuration: 0.4)
            containerView?.animateLayout(withDuration: 0.4)
            CATransaction.commit()
        } else {
            containerView?.setNeedsLayout()
        }
    }
    
    func addSubviewController(_ vc: UIViewController, parent: UIView? = nil) {
        addChild(vc)
        if let parent = parent {
            parent.addSubview(vc.view)
        } else {
            view.addSubview(vc.view)
        }

        vc.didMove(toParent: self)
    }

    func removeSubViewController(_ vc: UIViewController?) {
        if let vc = vc {
            vc.willMove(toParent: nil)
            vc.removeFromParent()
        }
    }
}
