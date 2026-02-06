//
//  UIView+Animate.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/15.
//

import Foundation

extension UIView {

    /// 伴随动画过度进行重新布局
    func animateLayout(withDuration duration: TimeInterval, usingSpring: Bool = false) {
        animateLayout(withDuration: duration, usingSpring: usingSpring, completion: nil)
    }
    
    func animateLayout(withDuration duration: TimeInterval, usingSpring: Bool = false, completion: ((Bool) -> Void)? = nil) {
        if usingSpring {
            UIView.animate(withDuration: duration,
                           delay: 0.0,
                           usingSpringWithDamping: 0.8,
                           initialSpringVelocity: 0.5,
                           options: .curveEaseInOut,
                           animations: {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }, completion: { finished in
                completion?(finished)
            })
        } else {
            UIView.animate(withDuration: duration) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            } completion: { finished in
                completion?(finished)
            }
        }
    }
}
