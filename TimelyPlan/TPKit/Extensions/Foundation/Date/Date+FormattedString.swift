//
//  Date+FormattedString.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/13.
//

import Foundation

extension Date {
    
    /// 年字符串
    var yearString: String {
        if Language.isChinese {
            return stringWithFormat("yyyy年")
        } else {
            return stringWithFormat("yyyy")
        }
    }
    
    /// 年+月字符串
    var yearMonthString: String {
        let format: String = resGetString("MMM, yyyy")
        return stringWithFormat(format)
    }
    
    var slashFormattedYearMonthString: String {
        return stringWithFormat("yyyy/MM")
    }
    
    /// 月+天字符串
    var monthDayString: String {
        let format: String = resGetString("MMM d")
        return stringWithFormat(format)
    }
    
    var slashFormattedMonthDayString: String {
        return stringWithFormat("MM/dd")
    }
    
    /// 年+月+天字符串
    var yearMonthDayString: String {
        let format: String = resGetString("MMM d, yyyy")
        return stringWithFormat(format)
    }
    
    var slashFormattedYearMonthDayString: String {
        return stringWithFormat("yyyy/MM/dd")
    }
    
    var shortMonthSymbol: String {
        return stringWithFormat("MMM")
    }
    
    var timeString: String {
        return stringWithFormat("HH:mm")
    }
    
    var monthDayTimeString: String {
        return "\(monthDayString) \(timeString)"
    }
    
    /// 返回日期的”月+天+周几“字符串，
    var monthDayWeekdaySymbolString: String {
        let dateString = monthDayString
        let weekString = weekdaySymbol()
        return dateString + " " + weekString
    }
    
    var monthDayShortWeekdaySymbolString: String {
        let dateString = monthDayString
        let weekString = shortWeekdaySymbol()
        return dateString + ", " + weekString
    }
    
    
    
    /// 获取年月日的字符串
    /// - Parameters:
    ///   - omitYear: 是否省略本年度的年字符串
    ///   - showRelativeDate: 是否显示相对日期
    ///   - slashSeparatedFormat: 是否使用斜杠分割的格式
    /// - Returns: 日期字符串
    func yearMonthDayString(omitYear: Bool,
                            showRelativeDate: Bool = true,
                            slashFormatted: Bool = false) -> String {
        if showRelativeDate {
            if isToday {
                return resGetString("Today")
            } else if isTomorrow {
                return resGetString("Tomorrow")
            }
        }

        if omitYear && isInCurrentYear {
            return slashFormatted ? slashFormattedMonthDayString : monthDayString
        }
        
        return slashFormatted ? slashFormattedYearMonthDayString : yearMonthDayString
    }
    
    func yearMonthDayWeekdaySymbolString(style: WeekdaySymbolStyle = .short,
                                         omitYear: Bool = true,
                                         showRelativeDate: Bool = false) -> String {
        let dateString = yearMonthDayString(omitYear: omitYear,
                                            showRelativeDate: showRelativeDate)
        let weekdaySymbol = weekdaySymbol(style: style)
        return dateString + ", " + weekdaySymbol
    }
    
    func yearMonthDayTimeString(omitYear: Bool, showRelativeDate: Bool = false, slashFormatted: Bool = false) -> String {
        let string = yearMonthDayString(omitYear: omitYear,
                                        showRelativeDate: showRelativeDate,
                                        slashFormatted: slashFormatted)
        return string + " " + timeString
    }
}
