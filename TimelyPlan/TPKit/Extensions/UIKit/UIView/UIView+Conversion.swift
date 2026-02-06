//
//  UIView+Conversion.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/14.
//

import Foundation

extension UIView {
    
    func convert(_ point: CGPoint, toViewOrWindow view: UIView?) -> CGPoint {
        guard let view = view else {
            if let window = self as? UIWindow {
                return window.convert(point, to: nil)
            } else {
                return self.convert(point, to: nil)
            }
        }
        
        let fromWindow = self is UIWindow ? self as? UIWindow : self.window
        let toWindow = view is UIWindow ? view as? UIWindow : view.window
        guard let fromWindow = fromWindow, let toWindow = toWindow, fromWindow != toWindow else {
            return self.convert(point, to: view)
        }
  
        var convertedPoint = self.convert(point, to: fromWindow)
        convertedPoint = fromWindow.convert(convertedPoint, to: toWindow)
        convertedPoint = toWindow.convert(convertedPoint, to: view)
        return convertedPoint
    }
    
    func convert(_ point: CGPoint, fromViewOrWindow view: UIView?) -> CGPoint {
        guard let view = view else {
            if let window = self as? UIWindow {
                return window.convert(point, from: nil)
            } else {
                return self.convert(point, from: nil)
            }
        }
        
        let fromWindow = view is UIWindow ? view as? UIWindow : view.window
        let toWindow = self is UIWindow ? self as? UIWindow : self.window
        guard let fromWindow = fromWindow, let toWindow = toWindow, fromWindow != toWindow else {
            return self.convert(point, from: view)
        }
  
        var convertedPoint = fromWindow.convert(point, from: view)
        convertedPoint = toWindow.convert(convertedPoint, from: fromWindow)
        convertedPoint = self.convert(convertedPoint, from: toWindow)
        return convertedPoint
    }
    
    func convert(_ rect: CGRect, toViewOrWindow view: UIView?) -> CGRect {
        guard let view = view else {
            if let window = self as? UIWindow {
                return window.convert(rect, to: nil)
            } else {
                return self.convert(rect, to: nil)
            }
        }
        
        let fromWindow = self is UIWindow ? self as? UIWindow : self.window
        let toWindow = view is UIWindow ? view as? UIWindow : view.window
        guard let fromWindow = fromWindow, let toWindow = toWindow, fromWindow != toWindow else {
            return self.convert(rect, to: view)
        }
  
        var convertedRect = self.convert(rect, to: fromWindow)
        convertedRect = fromWindow.convert(convertedRect, to: toWindow)
        convertedRect = toWindow.convert(convertedRect, to: view)
        return convertedRect
    }
    
    func convert(_ rect: CGRect, fromViewOrWindow view: UIView?) -> CGRect {
        guard let view = view else {
            if let window = self as? UIWindow {
                return window.convert(rect, from: nil)
            } else {
                return self.convert(rect, from: nil)
            }
        }
        
        let fromWindow = view is UIWindow ? view as? UIWindow : view.window
        let toWindow = self is UIWindow ? self as? UIWindow : self.window
        guard let fromWindow = fromWindow, let toWindow = toWindow, fromWindow != toWindow else {
            return self.convert(rect, from: view)
        }
  
        var convertedRect = fromWindow.convert(rect, from: view)
        convertedRect = toWindow.convert(convertedRect, from: fromWindow)
        convertedRect = self.convert(convertedRect, from: toWindow)
        return convertedRect
    }
    
    func isPoint(_ point: CGPoint, onSubview subview: UIView) -> Bool {
        guard self != subview else {
            return false
        }
        
        var bOnSubview = false
        let pt = self.convert(point, to: subview)
        if subview.point(inside: pt, with: nil) {
            bOnSubview = true
        }
        
        return bOnSubview
    }

    func isTouch(_ touch: UITouch, onSubView subview: UIView) -> Bool {
        let touchPoint = touch.location(in: self)
        return isPoint(touchPoint, onSubview: subview)
    }
}
