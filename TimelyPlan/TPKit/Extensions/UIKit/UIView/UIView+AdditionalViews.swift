//
//  UIView+AdditionalViews.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/15.
//

import Foundation
import UIKit

enum TFSeparatorPosition: Int {
    case top
    case left
    case bottom
    case right
}

extension UIView {
    
    private struct AssociatedKeys {
        static var separatorView = "separatorView"
        static var separatorColor = "separatorColor"
        static var separatorAlpha = "separatorAlpha"
        static var separatorPosition = "separatorPosition"
        static var separatorEdgeInset = "separatorEdgeInset"
    }

    // MARK: - 分割线
    var separatorView: UIView? {
        get {
            return associated.get(&AssociatedKeys.separatorView)
        }
        
        set {
            associated.set(retain: &AssociatedKeys.separatorView, newValue)
        }
    }
    
    var separatorColor: UIColor {
        get {
            let color: UIColor? = associated.get(&AssociatedKeys.separatorColor)
            return color ?? .separator
        }
        
        set {
            associated.set(retain: &AssociatedKeys.separatorColor, newValue)
            self.separatorView?.backgroundColor = newValue
        }
    }
    
    var separatorPosition: TFSeparatorPosition {
        get {
            let position: TFSeparatorPosition = associated.get(&AssociatedKeys.separatorPosition) ?? .top
            return position
        }
        
        set {
            associated.set(retain: &AssociatedKeys.separatorPosition, newValue)
            self.setNeedsLayout()
        }
    }
    
    var separatorAlpha: CGFloat {
        get {
            return associated.get(&AssociatedKeys.separatorAlpha) ?? 1.0
        }
        
        set {
            associated.set(retain: &AssociatedKeys.separatorAlpha, newValue)
            separatorView?.alpha = newValue
        }
    }
    
    var separatorEdgeInset: UIEdgeInsets {
        get {
            associated.get(&AssociatedKeys.separatorEdgeInset) ?? .zero
        }
        
        set {
            associated.set(retain: &AssociatedKeys.separatorEdgeInset, newValue)
            self.setNeedsLayout()
        }
    }
    
    var separatorRect: CGRect {
        var rect = CGRect.zero
        let layoutFrame = self.bounds.inset(by: separatorEdgeInset)
        let lineHeight = 1.0
        switch separatorPosition {
        case .top:
            rect = CGRect(x: layoutFrame.minX,
                          y: layoutFrame.minY,
                          width: layoutFrame.width,
                          height: lineHeight)
        case .left:
            rect = CGRect(x: layoutFrame.minX,
                          y: layoutFrame.minY,
                          width: lineHeight,
                          height: layoutFrame.height)
        case .bottom:
            rect = CGRect(x: layoutFrame.minX,
                          y: layoutFrame.maxY - lineHeight,
                          width: layoutFrame.width,
                          height: lineHeight)
        case .right:
            rect = CGRect(x: layoutFrame.maxX + lineHeight,
                          y: layoutFrame.minY,
                          width: lineHeight,
                          height: layoutFrame.height)
        }

        return rect
    }
    
    func addSeparator(position: TFSeparatorPosition, color: UIColor = Color(0x888888, 0.1)) {
        self.separatorPosition = position
        self.separatorColor = color
        self.addSeparator()
    }
    
    func addSeparator() {
        if let separatorView = separatorView, separatorView.isDescendant(of: self) {
            return
        }
        
        let separatorView = UIView(frame: separatorRect)
        separatorView.backgroundColor = separatorColor
        separatorView.alpha = separatorAlpha
        self.separatorView = separatorView
        self.insertSubview(separatorView, at: 999)
    }

    func removeSeparator() {
        self.separatorView?.removeFromSuperview()
        self.separatorView = nil
    }
    
    func layoutSeparator() {
        if let separatorView = self.separatorView {
            separatorView.frame = separatorRect
        }
    }
}
