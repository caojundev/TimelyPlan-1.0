//
//  TPSlidePresentAnimator.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/6.
//

import Foundation
import UIKit

class TPSlidePresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.4
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let presentationController = toVC.slidePresentationController else {
                  transitionContext.completeTransition(false)
            return
        }
        
       let fromView: UIView = fromVC.view
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                       delay: 0.0,
                       usingSpringWithDamping: 0.95,
                       initialSpringVelocity: 0.0,
                       options: .curveEaseInOut,
                       animations: {
            fromView.frame = presentationController.endFrameOfPresentingViewInContainerView()
        }) { (finished) in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
    }
}


class TFSlideDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    /// 是否手势交互中
    var isInteracting: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to),
              let presentationController = fromVC.slidePresentationController else {
                  transitionContext.completeTransition(false)
                  return
              }
        
        let toViewFrame = presentationController.initialFrameOfPresentingViewInContainerView()
        let animations = {
            toVC.view.frame = toViewFrame
        }
        
        let completion: ((Bool) -> Void) = { finished in
            let wasCancelled = transitionContext.transitionWasCancelled
            transitionContext.completeTransition(!wasCancelled)
        }
        
        if isInteracting {
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveLinear,
                           animations: animations,
                           completion: completion)
        } else {
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext),
                           delay: 0.0,
                           options: .curveEaseInOut,
                           animations: animations,
                           completion: completion)
        }
    }
}
