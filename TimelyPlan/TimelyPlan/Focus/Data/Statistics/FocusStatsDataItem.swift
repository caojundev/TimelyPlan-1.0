//
//  FocusStatsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/21.
//

import Foundation

class FocusStatsDataItem {
    
    /// 当前任务
    var task: TaskRepresentable?

    /// 计时器
    var timer: FocusTimer?
    
    /// 统计日期范围
    var dateRange: DateRange

    /// 当前统计范围内所有会话数组
    var sessions: [FocusSession]?
    
    /// 当前周期专注次数
    var count: Int? {
        return sessions?.count
    }
    
    var validFragments: [TimeFragment]? {
        return sessions?.validFragments
    }
    
    /// 当前周期专注时长
    var duration: Duration? {
        guard let sessions = sessions else { return nil }
        return sessions.duration
    }
    
    /// 平均得分
    var averageScore: Int? {
        guard let sessions = sessions else { return nil }
        return sessions.averageScore
    }
    
    /// 中断次数
    var pauseCount: Int? {
        guard let sessions = sessions else { return nil }
        return sessions.pauseCount
    }
    
    /// 习惯日信息字典
    var daySessions: [DayStringKey: [FocusSession]]? {
        guard let sessions = sessions else { return nil }
        var dic = [DayStringKey: [FocusSession]]()
        for session in sessions {
            guard let startDate = session.startDate else {
                continue
            }
            
            let key = startDate.dayStringKey
            var daySessions = dic[key] ?? []
            daySessions.append(session)
            dic[key] = daySessions
        }
        
        return dic
    }
    
    var dayInfos: [DayStringKey: FocusStatsDayInfo]? {
        guard let daySessions = daySessions else {
            return nil
        }
        
        /// 解析日信息字典
        var infos = [DayStringKey: FocusStatsDayInfo]()
        for (key, sessions) in daySessions {
            guard let date = Date.dateFromDayStringKey(key) else {
                continue
            }

            let dayInfo = FocusStatsDayInfo(date: date, sessions: sessions)
            infos[key] = dayInfo
        }
        
        return infos
     }
    
    var dayDurations: [DayStringKey: Duration]? {
        guard let daySessions = daySessions else {
            return nil
        }
        
        /// 解析日信息字典
        var infos = [DayStringKey: Duration]()
        for (key, sessions) in daySessions {
            let duration = sessions.duration
            if duration > 0 {
                infos[key] = duration
            }
        }
        
        return infos
     }

    /// 最佳专注时间
    var mostFocusedTimes: [Int: Duration]? {
        guard let sessions = sessions else { return nil }
        
        var dic = [Int: Duration]()
        for session in sessions {
            guard let date = session.startDate else {
                continue
            }
            
            let hour = date.hour
            var duration = dic[hour] ?? 0
            duration += Duration(session.duration)
            dic[hour] = duration
        }
        
        return dic
    }
    
    /// 按月份归类的日信息数组字典
    var monthDayInfos: [Int: [FocusStatsDayInfo]]? {
        guard let dayInfos = dayInfos else {
            return nil
        }
        
        var dic = [Int: [FocusStatsDayInfo]]()
        for dayInfo in dayInfos.values {
            let month = dayInfo.date.month
            var infos = dic[month] ?? []
            infos.append(dayInfo)
            dic[month] = infos
        }
        
        return dic
    }
    
    /// 按月份的专注时长字典
    private var monthDurations: [Int: Duration]? {
        guard let monthDayInfos = monthDayInfos else {
            return nil
        }

        var dic = [Int: Duration]()
        for (month, dayInfos) in monthDayInfos {
            dic[month] = dayInfos.duration
        }
        
        return dic
    }
    
    /// 按月份的平均得分字典
    private var monthAverageScores: [Int: Int]? {
        guard let monthDayInfos = monthDayInfos else {
            return nil
        }

        var dic = [Int: Int]()
        for (month, dayInfos) in monthDayInfos {
            dic[month] = dayInfos.averageScore
        }
        
        return dic
    }
    
    init(task: TaskRepresentable?, timer: FocusTimer?, dateRange: DateRange, sessions: [FocusSession]?) {
        self.task = task
        self.timer = timer
        self.dateRange = dateRange
        self.sessions = sessions ?? []
    }
    
    func orderedSessions(ascending: Bool = true) -> [FocusSession]? {
        guard let sessions = sessions else {
            return nil
        }
        
        let results = sessions.sorted { lSession, rSession in
            guard let lDate = lSession.startDate, let rDate = rSession.startDate else {
                return false
            }
        
            return ascending ? (lDate < rDate) : (lDate >= rDate)
        }
        
        return results
    }

    
    // MARK: - 获取按日期排序的日信息数组
    func orderedDayInfos(ascending: Bool = true) -> [FocusStatsDayInfo]? {
        guard let dayInfos = dayInfos else {
            return nil
        }
        
        var results = Array(dayInfos.values)
        if ascending {
            results = results.sorted { $0.date < $1.date }
        } else {
            results = results.sorted { $0.date >= $1.date }
        }
        
        return results
    }

}

// MARK: - 图表
extension FocusStatsDataItem {
    
    /// 日专注时长图表标记
    func durationChartMarks(xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        guard let dayInfos = dayInfos else {
            return []
        }
        
        var marks = [ChartMark]()
        for info in dayInfos.values {
            let duration = info.duration
            guard duration > 0 else {
                continue
            }

            let x = xValueForDate(info.date)
            var mark = ChartMark(x: x, y: CGFloat(duration))
            mark.highlightText = "\(info.date.monthDayString), \(duration.localizedTitle)"
            marks.append(mark)
        }

        return marks
    }
    
    /// 专注时间线
    func timelineChartMarks(xValueForDate: (Date) -> (start: CGFloat, end: CGFloat)) -> [RectangleChartMark] {
        var marks = [RectangleChartMark]()
        guard let fragments = sessions?.validDailyFragments else { return [] }
        
        for fragment in fragments {
            let (xStart, xEnd) = xValueForDate(fragment.startDate)
            let yStart = CGFloat(fragment.startDate.offset())
            let yEnd = yStart + CGFloat(fragment.interval)
            var mark = RectangleChartMark(xStart: xStart,
                                          xEnd: xEnd,
                                          yStart: yStart,
                                          yEnd: yEnd)
            mark.highlightText = "\(fragment.startDate.timeString)~\(fragment.endDate.timeString), \(fragment.duration.localizedTitle)"
            marks.append(mark)
        }
        
        return marks
    }
    
    /// 特定时间段平均评分图表标记数组
    func scoreChartMarks(in dateRange: DateRange,
                         xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        guard let dayInfos = dayInfos,
              let startDate = dateRange.startDate else {
            return []
        }
        
        var marks: [ChartMark] = []
        let count = dateRange.lastsCount()
        for i in 0..<count {
            let date = startDate.dateByAddingDays(i)!
            if date.isFutureDay {
                /// 未来日期跳出循环
                break
            }
            
            let x = xValueForDate(date)
            let score = dayInfos[date.dayStringKey]?.averageScore ?? 0
            var mark = ChartMark(x: x, y: CGFloat(score))
            mark.highlightText = "\(date.monthDayShortWeekdaySymbolString), \(score)"
            marks.append(mark)
        }
        
        return marks
    }
    
    func mostFocusedTimeChartMarks() -> [ChartMark] {
        var marks = [ChartMark]()
        let times = self.mostFocusedTimes ?? [:]
        for (hour, duration) in times {
            var toHour = hour + 1
            if toHour == HOURS_PER_DAY {
                toHour = 0
            }
            
            let timeString = String(format: "%02ld:00~%02ld:00", hour, toHour)
            var mark = ChartMark(x: CGFloat(hour), y: CGFloat(duration))
            mark.highlightText = "\(timeString), \(duration.localizedTitle)"
            marks.append(mark)
        }
        
        return marks
    }
    
    // MARK: - 年度统计
    func monthDurationChartMarks() -> [ChartMark] {
        guard let monthDurations = monthDurations else {
            return []
        }

        var marks = [ChartMark]()
        for (month, duration) in monthDurations {
            var barMark = ChartMark(x: CGFloat(month), y: CGFloat(duration))
            let symbol = Date.monthSymbol(ofMonth: month)
            barMark.highlightText = "\(symbol) • \(duration.localizedTitle)"
            marks.append(barMark)
        }
        
        return marks
    }

    /// 从1月到12月每月平均得分
    func monthAverageScoreChartMarks() -> [ChartMark] {
        guard let monthAverageScores = monthAverageScores else {
            return []
        }
        
        var marks: [ChartMark] = []
        for month in 1...MONTHS_PER_YEAR {
            if dateRange.isFutureYearRange ||
                (dateRange.contains(date: .now) && month > Date().month) {
                break
            }

            let score = monthAverageScores[month] ?? 0
            var mark = ChartMark(x: CGFloat(month), y: CGFloat(score))
            mark.highlightText = "\(Date.monthSymbol(ofMonth: month)), \(score)"
            marks.append(mark)
        }
        
        return marks
    }
    
    /// 按任务分类的专注时长饼状图切片
    func taskDurationPieSlices() -> [PieSlice] {
        guard let sessions = sessions else { return [] }
        
        var dic = [TaskInfo: [FocusSession]]()
        for session in sessions {
            let taskInfo = session.taskInfo ?? .none
            var sessions = dic[taskInfo] ?? []
            sessions.append(session)
            dic[taskInfo] = sessions
        }
        
        var totalDuration: Duration = 0
        var infos = [(name: String?, duration: Duration)]()
        for (info, value) in dic {
            let duration = value.duration
            let taskName = info.task?.name ?? resGetString("Unknown Task")
            infos.append((taskName, duration))
            totalDuration += duration
        }
        
        return durationPieSlices(for: infos, totalDuration: totalDuration)
    }
    
    /// 按计时器分类的专注时长饼状图切片
    func timerDurationPieSlices() -> [PieSlice] {
        guard let sessions = sessions else { return [] }
        
        var dic = [TimerFeature: [FocusSession]]()
        for session in sessions {
            let feature = session.timerFeature ?? .none
            var sessions = dic[feature] ?? []
            sessions.append(session)
            dic[feature] = sessions
        }
        
        var totalDuration: Duration = 0
        var infos = [(name: String?, duration: Duration)]()
        for (feature, value) in dic {
            let duration = value.duration
            var timerName: String?
            if let timer = feature.timer {
                timerName = timer.name
            } else {
                timerName = feature.shotName ?? resGetString("Unknown Timer")
            }

            infos.append((timerName, duration))
            totalDuration += duration
        }
        
        return durationPieSlices(for: infos, totalDuration: totalDuration)
    }
    
    private func durationPieSlices(for infos: [(name: String?, duration: Duration)], totalDuration: Duration) -> [PieSlice] {
        let infos = infos.sorted { $0.duration > $1.duration }
        var slices = [PieSlice]()
        for info in infos {
            let title = info.name
            let detail = info.duration.localizedTitle
            let percent = Double(info.duration) / Double(totalDuration)
            let slice = PieSlice(title: title, detail: detail, percent: percent)
            slices.append(slice)
        }
    
        return slices
    }
}
