//
//  TPSlideTransitioningDelegate.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/6.
//

import Foundation
import UIKit

class TPSlideTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    /// 呈现样式配置
    var configure: TPSlidePresentationConfigure

    /// 手势交互
    var interactiveTransition: TPSlideInteractiveTransition? {
        didSet {
            interactiveTransition?.dismissAnimator = dismissAnimator
        }
    }

    private var presentAnimator = TPSlidePresentAnimator()
    
    private var dismissAnimator = TFSlideDismissAnimator()
    
    init(configure: TPSlidePresentationConfigure) {
        self.configure = configure
        super.init()
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimator
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimator
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = TPSlidePresentationController(presentedViewController: presented,
                                                                   presenting: presenting)
        presentationController.configure = self.configure
        presented.slidePresentationController = presentationController
        return presentationController
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let interactiveTransition = interactiveTransition else {
            return nil
        }
        
        if interactiveTransition.isInteracting {
            return interactiveTransition
        }
        
        return nil
    }
}
