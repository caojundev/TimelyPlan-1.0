//
//  CGFloat+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/8.
//

import Foundation

extension CGFloat {
    
    var degreesToRadians: CGFloat {
        return self * .pi / 180
    }
    
    var radiansToDegrees: CGFloat {
        return self * 180 / .pi
    }

    /// 浮点数字符串
    /// - Parameter decimalPlaces: 保留最多小数位数
    /// - Returns: 浮点或整数字符串
    func string(decimalPlaces: Int) -> String? {
        return Float(self).string(decimalPlaces: decimalPlaces)
    }
}
