//
//  Date+Holiday.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/10.
//

import Foundation

enum FloatingHoliday {
    case fatherDay
    case motherDay
    case thanksgivingDay
    
    var name: String {
        switch self {
        case .fatherDay:
            return "父亲节"
        case .motherDay:
            return "母亲节"
        case .thanksgivingDay:
            return "感恩节"
        }
    }
    
    init?(date: Date) {
        if date.isFatherDay() {
            self = .fatherDay
            return
        } else if date.isMotherDay() {
            self = .motherDay
            return
        } else if date.isThanksgivingDay() {
            self = .thanksgivingDay
            return
        }
        
        return nil
    }
    
    static func isFloatingHoliday(_ date: Date) -> Bool {
        if date.isFatherDay() || date.isMotherDay() || date.isThanksgivingDay() {
            return true
        }
        
        return false
    }
}

extension Date {
    static let solarHolidays: [String:String] = [
        "01-01": "元旦",
        "02-14": "情人节",
        "03-08": "妇女节",
        "04-01": "愚人节",
        "05-01": "劳动节",
        "06-01": "儿童节",
        "07-01": "建党节",
        "08-01": "建军节",
        "09-10": "教师节",
        "10-01": "国庆节",
        "10-31": "万圣夜",
        "12-24": "平安夜",
        "12-25": "圣诞节"
    ]
    
    /// 农历节日
    static let lunarHolidays: [String: String] = [
        "01-01": "春节",
        "01-15": "元宵节",
        "05-05": "端午节",
        "07-07": "七夕节",
        "07-15": "中元节",
        "08-15": "中秋节",
        "09-09": "重阳节",
        "12-08": "腊八节",
        "12-23": "北小年",
        "12-24": "南小年"
    ]
    
    /// 判断是否是农历节日
    private var lunarHolidayKey: String {
        return String(format: "%02ld-%02ld", lunarMonth, lunarDay)
    }
    
    var lunarHolidayName: String? {
        if let name = Date.lunarHolidays[lunarHolidayKey] {
            return name
        }
        
        /// 除夕
        if isLunarNewYearEve {
            return "除夕"
        }
        
        return nil
    }
        
    var isLunarHoliday: Bool {
        if lunarHolidayName != nil {
            return true
        }
        
        return false
    }
    
    /// 判断是否是公历节日
    private var solarHolidayKey: String {
        return String(format: "%02ld-%02ld", month, day)
    }
    
    var solarHolidayName: String? {
        if let name = Date.solarHolidays[solarHolidayKey] {
            return name
        }
        
        if let floatingHoliday = FloatingHoliday(date: self) {
            return floatingHoliday.name
        }
        
        return nil
    }
    
    var isSolarHoliday: Bool {
        if solarHolidayName != nil {
            return true
        }
        
        return false
    }
    
    /// 节日名称
    var holidayName: String? {
        if let name = lunarHolidayName {
            return name
        }
        
        if let name = solarHolidayName {
            return name
        }
        
        return nil
    }
    
    var isHoliday: Bool {
        return isLunarHoliday || isSolarHoliday
    }
    
    // 判断是否是父亲节
    func isFatherDay() -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month,
                                                  .weekday,
                                                  .weekdayOrdinal], from: self)
        
        // 父亲节在6月的第三个星期日
        return components.month == 6 && components.weekday == 1 && components.weekdayOrdinal == 3
    }
    
    // 判断是否是母亲节
    func isMotherDay() -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month,
                                                  .weekday,
                                                  .weekdayOrdinal], from: self)
        
        // 母亲节在5月的第二个星期日
        return components.month == 5 && components.weekday == 1 && components.weekdayOrdinal == 2
    }
    
    // 判断是否是感恩节
    func isThanksgivingDay() -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month,
                                                  .weekday,
                                                  .weekdayOrdinal], from: self)
        
        // 感恩节在11月的第四个星期四
        return components.month == 11 && components.weekday == 5 && components.weekdayOrdinal == 4
    }
}
