//
//  TaskDateInfo.swift
//  TimelyPlan
//
//  Created by caojun on 2025/1/1.
//

import Foundation
import UIKit

/// 任务日期信息
struct TaskDateInfo: Hashable, Equatable {
    
    enum Style {
        case singleDay /// 单日
        case multiDay  /// 多日
    }
        
    /// 开始日期
    let startDate: Date
    
    /// 结束日期
    let endDate: Date
    
    /// 是否全天
    let isAllDay: Bool
    
    var style: Style {
        let count = Date.days(fromDate: startDate, toDate: endDate)
        if count == 0 {
            return .singleDay
        }
        
        return .multiDay
    }
  
    /// 持续时长
    var duration: Duration {
        let duration = Duration(endDate.timeIntervalSince(startDate))
        return max(duration, 0)
    }

    /// 是否已经逾期
    var isOverdue: Bool {
        return Date.now > endDate
    }
    
    var dateRange: DateRange {
        return DateRange(startDate: startDate, endDate: endDate)
    }
    
    var dateInterval: DateInterval {
        return DateInterval(start: startDate, end: endDate)
    }
    
    init(date: Date = .now, style: Style = .singleDay) {
        let startDate: Date = date.startOfDay()
        var endDate: Date = date.endOfDay()
        if style == .multiDay {
            endDate = endDate.dateByAddingDays(1)!
        }
        
        self.init(startDate: startDate, endDate: endDate, isAllDay: true)
    }
    
    init(startDate: Date, endDate: Date, isAllDay: Bool) {
        self.startDate = startDate
        self.endDate = endDate
        self.isAllDay = isAllDay
    }
    
    func attributedTitle(slashFormatted: Bool = true, textColor: UIColor = .primary) -> ASAttributedString {
        var strings = [String]()
        let startDateString = startDateString(slashFormatted: slashFormatted)
        strings.append(startDateString)
        if let endDateString = endDateString(slashFormatted: slashFormatted) {
            strings.append(endDateString)
        }
        
        var title = strings.joined(separator: "-")
        if isAllDay {
            title = title + " • \(resGetString("All-Day"))"
        }
        
        return title.attributedString(textColor: textColor)
    }
    
    private func startDateString(slashFormatted: Bool = true) -> String {
        let dateString: String
        if isAllDay {
            dateString = startDate.yearMonthDayString(omitYear: true,
                                                      showRelativeDate: true,
                                                      slashFormatted: slashFormatted)
        } else {
            dateString = startDate.yearMonthDayTimeString(omitYear: true,
                                                          showRelativeDate: true,
                                                          slashFormatted: slashFormatted)
        }
        
        return dateString
    }
    
    private func endDateString(slashFormatted: Bool = true) -> String? {
        let endDate = endDate
        let daysCount = self.startDate.daysBetween(endDate)
        var result: String?
        if daysCount < 1 {
            /// 单日
            result = isAllDay ? nil : endDate.timeString
        } else {
            /// 跨天
            if isAllDay {
                result = endDate.yearMonthDayString(omitYear: true,
                                                    showRelativeDate: true,
                                                    slashFormatted: slashFormatted)
            } else {
                result = endDate.yearMonthDayTimeString(omitYear: true,
                                                          showRelativeDate: true,
                                                          slashFormatted: slashFormatted)
            }
        }
        
        return result
    }
    
    
    func attributedDurationEndDateString(textColor: UIColor = .primary) -> ASAttributedString {
        let attributedDuration = duration.localizedTitle.attributedString(textColor: textColor)
        let attributedSeparator = " → ".attributedString(textColor: textColor)
        let attributedEndDate = attributedEndString(textColor: textColor)
        return attributedDuration + attributedSeparator + attributedEndDate
    }
    
    private func attributedEndString(slashFormatted: Bool = true,
                                     textColor: UIColor = .primary) -> ASAttributedString {
        let endDate = endDate
        let daysCount = startDate.daysBetween(endDate)
        var endDateString: String
        if daysCount < 1 {
            endDateString = endDate.timeString
        } else {
            endDateString = endDate.yearMonthDayTimeString(omitYear: true,
                                                           showRelativeDate: true,
                                                           slashFormatted: slashFormatted)
        }
        
        return endDateString.attributedString(textColor: textColor)
    }
    
    // MARK: - Helpers
    static func allDayDateInfo(startDate: Date) -> TaskDateInfo {
        let dateInfo = TaskDateInfo(startDate: startDate.startOfDay(),
                                    endDate: startDate.endOfDay(),
                                    isAllDay: true)
        return dateInfo
    }
}
