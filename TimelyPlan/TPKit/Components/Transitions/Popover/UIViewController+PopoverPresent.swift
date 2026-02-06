//
//  UIViewController+PopoverPresent.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/9.
//

import Foundation
import UIKit

extension UIViewController {
    private struct Constants {
      static var popoverPresentationControllerKey = "popoverPresentationControllerKey"
    }
    
    var popoverPresentationController: TPPopoverPresentationController? {
        get {
            var weakProxy = objc_getAssociatedObject(self, &Constants.popoverPresentationControllerKey)
            if weakProxy == nil, let navigationController = self.navigationController {
              weakProxy = objc_getAssociatedObject(navigationController, &Constants.popoverPresentationControllerKey)
            }
            
            let proxy = weakProxy as? TPWeakProxy<TPPopoverPresentationController>
            return proxy?.target
        }

        set {
            let weakProxy = TPWeakProxy(target: newValue)
            objc_setAssociatedObject(self,
                                   &Constants.popoverPresentationControllerKey,
                                   weakProxy,
                                   .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func popoverPresent(_ viewControllerToPresent: UIViewController,
                        from sourceView: UIView?,
                        sourceRect: CGRect? = nil,
                        isSourceViewCovered: Bool = false,
                        preferredPosition: TPPopoverPosition,
                        permittedPositions: [TPPopoverPosition]? = nil,
                        animated: Bool = true,
                        completion: (() -> Void)? = nil) {
        let configure = TPPopoverPresentationConfigure()
        configure.sourceView = sourceView
        if let sourceRect = sourceRect {
            configure.sourceRect = sourceRect
        } else {
            configure.sourceRect = sourceView?.bounds ?? .zero
        }
        
        configure.isSourceViewCovered = isSourceViewCovered
        
        configure.preferredPosition = sourceView == nil ? .center : preferredPosition
        if let permittedPositions = permittedPositions, permittedPositions.count > 0 {
            configure.permittedPositions = permittedPositions
        } else {
            configure.permittedPositions = TPPopoverPosition.allCases
        }
        
        let delegate = TPPopoverTransitioningDelegate(configure: configure)
        self.customTransitioningDelegate = delegate
        viewControllerToPresent.transitioningDelegate = delegate
        viewControllerToPresent.modalPresentationStyle = .custom
        self.present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
    func popoverShow() {
        popoverShow(from: nil, preferredPosition: .center)
    }
    
    func popoverShow(from sourceView: UIView?,
                     sourceRect: CGRect? = nil,
                     isSourceViewCovered: Bool = false,
                     preferredPosition: TPPopoverPosition,
                     permittedPositions: [TPPopoverPosition]? = nil,
                     animated: Bool = true,
                     completion: (() -> Void)? = nil) {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        topVC.popoverPresent(self,
                             from: sourceView,
                             sourceRect: sourceRect,
                             isSourceViewCovered: isSourceViewCovered,
                             preferredPosition: preferredPosition,
                             permittedPositions: permittedPositions,
                             animated: true,
                             completion: completion)
    }

}
