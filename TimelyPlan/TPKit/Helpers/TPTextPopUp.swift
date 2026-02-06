//
//  TPTextPopUp.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/20.
//

import Foundation
import UIKit

class TPTextPopUp {
    
    static func showText(_ text: String, fromView: UIView?) {
        showText(text,
                 color: .label,
                 font: BOLD_SYSTEM_FONT,
                 fromView: fromView)
    }
    
    static func showText(_ text: String, color: UIColor, fromView: UIView?) {
        showText(text,
                 color: color,
                 font: BOLD_SYSTEM_FONT,
                 fromView: fromView)
    }

    static func showText(_ text: String,
                         color: UIColor,
                         font: UIFont,
                         fromView: UIView?) {
        guard let rootView = UIWindow.keyWindow else {
            return
        }
        
        let label = UILabel()
        label.alpha = 0.0
        label.textColor = color
        label.font = font
        label.text = text
        label.sizeToFit()
        
        var rect: CGRect
        if let fromView = fromView {
            rect = fromView.convert(fromView.bounds, toViewOrWindow: nil)
        } else {
            rect = rootView.frame
        }

        label.center = rect.center
        rootView.addSubview(label)
        label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
    
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: .curveEaseInOut) {
            var transform = CGAffineTransform(translationX: 0.0, y: -label.height)
            transform = transform.concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
            label.transform = transform
            label.alpha = 1.0
        } completion: { _ in
            UIView.animate(withDuration: 0.2,
                           delay: 0.0,
                           options: .curveEaseInOut) {
                label.alpha = 0.0
                label.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            } completion: { finished in
                label.removeFromSuperview()
            }
        }
    }
}
