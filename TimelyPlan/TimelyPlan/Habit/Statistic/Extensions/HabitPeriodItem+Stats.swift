//
//  HabitPeriodItem+Stats.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation

typealias HabitDailyCheckinTimeResults = [DayIntegerKey: Set<Duration>]
typealias HabitMonthGroupedRecords = [Int: [HabitRecord]]

extension HabitPeriodItem {
    
    /// 完成数目
    func recordAmountChartMarks(in dateRange: DateRange, xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        guard let records = self.records else {
            return []
        }
        
        var marks = [ChartMark]()
        for (day, record) in records {
            let date = Date.dateFromDayIntegerKey(day)
            guard let date = date, dateRange.contains(date: date), record.amount > 0 else {
                continue
            }
            
            let x = xValueForDate(date)
            var mark = ChartMark(x: x, y: CGFloat(record.amount))
            mark.highlightText = "\(date.monthDayString), \(record.amount)"
            marks.append(mark)
        }
        
        return marks
    }
    
    private var dailyCheckInTimes: HabitDailyCheckinTimeResults? {
        guard let records = self.records else {
            return nil
        }
        
        var result = HabitDailyCheckinTimeResults()
        for (day, record) in records {
            result[day] = record.sampleTimeOffsets
        }
        
        return result
    }
    

    /// 周按日打卡时间点标记数组
    func checkinTimePointMarksForWeek(in dateRange: DateRange,
                                      xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        guard let dailyCheckInTimes = dailyCheckInTimes else {
            return []
        }

        var pointMarks: [ChartMark] = []
        for (day, value) in dailyCheckInTimes {
            let date = Date.dateFromDayIntegerKey(day)
            guard let date = date, dateRange.contains(date: date) else {
                continue
            }
            
            let weekIndex = xValueForDate(date)
            let marks = value.map { duration -> ChartMark in
                var mark = ChartMark(x: weekIndex, y: CGFloat(duration))
                mark.highlightText = "\(date.monthDayShortWeekdaySymbolString), \(duration.timeString)"
                return mark
            }
            
            pointMarks.append(contentsOf: marks)
        }
        
        return pointMarks
    }
    
    /// 键是日期的字符串形式，值表示当天的打卡时间集合
    private var hourlyCheckinResults: HabitHourlyCheckinResults {
        guard let records = self.records else {
            return [:]
        }
        
        var totalResults = HabitHourlyCheckinResults()
        for (_, record) in records {
            guard let recordResults = record.hourlyCheckinResults else {
                continue
            }
            
            for (hour, count) in recordResults {
                let currentCount = totalResults[hour] ?? 0
                totalResults[hour] = currentCount + count
            }
        }
        
        return totalResults
    }
    
    func hourlyCheckInCountChartMarks() -> [ChartMark] {
        var marks = [ChartMark]()
        for (hour, count) in hourlyCheckinResults {
            guard count > 0 else {
                continue
            }
            
            var mark = ChartMark(x: CGFloat(hour), y: CGFloat(count))
            let unit: String = resGetString(count > 1 ? "times(count)" : "time(count)")
            let countString = "\(count) \(unit)"
            
            /// 时间字符串
            var toHour = hour + 1
            if toHour == HOURS_PER_DAY {
                toHour = 0
            }
            
            let timeString = String(format: "%02ld:00~%02ld:00", hour, toHour)
            mark.highlightText = "\(timeString) • \(countString)"
            marks.append(mark)
        }
        
        return marks
    }
    
    /// 特定时间段平均评分图表标记数组
    func scoreChartMarks(in dateRange: DateRange,
                         xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        guard let records = self.records, let startDate = dateRange.startDate else {
            return []
        }
        
        var marks = [ChartMark]()
        let count = dateRange.lastsCount()
        for i in 0..<count {
            guard let date = startDate.dateByAddingDays(i), !date.isFutureDay else {
                continue
            }
            
            let x = xValueForDate(date)
            
            var score = records[date.dayIntegerKey]?.score
            if score == nil, !isScheduledDate(date) {
                /// 非计划日，评分设置为100
                score = 100
            }
            
            let markScore = score ?? 0
            var mark = ChartMark(x: x, y: CGFloat(markScore))
            mark.highlightText = "\(date.monthDayShortWeekdaySymbolString), \(markScore)"
            marks.append(mark)
        }
        
        return marks
    }

    // MARK: - 饼状图
    /// 任务状态天数饼状图信息
    func statusDayCountPieVisual(_ recordDays: inout Int) -> PieVisual {
        let info = statusDayCountPieSlicesInfo()
        recordDays = info.recordDays
        return PieVisual(slices: info.slices) { othersSlices in
            let days: Int = othersSlices.totalAddtionalCount()
            let percent = othersSlices.totalPercent
            return PieSlice(title: resGetString("Others"),
                            detail: days.dayCountStirng,
                            percent: percent)
        }
    }

    /// 任务状态天数对应的饼状图切片
    private func statusDayCountPieSlicesInfo() -> (slices: [PieSlice], recordDays: Int) {
        guard let records = self.records else {
            return ([], 0)
        }
        
        var infos = [HabitTaskStatus: Int]()
        var recordDays = 0
        for (_, record) in records {
            let status = status(with: record)
            if status != .notStarted {
                let currentDays = infos[status] ?? 0
                infos[status] = currentDays + 1
                recordDays += 1
            }
        }
        
        let slices = statusDayCountPieSlices(for: infos, recordDays: recordDays)
        return (slices, recordDays)
    }
    

    private func statusDayCountPieSlices(for infos: [HabitTaskStatus: Int],
                                         recordDays: Int) -> [PieSlice] {
        let infos = infos.sorted { $0.value > $1.value }
        var slices = [PieSlice]()
        for (status, count) in infos {
            var details: [String] = []
            if status.isSkipped {
                details.append(resGetString("Skipped"))
            } else if status.isFailed {
                details.append(resGetString("Failed"))
            }
            
            let daysDetail = count.dayCountStirng
            details.append(daysDetail)
            let detail = details.joined(separator: " • ")
            
            let percent = Double(count) / Double(recordDays)
            let slice = PieSlice(title: status.title,
                                 detail: detail,
                                 percent: percent,
                                 addtional: count)
            slices.append(slice)
        }
    
        return slices
    }
    
    func statsLogs() -> [HabitStatsLog]? {
        guard let records = self.records else {
            return nil
        }
        
        var logs = [HabitStatsLog]()
        for (_, record) in records {
            guard let date = record.date else {
                continue
            }
            
            let status = status(with: record)
            if status != .notStarted, status != .inProgress {
                let log = HabitStatsLog(date: date,
                                        status: status,
                                        content: record.log,
                                        score: Int(record.score))
                logs.append(log)
            }
        }
        
        return logs.sorted { $0.date < $1.date }
    }
    
    
    /// 将记录以月份归类
    func monthGroupedRecords() -> HabitMonthGroupedRecords? {
        guard let records = self.records else {
            return nil
        }
        
        var result = HabitMonthGroupedRecords()
        for record in records.values {
            guard let date = record.date else {
                continue
            }
            
            let month = date.month
            var array = result[month] ?? []
            array.append(record)
            result[month] = array
        }
        
        return result
    }
}

// MARK: -  按月份
extension HabitPeriodItem {
    
    /// 年度按月打卡数目字典
    private var monthlyCheckinAmountForYear: [Int: Int64] {
        var monthlyAmount = [Int: Int64]()
        guard let records = self.records else {
            return monthlyAmount
        }

        for record in records.values {
            guard record.amount > 0, let date = record.date else {
                continue
            }
            
            let month = date.month
            let monthAmount = monthlyAmount[month] ?? 0
            monthlyAmount[month] = monthAmount + record.amount
        }
        
        return monthlyAmount
    }
    
    func monthlyCheckinAmountChartMarks() -> [ChartMark] {
        var marks = [ChartMark]()
        for (month, amount) in monthlyCheckinAmountForYear {
            var barMark = ChartMark(x: CGFloat(month), y: CGFloat(amount))
            let symbol = Date.monthSymbol(ofMonth: month)
            barMark.highlightText = "\(symbol) • \(amount)"
            marks.append(barMark)
        }
        
        return marks
    }
    
    /// 月均分数字典
    private var monthlyAverageScoreForYear: [Int: Int] {
        guard let records = self.records else {
            return [:]
        }

        var monthScoreInfoDic = [Int: (days: Int, sumScore: Int)]()
        for record in records.values {
            guard let date = record.date else {
                continue
            }
            
            let month = date.month
            let monthScoreInfo = monthScoreInfoDic[month] ?? (0, 0)
            let days = monthScoreInfo.days + 1
            let sumScore = monthScoreInfo.sumScore + Int(record.score)
            monthScoreInfoDic[month] = (days, sumScore)
        }
        
        var monthlyAverageScoreDic = [Int: Int]()
        for (month, scoreInfo) in monthScoreInfoDic {
            monthlyAverageScoreDic[month] = scoreInfo.sumScore / scoreInfo.days
        }
        
        return monthlyAverageScoreDic
    }
    
    func monthlyAverageScoreChartMarks() -> [ChartMark] {
        let monthlyAverageScoreDic = monthlyAverageScoreForYear
        var marks = [ChartMark]()
        for (month, score) in monthlyAverageScoreDic {
            var barMark = ChartMark(x: CGFloat(month), y: CGFloat(score))
            let symbol = Date.monthSymbol(ofMonth: month)
            barMark.highlightText = "\(symbol) • \(score)"
            marks.append(barMark)
        }
        
        return marks
    }
    
}


// MARK: - 概览
extension HabitPeriodItem {
    
    func summaries() -> [StatsSummary] {
        var results: [StatsSummary] = []
        if habitTask.goal.mode == .amount {
            results.append(contentsOf: amountSummaries())
        }
        
        let finishedDaysSummary = finishedDaysSummary()
        results.append(finishedDaysSummary)
        
        let averageScoreSummary = averageScoreSummary()
        results.append(averageScoreSummary)
        
        return results
    }
    
    func amountSummaries() -> [StatsSummary] {
        var completedAmount: Int64 = 0
        var averageAmount: Int64 = 0
        if let records = self.records?.values, records.count > 0 {
            completedAmount = Array(records).recordAmount
            averageAmount = completedAmount / Int64(records.count)
        }
        
        let completedAmountSummary = completedAmountSummary(amount: completedAmount)
        let dailyAverageAmountSummary = dailyAverageAmountSummary(amount: averageAmount)
        return [completedAmountSummary, dailyAverageAmountSummary]
    }
    
    func completedAmountSummary(amount: Int64) -> StatsSummary {
        var summary = StatsSummary()
        summary.title = resGetString("Completed Amount")
        if amount > 0 {
            summary.attributedValue = "\(amount)"
        }
        
        return summary
    }
    
    /// 日平均记录数目
    func dailyAverageAmountSummary(amount: Int64) -> StatsSummary {
        var summary = StatsSummary()
        summary.title = resGetString("Daily Avg Amount")
        if amount > 0 {
            summary.attributedValue = "\(amount)"
        }
        
        return summary
    }
    
    /// 日平均得分
    func averageScoreSummary() -> StatsSummary {
        var summary = StatsSummary()
        summary.title = resGetString("Daily Avg Score")
        if let records = self.records?.values, records.count > 0 {
            let score = Array(records).averageScore
            summary.value = "\(score)"
        } else {
            summary.value = "---"
        }
        
        return summary
    }
    
    /// 完成天数
    func finishedDaysSummary() -> StatsSummary {
        var summary = StatsSummary()
        summary.title = resGetString("Finished Days")
        
        if let records = self.records?.values, records.count > 0 {
            let finishedDays = Array(records).finishedDays(for: habitTask)
            summary.attributedValue = daysAttributedTitle(with: finishedDays)
        } else {
            summary.value = "---"
        }
        
        return summary
    }
    
    // MARK: - Helpers
    /// 获取天数富文本
    func daysAttributedTitle(with count: Int?) -> ASAttributedString? {
        guard let count = count, count > 0 else {
            return nil
        }
        
        let badge: String = count > 1 ? resGetString("days") : resGetString("day")
        return StatsSummary.attributedValue(text: "\(count)", badge: badge, badgeColor: summaryTextColor)
    }

    /// 符号文本颜色
    var summaryTextColor: UIColor {
        return .primary.withAlphaComponent(0.8)
    }
    
}
