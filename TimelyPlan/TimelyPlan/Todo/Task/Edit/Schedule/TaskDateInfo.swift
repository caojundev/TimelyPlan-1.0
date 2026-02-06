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
    
    /// 开始日期
    private(set) var startDate: Date
    
    /// 是否全天
    private(set)var isAllDay: Bool
    
    /// 持续时长
    private(set)var duration: Duration

    /// 结束日期
    var endDate: Date {
        if isAllDay {
            return startDate.endOfDay()
        }
        
        return startDate.dateByAddingSeconds(duration) ?? startDate
    }
    
    /// 是否已经逾期
    var isOverdue: Bool {
        return Date.now > endDate
    }
    
    static func allDayDateInfo(startDate: Date) -> TaskDateInfo {
        let dateInfo = TaskDateInfo(startDate: startDate.startOfDay(),
                                    isAllDay: true,
                                    duration: SECONDS_PER_DAY)
        return dateInfo
    }
    
    init() {
        self.init(startDate: .now.startOfDay(), isAllDay: true, duration: 0)
    }
    
    init(startDate: Date, endDate: Date, isAllDay: Bool) {
        if isAllDay {
            self.init(startDate: startDate.startOfDay(), isAllDay: true, duration: SECONDS_PER_DAY)
        } else {
            var duration = Duration(endDate.timeIntervalSince(startDate))
            if duration < SECONDS_PER_MINUTE {
                duration = SECONDS_PER_MINUTE
            }

            self.init(startDate: startDate, isAllDay: false, duration: duration)
        }
    }
    
    init(startDate: Date, duration: Duration) {
        self.init(startDate: startDate, isAllDay: false, duration: duration)
    }
    
    init(startDate: Date, isAllDay: Bool, duration: Duration) {
        self.startDate = startDate
        self.duration = duration
        self.isAllDay = isAllDay
    }
    
    mutating func setStartDate(_ date: Date) {
        /// 将时间替换成当前开始日期时间部分
        startDate = date.dateByReplacingTime(with: startDate)
    }

    mutating func setSpecificTime(with date: Date) {
        isAllDay = false
        startDate = startDate.dateByReplacingTime(with: date)
        if duration < SECONDS_PER_MINUTE || duration >= SECONDS_PER_DAY {
            duration = SECONDS_PER_MINUTE
        }
    }
    
    mutating func clearSpecificTime() {
        isAllDay = true
        startDate = startDate.startOfDay()
    }
    
    mutating func setDuration(_ duration: Duration) {
        self.duration = duration
    }

    /// 清除持续时长
    mutating func clearDuration() {
        self.duration = 0
        /// 切换为全天任务
        self.isAllDay = true
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
}
