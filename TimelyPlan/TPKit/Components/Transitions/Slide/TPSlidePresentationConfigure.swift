//
//  TPSlidePresentationConfigure.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/6.
//

import Foundation
import UIKit

/// 滑动方向
enum TPSlideDirection {
    case top
    case left
    case bottom
    case right
}

/// 展示位置
enum TPSlidePresentationPosition {
    case top
    case left
    case bottom
    case right
    case center
}

// 定义一个类，用于配置滑动展示的配置项
class TPSlidePresentationConfigure {
    
    // 弹出方向，默认为底部
    var direction: TPSlideDirection = .bottom
    
    /// 展示位置
    var compactPresentPosition: TPSlidePresentationPosition
    var regularPresentPosition: TPSlidePresentationPosition
    var presentPosition: TPSlidePresentationPosition {
        get {
            if UITraitCollection.isRegularMode() {
                return regularPresentPosition
            } else {
                return compactPresentPosition
            }
        }
        
        set {
            compactPresentPosition = newValue
            regularPresentPosition = newValue
        }
    }
    
    // 边界间距，默认为0
    var compactEdgeInsets: UIEdgeInsets
    var regularEdgeInsets: UIEdgeInsets
    var edgeInsets: UIEdgeInsets {
        get {
            if UITraitCollection.isRegularMode() {
                return regularEdgeInsets
            } else {
                return compactEdgeInsets
            }
        }
        
        set {
            compactEdgeInsets = newValue
            regularEdgeInsets = newValue
        }
    }
    
    var compactContentSize: CGSize
    var regularContentSize: CGSize
    var contentSize: CGSize {
        get {
            if UITraitCollection.isRegularMode() {
                return regularContentSize
            } else {
                return compactContentSize
            }
        }
        
        set {
            compactContentSize = newValue
            regularContentSize = newValue
        }
    }
    
    
    // 圆角位置，默认四个角都为圆角
    var compactRoundingCorners: UIRectCorner
    var regularRoundingCorners: UIRectCorner
    var roundingCorners: UIRectCorner {
        get {
            if UITraitCollection.isRegularMode() {
                return regularRoundingCorners
            } else {
                return compactRoundingCorners
            }
        }
        
        set {
            compactRoundingCorners = newValue
            regularRoundingCorners = newValue
        }
    }
    
    // 圆角半径，默认为0
    var compactCornerRadius: CGFloat
    var regularCornerRadius: CGFloat
    var cornerRadius: CGFloat {
        get {
            if UITraitCollection.isRegularMode() {
                return regularCornerRadius
            } else {
                return compactCornerRadius
            }
        }
        
        set {
            compactCornerRadius = newValue
            regularCornerRadius = newValue
        }
    }
    
    var cornerRadii: CGSize {
        return CGSize(value: cornerRadius)
    }
    
    // 最小宽度和最大宽度
    var minimumWidth: CGFloat
    var maximumWidth: CGFloat
    
    // 最小高度和最大高度
    var minimumHeight: CGFloat
    var maximumHeight: CGFloat
    
    // 穿透视图数组，遮罩之下会响应触控事件
    var passthroughViews: [UIView]
    
    // 遮罩颜色
    var maskColor: UIColor
    
    // 点击遮罩是否 dismiss 视图控制器
    var shouldDismissWhenTapOnMask: Bool = true
    
    // 弹出视图阴影样式
    var shadowColor: UIColor
    var shadowOffset: CGSize
    var shadowRadius: CGFloat
    
    // 键盘弹出是否自动调整
    var automaticallyAdjustsForKeyboard: Bool
    
    // 初始化方法
    init() {
        // 设置默认值
        compactPresentPosition = .bottom
        regularPresentPosition = .bottom
        compactEdgeInsets = .zero
        regularEdgeInsets = .zero
        compactContentSize = .zero
        regularContentSize = .zero
        compactRoundingCorners = .allCorners
        regularRoundingCorners = .allCorners
        
        direction = .bottom
        maskColor = UIColor(white: 0.0, alpha: 0.5)
        
        shadowColor = UIColor(white: 0.0, alpha: 0.15)
        shadowOffset = CGSize(width: 0, height: -2.0)
        shadowRadius = 12.0
        
        compactCornerRadius = 16.0
        regularCornerRadius = 16.0
        
        minimumWidth = 320.0
        maximumWidth = CGFloat.greatestFiniteMagnitude
        
        minimumHeight = 0.0
        maximumHeight = CGFloat.greatestFiniteMagnitude
        
        passthroughViews = []
        automaticallyAdjustsForKeyboard = true
    }
}
