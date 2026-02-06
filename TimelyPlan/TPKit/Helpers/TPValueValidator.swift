//
//  TPValueValidator.swift
//  TimelyPlan
//
//  Created by caojun on 2024/12/30.
//

import Foundation

class TPValueValidator {
    
    /// 返回一个合法的进度值
    static func validateProgress(_ value: CGFloat) -> CGFloat {
        return max(0.0, min(value, 1.0))
    }

    static func validateValue<T: Comparable>(value: T, num1: T, num2: T) -> T {
        let minValue = min(num1, num2)
        let maxValue = max(num1, num2)

        if value >= minValue && value <= maxValue {
            return value
        } else if value < minValue {
            return minValue
        } else {
            return maxValue
        }
    }
}
