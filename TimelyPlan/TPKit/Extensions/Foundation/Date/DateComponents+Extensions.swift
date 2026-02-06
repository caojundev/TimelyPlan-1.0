//
//  DateComponents+String.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/23.
//

import Foundation

// MARK: - 格式化字符串
extension DateComponents {
    
    /// 返回由当前日期组件的年和月组成的新组件
    var yearMonthDateComponents: DateComponents {
        var components = DateComponents()
        components.year = year
        components.month = month
        return components
    }
    
    var yearMonthDayDateComponents: DateComponents {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return components
    }
    
    /// 年+月+天字符串
    var yearMonthDayString: String? {
        let date = Date.dateFromComponents(self)
        return date?.yearMonthDayString
    }
    
    /// 月+天字符串
    var flexibleMonthDayString: String? {
        guard let date = Date.dateFromComponents(self) else {
            return nil
        }
        
        if date.isInCurrentYear {
            return date.monthDayString
        } else {
            return date.yearMonthDayString
        }
    }
}

// MARK: - 日期判断
extension DateComponents {
    
    var isPastDate: Bool {
        return Self.isPastDate(self)
    }
    
    /// 判断一个DateComponents对象是否表示过去的日期（今天之前）
    static func isPastDate(_ components: DateComponents) -> Bool {
        let currentDate = Date().startOfDay()
        if let date = Date.date(from: components) {
            return date < currentDate
        }
        
        return false
    }
 
}
