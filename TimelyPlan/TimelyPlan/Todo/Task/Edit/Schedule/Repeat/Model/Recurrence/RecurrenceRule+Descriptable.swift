//
//  RecurrenceRule+Descriptable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/24.
//

import Foundation
import UIKit

extension RecurrenceRule {
    
    var title: String? {
        let type = getType()
        switch type {
        case .regularly:
            /// 标题为间隔描述
            return intervalDescription?.value.string
        case .afterCompletion:
            return afterCompletionDescription?.value.string
        case .specificDates:
            return resGetString("Specific Dates")
        }
    }
    
    var subtitle: String? {
        let type = getType()
        switch type {
        case .regularly:
            return regularlyDetailDescription?.value.string
        case .afterCompletion:
            return nil
        case .specificDates:
            return specificDatesDescription?.value.string
        }
    }
}

extension RecurrenceRule: AttributedDescriptable {
    
    func localizedAttributedDescription() -> ASAttributedString? {
        let type = getType()
        switch type {
        case .regularly, .afterCompletion:
            let description: ASAttributedString?
            if type == .regularly {
                description = regularlyDescription
            } else {
                description = afterCompletionDescription
            }
            
            var descriptions = [ASAttributedString]()
            if let description = description {
                descriptions.append(description)
            }
            
            return descriptions.joined(separator: ", ")
        case .specificDates:
            return specificDatesDescription
        }
    }
    
    // MARK: - 描述
    /// 定期描述信息（间隔频率信 + 详细描述）
    private var regularlyDescription: ASAttributedString? {
        var descriptions = [ASAttributedString]()
        if let intervalDescription = intervalDescription {
            descriptions.append(intervalDescription)
        }
        
        if let detailDescription = regularlyDetailDescription {
            descriptions.append(detailDescription)
        }
        
        return descriptions.joined(separator: ", ")
    }
    
    /// 定期详细描述信息
    var regularlyDetailDescription: ASAttributedString? {
        let frequency = getFrequency()
        switch frequency {
        case .daily:
            return nil
        case .weekly:
            return daysOfTheWeekDescription()
        case .monthly:
            return monthAttributedString
        case .yearly:
            return yearlyDetailDescription
        }
    }
    
    /// 特定日期
    private var specificDatesDescription: ASAttributedString? {
        let count = specificDates?.count ?? 0
        let format: String
        if count > 1 {
            format = resGetString("%@ days selected")
        } else {
            format = resGetString("%@ day selected")
        }
        
        return .string(format: format, attributedParameters: ["\(count, highlightedTextColor)"])
    }
    
    /// 结束后
    private var afterCompletionDescription: ASAttributedString? {
        let format: String = resGetString("%@ after completion")
        return .string(format: format, attributedParameters: [intervalAttributedString])
    }
    
    /// 年重复具体描述
    var yearlyDetailDescription: ASAttributedString? {
        var strings: [ASAttributedString] = []
        if let monthsOfTheYearString = monthsOfTheYearAttributedString {
            strings.append(monthsOfTheYearString)
        }
        
        if let monthString = monthAttributedString {
            strings.append(monthString)
        }
        
        return strings.joined(separator: ", ")
    }
    
    // MARK: - Interval
    var intervalDescription: ASAttributedString? {
        let interval = getInterval()
        let frequency = getFrequency()
        return intervalDescription(interval: interval, frequency: frequency)
    }
    
    func intervalDescription(interval: Int, frequency: RepeatFrequency) -> ASAttributedString? {
        let frequencyFormat: String = resGetString("every %@")
        return .string(format: frequencyFormat, attributedParameters: [intervalAttributedString])
    }
    
    /// 间隔高亮富文本信息
    private var intervalAttributedString: ASAttributedString {
        let interval = getInterval()
        let frequency = getFrequency()
        let unit = frequency.unit(for: interval).lowercased()
        let format: String = resGetString("%ld \(unit)")
        let string = String(format: format, interval)
        
        return "\(string, highlightedTextColor)"
    }
    

    // MARK: -
    var monthAttributedString: ASAttributedString? {
        if monthlyMode == .onWeek {
            return weekdayOfTheMonthAttributedString
        } else {
            return daysOfTheMonthAttributedString
        }
    }

    /// 周天
    func daysOfTheWeekDescription() -> ASAttributedString? {
        guard let symbols = daysOfTheWeek?.weekdays?.orderedShortSymbols else {
            return nil
        }
        
        let symbolString = symbols.joined(separator: ", ")
        let symbolAttributedString: ASAttributedString = "\(symbolString, highlightedTextColor)"
        let format: String = resGetString("on the %@")
        return .string(format: format, attributedParameters: [symbolAttributedString])
    }

    /// 月天
    var daysOfTheMonthAttributedString: ASAttributedString? {
        guard let daysOfTheMonth = daysOfTheMonth, daysOfTheMonth.count > 0 else {
            return nil
        }

        var symbols = [String]()
        for i in 1...31 {
           if daysOfTheMonth.contains(i) {
               let symbol = i.localizedOrdinalSuffixString()
               symbols.append(symbol)
           }
        }

        // 最后一天
        if daysOfTheMonth.contains(-1) {
            let lastSymbol: String = resGetString("last day")
            symbols.append(lastSymbol)
        }
        
        let symbolString = symbols.joined(separator: ", ")
        let symbolAttributedString: ASAttributedString = "\(symbolString, highlightedTextColor)"
        let format: String = resGetString("on the %@")
        return .string(format: format, attributedParameters: [symbolAttributedString])
    }
    
    /// 月按周
    var weekdayOfTheMonthAttributedString: ASAttributedString? {
        guard let dayOfTheWeek = daysOfTheWeek?.first,
              let weekNumber = RepeatWeekNumber(rawValue: dayOfTheWeek.weekNumber) else {
            return nil
        }
        
        let weekday: Weekday = dayOfTheWeek.dayOfTheWeek
        let string = String(format: resGetString("%@ %@"), weekNumber.title.lowercased(), weekday.symbol.lowercased())
        let attributedString: ASAttributedString = "\(string, highlightedTextColor)"
        let format: String = resGetString("on the %@")
        return .string(format: format, attributedParameters: [attributedString])
    }
    
    // MARK: - 月份
    var monthsOfTheYearAttributedString: ASAttributedString? {
        guard let symbols = monthsOfTheYearSymbols else {
            return nil
        }
        
        let string = symbols.joined(separator: ", ")
        let attributedString: ASAttributedString = "\(string, highlightedTextColor)"
        let format: String = resGetString("in %@")
        return .string(format: format, attributedParameters: [attributedString])
    }
    
    var monthsOfTheYearSymbols: [String]? {
        guard let monthsOfTheYear = monthsOfTheYear, monthsOfTheYear.count > 0 else {
            return nil
        }

        var symbols = [String]()
        for month in Month.allCases {
            if monthsOfTheYear.contains(month.rawValue) {
                symbols.append(month.symbol)
            }
        }
        
        return symbols
    }
    
}
