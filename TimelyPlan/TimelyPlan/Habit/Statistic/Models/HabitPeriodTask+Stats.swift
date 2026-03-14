//
//  HabitPeriodTask+Stats.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation

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
    
    /// 键是日期的字符串形式，值表示当天的打卡时间集合
    var dailyCheckInTimes: [DayIntegerKey: Set<Duration>]? {
        guard let records = self.records else {
            return nil
        }
        
        var result = [DayIntegerKey: Set<Duration>]()
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
}
