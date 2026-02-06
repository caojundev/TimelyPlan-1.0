//
//  UIEdgeInsets+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/16.
//

import Foundation

extension UIEdgeInsets {
    
    var horizontalLength: CGFloat {
        return self.left + self.right
    }
    
    var verticalLength: CGFloat {
        return self.top + self.bottom
    }
    
    /// 所有边间距相同
    init (value: CGFloat) {
        self.init(top: value, left: value, bottom: value, right: value)
    }
    
    init (horizontal: CGFloat = 0.0, vertical: CGFloat = 0.0) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }
    
    init (horizontal: CGFloat, top: CGFloat) {
        self.init(top: top, left: horizontal, bottom: 0.0, right: horizontal)
    }
    
    init (horizontal: CGFloat, bottom: CGFloat) {
        self.init(top: 0.0, left: horizontal, bottom: bottom, right: horizontal)
    }
    
    init (top: CGFloat) {
        self.init(top: top, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    init (left: CGFloat) {
        self.init(top: 0.0, left: left, bottom: 0.0, right: 0.0)
    }
    
    init (bottom: CGFloat) {
        self.init(top: 0.0, left: 0.0, bottom: bottom, right: 0.0)
    }
    
    init (right: CGFloat) {
        self.init(top: 0.0, left: 0.0, bottom: 0.0, right: right)
    }
    
    init (top: CGFloat, bottom: CGFloat) {
        self.init(top: top, left: 0.0, bottom: bottom, right: 0.0)
    }
    
    init (left: CGFloat, right: CGFloat) {
        self.init(top: 0.0, left: left, bottom: 0.0, right: right)
    }
    
    /// 将两个 insets 的各个方向的值相加，得到一个新的 insets
    func addingInsets(_ insets: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: self.top + insets.top,
            left: self.left + insets.left,
            bottom: self.bottom + insets.bottom,
            right: self.right + insets.right
        )
    }
}
