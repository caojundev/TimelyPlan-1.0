//
//  String+DaysCount.swift
//  TimelyPlan
//
//  Created by caojun on 2023/5/28.
//

import Foundation

extension String {
    
    public static func stringWithDaysCount(_ count: Int) -> String {
        var format: String
        if count <= 1 {
            format = resGetString("%ld day")
        } else {
            format = resGetString("%ld days")
        }
    
        return String(format: format, count)
    }
}
