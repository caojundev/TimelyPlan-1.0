//
//  UIColor+Focus.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/26.
//

import Foundation
import UIKit

extension UIColor {
    
    /// 专注计时器颜色
    static var focusTimerColors: [UIColor] {
        return kFocusTimerColorHexValues.colors
    }

    /// 随机专注计时器颜色
    static var randomFocusTimerColor: UIColor {
        let value = kFocusTimerColorHexValues.randomElement()!
        return Color(value)
    }
    
    /// 专注会话颜色
    static var focusSessionColors: [UIColor] {
        return kFocusSessionColorHexValues.colors
    }

    /// 专注会话默认颜色
    static var focusSessionDefaultColor: UIColor {
        return .primary
    }
}

extension Array where Element == UInt64 {
    
    /// 获取颜色数组
    var colors: [UIColor] {
        return self.map { Color($0) }
    }
}
