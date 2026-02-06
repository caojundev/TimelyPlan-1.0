//
//  Focus+Statistics.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/22.
//

import Foundation

extension Focus {
    
    // MARK: - 获取特定任务统计数据
    /// 获取日统计数据
    func fetchDailyStats(forTask task: TaskRepresentable? = nil,
                         timer: FocusTimer? = nil,
                         on date: Date,
                         completion: @escaping(FocusStatsDataItem) -> Void) {
        let dateRange = date.rangeOfThisDay()
        fetchStats(forTask: task, timer: timer, dateRange: dateRange, completion: completion)
    }
    
    /// 获取周统计数据
    func fetchWeeklyStats(forTask task: TaskRepresentable? = nil,
                          timer: FocusTimer? = nil,
                          inWeekContaining date: Date,
                          firstWeekday: Weekday = .firstWeekday,
                          completion: @escaping(FocusStatsDataItem) -> Void) {
        let dateRange = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        fetchStats(forTask: task, timer: timer, dateRange: dateRange, completion: completion)
    }
    
    /// 获取月统计数据
    func fetchMonthlyStats(forTask task: TaskRepresentable? = nil,
                           timer: FocusTimer? = nil,
                           inMonthContaining date: Date,
                           completion: @escaping(FocusStatsDataItem) -> Void) {
        let dateRange = date.rangeOfThisMonth()
        fetchStats(forTask: task, timer: timer, dateRange: dateRange, completion: completion)
    }
    
    /// 获取年数据
    func fetchYearlyStats(forTask task: TaskRepresentable? = nil,
                          timer: FocusTimer? = nil,
                          inYearContaining date: Date,
                          completion: @escaping(FocusStatsDataItem) -> Void) {
        let dateRange = date.rangeOfThisYear()
        fetchStats(forTask: task, timer: timer, dateRange: dateRange, completion: completion)
    }
    
    private func fetchStats(forTask task: TaskRepresentable? = nil,
                            timer: FocusTimer? = nil,
                            dateRange: DateRange,
                            completion: @escaping(FocusStatsDataItem) -> Void) {
        fetchSessions(forTask: task, timer: timer, dateRange: dateRange) { sessions in
            let item = FocusStatsDataItem(task: task, timer: timer, dateRange: dateRange, sessions: sessions)
            completion(item)
        }
    }
    
    
}


