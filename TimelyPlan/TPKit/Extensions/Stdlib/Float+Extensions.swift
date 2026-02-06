//
//  Float.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/21.
//

import Foundation

extension Float {
    
    /// 浮点数字符串
    /// - Parameter decimalPlaces: 保留最多小数位数
    /// - Returns: 浮点或整数字符串
    func string(decimalPlaces: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = decimalPlaces
        let number = NSNumber(value: self)
        return formatter.string(from: number)
    }
    
    /// 将浮点数转换成百分比字符串，并指定小数点后的位数
    func percentageString(decimalPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = decimalPlaces
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    func attributedPercentageString(decimalPlaces: Int,
                                    percentSignFont: UIFont = BOLD_SMALL_SYSTEM_FONT) -> ASAttributedString {
        let string = percentageString(decimalPlaces: decimalPlaces)
        let numberString = string.replacingOccurrences(of: "%", with: "")
        return "\(numberString)\("%", .font(percentSignFont))"
    }
}

