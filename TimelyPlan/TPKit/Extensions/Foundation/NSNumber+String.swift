//
//  NSNumber+String.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/22.
//

import Foundation

extension NSNumber {
    
    /// 将整数格式化为每隔三位用逗号分隔开来的格式
    var decimalStyleString: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let formattedNumber = numberFormatter.string(from: self) {
            return formattedNumber
        }
        
        return "\(int64Value)"
    }
}
