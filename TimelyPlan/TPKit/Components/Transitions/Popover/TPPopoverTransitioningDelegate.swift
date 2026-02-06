//
//  TPPopoverTransitioningDelegate.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/9.
//

import Foundation

class TPPopoverTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var configure: TPPopoverPresentationConfigure
    
    private var presentAnimator = TPPopoverPresentAnimator()
    
    private var dismissAnimator = TFPopoverDismissAnimator()
    
    init(configure: TPPopoverPresentationConfigure) {
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
        let presentationController = TPPopoverPresentationController(presentedViewController: presented,
                                                                     presenting: presenting)
        presentationController.sourceViewController = source
        presentationController.configure = self.configure
        return presentationController
    }
}
