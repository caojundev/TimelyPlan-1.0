//
//  Int+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/7.
//

import Foundation

extension Int {
    
    /// 数字位数
    var digitsCount: Int {
        return Int(log10(abs(Double(self)))) + 1
    }
    
    /// 获取数字对应的序数词字符串
    func ordinalSuffix() -> String {
        let format = ordinalSuffixFormat()
        return String(format: format, self)
    }
    
    /// 获取数字对应的序数词字符串 format
    func ordinalSuffixFormat(prefix: String? = nil, suffix: String? = nil) -> String {
        let lastDigit = self % 10
        let lastTwoDigits = self % 100
        
        var format: String
        switch (lastDigit, lastTwoDigits) {
        case (1, 11...13):
            format = "%ldth"
        case (1, _):
            format = "%ldst"
        case (2, _):
            format = "%ldnd"
        case (3, _):
            format = "%ldrd"
        default:
            format = "%ldth"
        }
        
        format = (prefix ?? "") + format + (suffix ?? "")
        return format
    }
    
    /// 获取数字对应的本地化序数词字符串
    func localizedOrdinalSuffixString() -> String {
        let format = ordinalSuffixFormat()
        return String(format: resGetString(format), self)
    }

}
