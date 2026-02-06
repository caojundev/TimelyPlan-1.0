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
        return kFocusTimerColorHexValues.map { Color($0) }
    }

    /// 随机专注计时器颜色
    static var randomFocusTimerColor: UIColor {
        let value = kFocusTimerColorHexValues.randomElement()!
        return Color(value)
    }
}
