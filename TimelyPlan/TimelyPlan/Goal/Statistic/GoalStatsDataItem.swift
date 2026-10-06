//
//  GoalStatsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation

// MARK: - 目标记录统计条目

/// 目标记录统计条目
final class GoalStatsDataItem {

    /// 目标任务
    let goalTask: GoalTask

    /// 统计日期区间
    let dateRange: DateRange

    /// 日期区间内的打卡记录
    private(set) var records: [GoalRecord] = []

    init(goalTask: GoalTask, dateRange: DateRange, records: [GoalRecord] = []) {
        self.goalTask = goalTask
        self.dateRange = dateRange
        self.update(records: records)
    }

    // MARK: - 更新
    /// 更新统计记录（仅保留日期区间内的记录）
    func update(records: [GoalRecord]?) {
        guard let records = records else {
            self.records = []
            return
        }

        self.records = records.filter { record in
            guard let date = record.date else {
                return false
            }

            return dateRange.contains(date: date)
        }
    }

    /// 是否有记录
    var isEmpty: Bool {
        return records.isEmpty
    }

    // MARK: - 概览
    /// 记录总次数
    var totalRecordCount: Int {
        return records.count
    }

    /// 记录总量（记录数值合计）
    var totalRecordAmount: Int64 {
        return records.reduce(0) { $0 + $1.amount }
    }

    /// 概览统计项（记录总量、记录总次数）
    func summaries() -> [StatsSummary] {
        return [totalRecordAmountSummary(), totalRecordCountSummary()]
    }

    /// 记录总量
    private func totalRecordAmountSummary() -> StatsSummary {
        var summary = StatsSummary()
        summary.title = resGetString("Total Record Amount")
        if totalRecordCount > 0 {
            summary.value = "\(totalRecordAmount)"
        }

        return summary
    }

    /// 记录总次数
    private func totalRecordCountSummary() -> StatsSummary {
        var summary = StatsSummary()
        summary.title = resGetString("Total Record Times")

        let count = totalRecordCount
        if count > 0 {
            let badge: String = resGetString(count > 1 ? "Times(count)" : "Time(count)")
            summary.attributedValue = StatsSummary.attributedValue(text: "\(count)",
                                                                   badge: badge)
        }

        return summary
    }

    // MARK: - 打卡分布（按天 / 按月）
    /// 每天的打卡次数
    private var dailyCheckinCounts: [DayIntegerKey: Int] {
        var counts = [DayIntegerKey: Int]()
        for record in records {
            guard let day = record.day else {
                continue
            }

            counts[day, default: 0] += 1
        }

        return counts
    }

    /// 每月的打卡次数
    private var monthlyCheckinCounts: [Int: Int] {
        var counts = [Int: Int]()
        for record in records {
            guard let date = record.date else {
                continue
            }

            counts[date.month, default: 0] += 1
        }

        return counts
    }

    /// 按天打卡分布图表标记（周、月）
    func dailyCheckinCountChartMarks(xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        guard let startDate = dateRange.startDate else {
            return []
        }

        let daysCount = dateRange.lastsCount()
        guard daysCount > 0 else {
            return []
        }

        let counts = dailyCheckinCounts
        var marks = [ChartMark]()
        for index in 0..<daysCount {
            guard let date = startDate.dateByAddingDays(index),
                  let count = counts[date.dayIntegerKey], count > 0 else {
                continue
            }

            var mark = ChartMark(x: xValueForDate(date), y: CGFloat(count))
            mark.highlightText = "\(date.monthDayString), \(countText(count))"
            marks.append(mark)
        }

        return marks
    }

    /// 按月打卡分布图表标记（年）
    func monthlyCheckinCountChartMarks() -> [ChartMark] {
        var marks = [ChartMark]()
        for (month, count) in monthlyCheckinCounts where count > 0 {
            var mark = ChartMark(x: CGFloat(month), y: CGFloat(count))
            let symbol = Date.monthSymbol(ofMonth: month)
            mark.highlightText = "\(symbol) • \(countText(count))"
            marks.append(mark)
        }

        return marks
    }

    // MARK: - 打卡时间段分布
    /// 按小时的打卡次数
    private var hourlyCheckinCounts: [Int: Int] {
        var counts = [Int: Int]()
        for record in records {
            guard let date = record.date else {
                continue
            }

            counts[date.hour, default: 0] += 1
        }

        return counts
    }

    /// 按小时打卡时间段分布图表标记
    func hourlyCheckinCountChartMarks() -> [ChartMark] {
        var marks = [ChartMark]()
        for (hour, count) in hourlyCheckinCounts where count > 0 {
            var mark = ChartMark(x: CGFloat(hour), y: CGFloat(count))

            /// 时间字符串
            var toHour = hour + 1
            if toHour == HOURS_PER_DAY {
                toHour = 0
            }

            let timeString = String(format: "%02ld:00~%02ld:00", hour, toHour)
            mark.highlightText = "\(timeString) • \(countText(count))"
            marks.append(mark)
        }

        return marks
    }

    // MARK: - 打卡时间分布
    /// 打卡时间点图表标记（y 轴为记录发生在当天的秒数偏移）
    func checkinTimePointChartMarks(xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        var marks = [ChartMark]()
        for record in records {
            guard let date = record.date else {
                continue
            }

            let offset = date.offset()
            var mark = ChartMark(x: xValueForDate(date), y: CGFloat(offset))
            mark.highlightText = "\(date.monthDayShortWeekdaySymbolString), \(offset.timeString)"
            marks.append(mark)
        }

        return marks
    }

    // MARK: - 热力图
    /// 每天的记录数值合计
    private var dailyRecordAmounts: [DayIntegerKey: Int64] {
        var amounts = [DayIntegerKey: Int64]()
        for record in records {
            guard let day = record.day else {
                continue
            }

            amounts[day, default: 0] += record.amount
        }

        return amounts
    }

    /// 某天记录的数值合计（无记录时为 nil）
    func recordAmount(on date: Date) -> Int64? {
        return dailyRecordAmounts[date.dayIntegerKey]
    }

    /// 单日最大记录数值（取绝对值，用于热力图分级）
    var maxDailyRecordAmount: Int64 {
        return dailyRecordAmounts.values.map { abs($0) }.max() ?? 0
    }

    // MARK: - Helpers
    /// 打卡次数文本
    private func countText(_ count: Int) -> String {
        let unit: String = resGetString(count > 1 ? "times(count)" : "time(count)")
        return "\(count) \(unit)"
    }
}
