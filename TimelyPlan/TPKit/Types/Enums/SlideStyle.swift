//
//  SlideStyle.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation

/// 滑动样式
enum SlideStyle: Int {
    case none
    case rightToLeft  /// 从右向左
    case leftToRight /// 从左向右
    case topToBottom /// 从上向下
    case bottomToTop /// 从下向上

    /// 根据两个可比较的数值返回水平动画样式
    static func horizontalStyle<T: Comparable>(fromValue: T, toValue: T) -> Self {
        if fromValue < toValue {
            return .rightToLeft
        } else if fromValue > toValue {
            return .leftToRight
        }
        return .none
    }

    /// 根据两个可比较的数值返回垂直动画样式
    static func verticalStyle<T: Comparable>(fromValue: T, toValue: T) -> Self {
        if fromValue < toValue {
            return .bottomToTop
        } else if fromValue > toValue {
            return .topToBottom
        }
        return .none
    }
}

