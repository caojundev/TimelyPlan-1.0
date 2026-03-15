//
//  HabitPeriodTask+Stats.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation

typealias HabitDailyCheckinTimeResults = [DayIntegerKey: Set<Duration>]

extension HabitPeriodTask {
    
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
            let score = records[date.dayIntegerKey]?.score ?? 0
            var mark = ChartMark(x: x, y: CGFloat(score))
            mark.highlightText = "\(date.monthDayShortWeekdaySymbolString), \(score)"
            marks.append(mark)
        }
        
        return marks
    }
    
    // MARK: - 按月份完成数目统计
    
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
    
    // MARK: - 饼状图
    /// 任务状态天数饼状图信息
    func statusDayCountPieVisual() -> PieVisual {
        let slices = statusDayCountPieSlices()
        return PieVisual(slices: slices, colors: nil)
    }
    
    /// 任务状态天数对应的饼状图切片
    private func statusDayCountPieSlices() -> [PieSlice] {
        guard let records = self.records else {
            return []
        }
        
        let totalDays = period.pastDaysCount
        print(totalDays)
        if totalDays <= 0 {
            return []
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
        
        infos[.notStarted] = max((totalDays - recordDays), 0)
        return statusDayCountPieSlices(for: infos, totalDays: totalDays)
    }
    
    private func statusDayCountPieSlices(for infos: [HabitTaskStatus: Int],
                                         totalDays: Int) -> [PieSlice] {
        let infos = infos.sorted { $0.value > $1.value }
        var slices = [PieSlice]()
        for (status, count) in infos {
            let title = status.title
            let format: String
            if count > 1 {
                format = resGetString("%ld days")
            } else {
                format = resGetString("%ld day")
            }
            
            var details: [String] = []
            if status.isSkipped {
                details.append(resGetString("Skipped"))
            } else if status.isFailed {
                details.append(resGetString("Failed"))
            }
            
            let daysDetail = String(format: format, count)
            details.append(daysDetail)
            let detail = details.joined(separator: " • ")
            
            let percent = Double(count) / Double(totalDays)
            let slice = PieSlice(title: title, detail: detail, percent: percent)
            slices.append(slice)
        }
    
        return slices
    }
}
