//
//  TPSlideInteractiveTransition.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/6.
//

import Foundation
import UIKit

class TPSlideInteractiveTransition: UIPercentDrivenInteractiveTransition,
                                        UIGestureRecognizerDelegate {
    
    
    /// 方向
    var direction: TPSlideDirection = .left
    
    /// 是否正在交互中
    var isInteracting: Bool = false
    
    /// 退出动画器
    var dismissAnimator: TFSlideDismissAnimator?
    
    /// 绑定的呈现视图控制器
    private weak var viewController: UIViewController?
    
    private var shouldComplete: Bool = false
    
    init(viewController: UIViewController) {
        super.init()
        self.viewController = viewController
        self.completionCurve = .easeInOut
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        gesture.delegate = self
        viewController.view.addGestureRecognizer(gesture)
    }
    
    override var completionSpeed: CGFloat {
        get {
            var speed = 0.8
            if !shouldComplete {
                speed = self.percentComplete
                if speed < 0.6 {
                    speed = 0.6
                }
            }
            
            return speed
        }
        
        set { }
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        guard let view = recognizer.view else {
            return
        }
        
        let translation = recognizer.translation(in: view.superview)
        switch recognizer.state {
        case .began:
            self.isInteracting = true
            self.dismissAnimator?.isInteracting = true
            self.viewController?.dismiss(animated: true, completion: nil)
        case .changed:
            var fraction = 0.0
            switch direction {
            case .top:
                fraction = -translation.y / view.height
            case .left:
                fraction = -translation.x / view.width
            case .bottom:
                fraction = translation.y / view.height
            case .right:
                fraction = translation.x / view.width
            }

            self.shouldComplete = (fraction > 0.4)
            self.update(fraction)
        default:
            self.isInteracting = false
            self.dismissAnimator?.isInteracting = false
            if !shouldComplete || recognizer.state == .cancelled {
                self.cancel()
            } else {
                self.finish()
            }
        }
            
    }

    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var shouldReceive = true
        var aView = touch.view
        while aView != nil {
            /// 触摸点在控件上
            if aView is UIControl {
                shouldReceive = false
                break
            }
            
            if let cell = aView as? UITableViewCell {
                shouldReceive = shouldReceiveTouch(touch, on: cell)
                break;
            }
           
            aView = aView?.superview
        }

        return shouldReceive
    }
    
    private func shouldReceiveTouch(_ touch: UITouch, on cell: UITableViewCell) -> Bool {
        let point = touch.location(in: cell)
        let triggerEdgeWidth = 40.0
        if point.x < triggerEdgeWidth || point.x > cell.frame.maxX - triggerEdgeWidth {
            return true
        }
        
        return false
    }
}
