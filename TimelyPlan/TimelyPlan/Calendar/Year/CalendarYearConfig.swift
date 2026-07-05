//
//  CalendarYearConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/4.
//

import Foundation

struct CalendarYearConfig {
    
    static let baseYear = 1970
    
    static let displayYears = 200
    
    static let lunarNewYearLineHeight = 1.8
    static let lunarFirstDayLineHeight = 1.0
    static let lunarFirstLineColor = UIColor.systemOrange
    
    
    
    /// 显示年范围
    static var yearRange: (from: Int, to: Int) {
        let toYear = baseYear + displayYears - 1
        return (baseYear, toYear)
    }
    
    
}
