//
//  UIViewController+TFSlideTransition.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/6.
//

import Foundation
import UIKit

extension UIViewController {
    
    private struct Constants {
      static var slidePresentationControllerKey = "slidePresentationControllerKey"
    }
    
    var slidePresentationController: TPSlidePresentationController? {
        get {
            var weakProxy = objc_getAssociatedObject(self, &Constants.slidePresentationControllerKey)
            if weakProxy == nil, let navigationController = self.navigationController {
              weakProxy = objc_getAssociatedObject(navigationController, &Constants.slidePresentationControllerKey)
            }
            
            let proxy = weakProxy as? TPWeakProxy<TPSlidePresentationController>
            return proxy?.target
        }

        set {
            let weakProxy = TPWeakProxy(target: newValue)
            objc_setAssociatedObject(self,
                                   &Constants.slidePresentationControllerKey,
                                   weakProxy,
                                   .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    
    // MARK: - Present
    func slideShow(from direction: TPSlideDirection,
                    animated: Bool,
                    completion: (() -> Void)?) {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        topVC.slidePresent(self, direction: direction, animated: animated, completion: completion)
    }
    
    func slidePresent(_ viewControllerToPresent: UIViewController,
                        direction: TPSlideDirection,
                        animated: Bool,
                        completion: (() -> Void)?) {
        let configure = TPSlidePresentationConfigure()
        configure.direction = direction
        configure.shouldDismissWhenTapOnMask = true
        configure.compactPresentPosition = .bottom
        configure.regularPresentPosition = .bottom
        configure.maskColor = Color(0x000000, 0.2)
        configure.compactCornerRadius = 24.0
        configure.regularCornerRadius = 24.0
        configure.regularEdgeInsets = UIEdgeInsets(value: 5.0)
        configure.compactEdgeInsets = UIEdgeInsets(value: 5.0)
        self.slidePresent(viewControllerToPresent,
                          configure: configure,
                          isInteractive: false,
                          animated: true,
                          completion: nil)
    }
    
    func slidePresent(_ viewControllerToPresent: UIViewController,
                        configure: TPSlidePresentationConfigure,
                        isInteractive: Bool,
                        animated: Bool,
                        completion: (() -> Void)?) {
        let transitioningDelegate = TPSlideTransitioningDelegate(configure: configure)
        self.customTransitioningDelegate = transitioningDelegate /// 强引用
        if isInteractive {
            let interactiveTransition = TPSlideInteractiveTransition(viewController: viewControllerToPresent)
            interactiveTransition.direction = configure.direction
            transitioningDelegate.interactiveTransition = interactiveTransition
        }
    
        viewControllerToPresent.transitioningDelegate = transitioningDelegate
        viewControllerToPresent.modalPresentationStyle = .custom
        present(viewControllerToPresent, animated: animated, completion: completion)
    }
    
}
