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
    
    init(style: Style = .singleDay) {
        let date = Date()
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
    
    // MARK: - Getters
    func title(slashFormatted: Bool = true) -> String {
        if isAllDay {
            let dateString = startDate.yearMonthDayString(omitYear: true,
                                                          showRelativeDate: true,
                                                          slashFormatted: slashFormatted)
            return "\(dateString) • \(resGetString("All-Day"))"
        }
        
        let startDateString = startDate.yearMonthDayTimeString(omitYear: true, showRelativeDate: true)
        let endTimeString = endDate.timeString
        return "\(startDateString) - \(endTimeString)"
    }
    
    func attributedTitle(slashFormatted: Bool = true,
                         textColor: UIColor = .primary,
                         badgeBaselineOffset: CGFloat = 6.0,
                         badgeFont: UIFont = UIFont.boldSystemFont(ofSize: 6.0)) -> ASAttributedString {
        if isAllDay {
            let dateString = startDate.yearMonthDayString(omitYear: true, showRelativeDate: true, slashFormatted: slashFormatted)
            return "\(dateString) • \(resGetString("All-Day"))".attributedString(textColor: textColor)
        }
        
        let startDateString = startDate.yearMonthDayTimeString(omitYear: true,
                                                               showRelativeDate: true,
                                                               slashFormatted: slashFormatted)
        let attributedStartDate = startDateString.attributedString(textColor: textColor)
        let attributedSeparator = "-".attributedString(textColor: textColor)
        let attributedEndDate = attributedEndDateString(textColor: textColor,
                                                        badgeBaselineOffset: badgeBaselineOffset,
                                                        badgeFont: badgeFont)
        return attributedStartDate + attributedSeparator + attributedEndDate
    }
    
    func attributedDurationEndDateString(textColor: UIColor = .primary,
                                         badgeBaselineOffset: CGFloat = 6.0,
                                         badgeFont: UIFont = UIFont.boldSystemFont(ofSize: 6.0)) -> ASAttributedString {
        let attributedDuration = duration.localizedTitle.attributedString(textColor: textColor)
        let attributedSeparator = " → ".attributedString(textColor: textColor)
        let attributedEndDate = attributedEndDateString(textColor: textColor,
                                                        badgeBaselineOffset: badgeBaselineOffset,
                                                        badgeFont: badgeFont)
        return attributedDuration + attributedSeparator + attributedEndDate
    }
    
    func attributedEndDateString(textColor: UIColor = .primary,
                                 badgeBaselineOffset: CGFloat = 6.0,
                                 badgeFont: UIFont = UIFont.boldSystemFont(ofSize: 6.0)) -> ASAttributedString {
        let endDate = endDate
        var attributedEndString = endDate.timeString.attributedString(textColor: textColor)
        let daysCount = startDate.daysBetween(endDate)
        if daysCount > 0 {
            attributedEndString = attributedEndString.byAppend(badge: "+\(daysCount)",
                                                               baselineOffset: badgeBaselineOffset,
                                                               font: badgeFont,
                                                               color: textColor)
        }
        
        return attributedEndString
    }
    
    // MARK: - Helpers
    static func allDayDateInfo(startDate: Date) -> TaskDateInfo {
        let dateInfo = TaskDateInfo(startDate: startDate.startOfDay(),
                                    endDate: startDate.endOfDay(),
                                    isAllDay: true)
        return dateInfo
    }
}
