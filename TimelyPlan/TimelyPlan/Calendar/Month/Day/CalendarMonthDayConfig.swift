//
//  CalendarMonthDayConfig.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/23.
//

import Foundation

struct CalendarMonthDayConfig {
    
    /// 日期
    var date: Date
    
    /// 节日名称
    var holidayName: String?
    
    /// 节气名称
    var solarTermName: String?
    
    /// 农历日期
    var lunarDayString: String?
    
    /// 调休状态
    let workStatus: TPDateState

    var dayLabelText: String {
        let day = date.day
        if day != 1 {
            return "\(date.day)"
        }
        
        return date.shortMonthSymbol
    }
    
    var lunarLabelText: String? {
        var result: String?
        if let holidayName = holidayName {
            result = holidayName
        } else if let solarTermName = solarTermName {
            result = solarTermName
        } else {
            result = lunarDayString
        }
        
        return result
    }
    
    var workStatusLabelText: String? {
        return workStatus.title
    }

    init(date: Date, showLunar: Bool = true, showChineseHolidays: Bool = true) {
        self.date = date
        if showLunar {
            self.holidayName = date.holidayName
            self.solarTermName = date.solarTermName
            self.lunarDayString = date.lunarCalendarDayString
        }
   
        if showChineseHolidays {
            self.workStatus = TPHolidayScheduler.shared.state(for: date)
        } else {
            self.workStatus = .inNormal
        }
    }
}
