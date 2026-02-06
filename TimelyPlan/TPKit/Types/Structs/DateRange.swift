//
//  DateRange.swift
//  TimelyPlan
//
//  Created by caojun on 2023/4/18.
//

import Foundation

/// 日期范围编辑类型
enum DateRangeEditType: Int, TPMenuRepresentable {
    case start
    case end
    
    static func titles() -> [String] {
        return ["Start Date",
                "End Date"]
    }
}

struct DateRange: DateRangeProtocol, Hashable, Codable {
    
    /// 开始日期
    var startDate: Date?
    
    /// 结束日期
    var endDate: Date?
    
    init() {
        self.startDate = Date().startOfDay()
        self.endDate = nil
    }
    
    init(startDate: Date?, endDate: Date?) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    /// 判断两个日期是否有交集
    func intersects(with otherRange: DateRange) -> Bool {
        /// 转换为数值的判断
        var currentStart: TimeInterval = 0.0
        if let startDate = startDate {
            currentStart = startDate.timeIntervalSince1970
        }
        
        var currentEnd: TimeInterval = .greatestFiniteMagnitude
        if let endDate = endDate {
            currentEnd = endDate.timeIntervalSince1970
        }
        
        var otherStart: TimeInterval = 0.0
        if let startDate = otherRange.startDate {
            otherStart = startDate.timeIntervalSince1970
        }
        
        var otherEnd: TimeInterval = .greatestFiniteMagnitude
        if let endDate = otherRange.endDate {
            otherEnd = endDate.timeIntervalSince1970
        }
        
         return currentStart <= otherEnd && currentEnd >= otherStart
     }
    
    /// 是否是过去年份范围
    var isPreviousYearRange: Bool {
        guard let endDate = endDate else {
            return false
        }

        let date = Date.now.startOfYear()
        return date.isFutureDay(of: endDate)
    }
    
    /// 是否是未来年
    var isFutureYearRange: Bool {
        guard let startDate = startDate else {
            return false
        }

        let date = Date.now.endOfYear()
        return startDate.isFutureDay(of: date)
    }
}

protocol DateRangeProtocol: AttributedDescriptable {
    
    /// 开始日期
    var startDate: Date? {get set}
    
    /// 结束日期
    var endDate: Date? {get set}
    
    /// 开始日期文本
    func startDateText() -> String
    
    /// 结束日期文本
    func endDateText() -> String

    /// 持续天数
    func lastsCount() -> Int

    /// 持续天数显示文本
    func lastsCountText() -> String
    
    /// 是否是有效范围（条件：持续天数 > 0）
    func isValidRange() -> Bool
    
    /// 判断该时间范围内是否包含该日期
    func contains(date: Date) -> Bool
    
    func intersection(with otherRange: DateRange) -> DateRange?
    
    func isAllDay() -> Bool
}

extension DateRangeProtocol {
    
    func isAllDay() -> Bool {
        return false
    }
    
    /// 是否有开始或结束日期
    var hasDate: Bool {
        if startDate != nil || endDate != nil {
            return true
        }
        
        return false
    }
    
    func isValidRange() -> Bool {
        guard startDate != nil else {
            /// 无开始日期，始终表示一个有效范围
            return true
        }
        
        /// 有开始日期，持续天数需要大于 0
        return lastsCount() >= 0
    }

    /// 判断该时间范围内是否包含该日期
    func contains(date: Date) -> Bool {
        if !isValidRange() {
            return false
        }
        
        guard let startDate = startDate?.startOfDay() else {
            if let endDate = endDate?.endOfDay(){
                /// 结束日期不能早于当前日期
                return endDate.compare(date) != .orderedAscending
            } else {
                /// 无开始无结束日期
                return true
            }
        }
        
        if date.compare(startDate) == .orderedAscending {
            /// 早于开始日期
            return false
        }
        
        /// 无结束日期
        guard let endDate = endDate?.endOfDay() else {
            return true
        }
        
        return endDate.compare(date) != .orderedAscending
    }


    func startDateText() -> String {
        return displayTextForDate(startDate)
    }

    /// 开始日期的描述文本
    func startDateDescription() -> String {
        let date = startDate ?? Date()
        if date.isToday {
            return resGetString("Today")
        } else if date.isYesterday {
            return resGetString("Yesterday")
        } else if date.isTomorrow {
            return resGetString("Tomorrow")
        }
        
        /// 计算天数
        let lastsCount = lastsDaysCount(fromDate: Date(), toDate: date)
        let intervalDays: Int ///
        let format: String
        if lastsCount > 0 {
            intervalDays = labs(lastsCount - 1)
            format = resGetString("%ld days later")
        } else {
            intervalDays = labs(lastsCount + 1)
            format = resGetString("%ld days before")
        }
        
        return String(format: format, intervalDays)
    }
    
    func endDateText() -> String {
        return displayTextForDate(endDate)
    }
    
    private func displayTextForDate(_ date: Date?) -> String {
        if let date = date {
            return date.yearMonthDayWeekdaySymbolString(omitYear: true)
        }
        
        return resGetString("None")
    }
    
    /// 持续天数显示文本
    func lastsCountText() -> String {
        let startDate = startDate ?? Date()
        let count = lastsDaysCount(fromDate: startDate, toDate: endDate)
        if count == NSNotFound {
            /// 永不结束
            return resGetString("Never End")
        }
        
        var format: String
        if labs(count) <= 1 {
            format = resGetString("%ld day")
        } else {
            format = resGetString("%ld days")
        }
        
        return String(format: format, count)
    }
    
    /// 持续天数
    func lastsCount() -> Int {
        guard let startDate = startDate else {
            return 0
        }

        return lastsDaysCount(fromDate: startDate, toDate: endDate)
    }
    
    func lastsCountDescription() -> String {
        if endDate != nil {
            return resGetString("Lasts:") + " " + lastsCountText()
        }
        
        return lastsCountText()
    }
    

    /// 获取两个日期之间间隔天数（开始结束同一天，天数为 1）
    /// - Parameters:
    ///   - fromDate: 开始日期
    ///   - toDate: 结束日期
    /// - Returns: 如果无法计算间隔，则返回NSNotFound
    private func lastsDaysCount(fromDate: Date, toDate: Date?) -> Int {
        guard let toDate = toDate else {
            return NSNotFound
        }
        
        let count = Date.days(fromDate: fromDate, toDate: toDate)
        if count >= 0 {
            return count + 1 /// 总天数+1s
        } else {
            return count - 1
        }
    }
    
    /// 返回两个日期的交集，日期范围开始和结束日期必须都不为 nil
    func intersection(with otherRange: DateRange) -> DateRange? {
        guard let currentStartDate = startDate,
              let currentEndDate = endDate,
              let otherStartDate = otherRange.startDate,
              let otherEndDate = otherRange.endDate else {
            return nil
        }
                
        let start = max(currentStartDate, otherStartDate)
        let end = min(currentEndDate, otherEndDate)
        if start <= end {
            return DateRange(startDate: start, endDate: end)
        }
        
        return nil
     }
}

extension DateRangeProtocol {
    
    /// 时间富文本信息
    func dateAttributedInfo() -> ASAttributedString? {
        var infos = [ASAttributedString]()
        if let startInfo = startDateAttributedInfo() {
            infos.append(startInfo)
        }
        
        if let endInfo = endDateAttributedInfo() {
            infos.append(endInfo)
        }
        
        return infos.joined(separator: " ")
    }
    
    func startDateAttributedInfo() -> ASAttributedString? {
        guard let startDate = startDate else {
            return nil
        }
        
        let dateString = startDate.monthDayShortWeekdaySymbolString
        return "\(resGetString("Starting")) \(dateString, highlightedTextColor)"
    }
    
    func endDateAttributedInfo() -> ASAttributedString? {
        guard let endDate = endDate else {
            return nil
        }
        
        let dateString = endDate.monthDayShortWeekdaySymbolString
        return "\(resGetString("until")) \(dateString, highlightedTextColor)"
    }
    
    /// 时间范围富文本
    func attributedTimeRange() -> ASAttributedString? {
        guard let startDate = startDate, let endDate = endDate else {
            return nil
        }
        
        let startString = startDate.timeString
        let endString: ASAttributedString
        if startDate.isInSameDayAs(endDate) {
            endString = "\(endDate.timeString)"
        } else {
            let days = Date.days(fromDate: startDate, toDate: endDate)
            endString = endDate.timeString.byAppend(badge: " +\(days)")
        }
        
        return startString + " - " + endString
    }
    
    /// 返回简单的时间范围字符串
    func simpleTimeRangeString() -> String? {
        guard let startDate = startDate, let endDate = endDate else {
            return nil
        }
        
        let startString = startDate.timeString
        let endString = "\(endDate.timeString)"
        return startString + " - " + endString
    }
}
