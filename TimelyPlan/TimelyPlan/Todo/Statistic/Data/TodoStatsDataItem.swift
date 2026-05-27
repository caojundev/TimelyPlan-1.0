//
//  TodoStatsDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/27.
//

import Foundation

/// 统计周期
enum StatisticsPeriod {
    case week(Date, Weekday) // 关联任意一天，定位到该周
    case month(Date)   // 关联任意一天，定位到该月
    case year(Date)    // 关联任意一天，定位到该年
    
    func dateRange() -> DateRange {
        switch self {
        case .week(let date, let firstWeekday):
            return date.rangeOfThisWeek(firstWeekday: firstWeekday)
        case .month(let date):
            return date.rangeOfThisMonth()
        case .year(let date):
            return date.rangeOfThisYear()
        }
    }
}

struct TodoStatsDataItem {

    /// 统计周期
    var period: StatisticsPeriod
    
    /// 周期内任务数组
    var tasks: [TodoTask]?
}

// MARK: - 完成趋势统计数据

extension TodoStatsDataItem {
    
    /// 获取完成趋势统计数据
    func getCompletionTrend() -> TodoStatsCompletionTrend {
        guard let tasks = tasks, !tasks.isEmpty else {
            return emptyTrend(period: period)
        }
        
        let dateRange = period.dateRange()
        guard let startDate = dateRange.startDate, let endDate = dateRange.endDate else {
            return emptyTrend(period: period)
        }
        
        let totalCreated = countTasks(tasks, keyPath: \.creationDate, from: startDate, to: endDate)
        let totalCompleted = countTasks(tasks, keyPath: \.completionDate, from: startDate, to: endDate)
        
        switch period {
        case .week(_, _):
            let dailyStats = calculateDailyStats(
                tasks: tasks,
                startDate: startDate,
                endDate: endDate
            )
            return TodoStatsCompletionTrend(
                period: period,
                dailyStats: dailyStats,
                monthlyStats: nil,
                totalCompleted: totalCompleted,
                totalCreated: totalCreated
            )
            
        case .month(_):
            let dailyStats = calculateDailyStats(
                tasks: tasks,
                startDate: startDate,
                endDate: endDate
            )
            return TodoStatsCompletionTrend(
                period: period,
                dailyStats: dailyStats,
                monthlyStats: nil,
                totalCompleted: totalCompleted,
                totalCreated: totalCreated
            )
            
        case .year(let referenceDate):
            let monthlyStats = calculateMonthlyStats(
                tasks: tasks,
                yearDate: referenceDate
            )
            return TodoStatsCompletionTrend(
                period: period,
                dailyStats: nil,
                monthlyStats: monthlyStats,
                totalCompleted: totalCompleted,
                totalCreated: totalCreated
            )
        }
    }
    
    // MARK: - 私有计算方法
    
    /// 计算每日统计数据（周/月维度）
    private func calculateDailyStats(tasks: [TodoTask], startDate: Date, endDate: Date) -> [TodoDailyStats] {
        var stats: [TodoDailyStats] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            let dayStart = currentDate.startOfDay()
            let dayEnd = currentDate.endOfDay()
            
            let createdCount = countTasks(tasks, keyPath: \.creationDate, from: dayStart, to: dayEnd)
            let completedCount = countTasks(tasks, keyPath: \.completionDate, from: dayStart, to: dayEnd)
            
            stats.append(TodoDailyStats(
                date: currentDate,
                completedCount: completedCount,
                createdCount: createdCount
            ))
            
            guard let nextDate = currentDate.dateByAddingDays(1) else {
                break
            }
            currentDate = nextDate
        }
        
        return stats
    }
    
    /// 计算每月统计数据（年维度）
    private func calculateMonthlyStats(tasks: [TodoTask], yearDate: Date) -> [TodoMonthlyStats] {
        var stats: [TodoMonthlyStats] = []
        
        for month in 1...12 {
            guard let monthDate = yearDate.dateByReplacingMonth(month) else {
                continue
            }
            
            let monthStart = monthDate.startOfMonth()
            let monthEnd = monthDate.endOfMonth()
            let createdCount = countTasks(tasks, keyPath: \.creationDate, from: monthStart, to: monthEnd)
            let completedCount = countTasks(tasks, keyPath: \.completionDate, from: monthStart, to: monthEnd)
            
            stats.append(TodoMonthlyStats(
                month: monthStart,
                completedCount: completedCount,
                createdCount: createdCount
            ))
        }
        
        return stats
    }
    
    /// 统计指定日期范围内，某个日期属性的任务数量
    private func countTasks(_ tasks: [TodoTask], keyPath: KeyPath<TodoTask, Date?>, from startDate: Date, to endDate: Date) -> Int {
        tasks.filter { task in
            guard let date = task[keyPath: keyPath] else { return false }
            return date >= startDate && date <= endDate
        }.count
    }
    
    /// 空趋势
    private func emptyTrend(period: StatisticsPeriod) -> TodoStatsCompletionTrend {
        switch period {
        case .week, .month:
            return TodoStatsCompletionTrend(
                period: period,
                dailyStats: [],
                monthlyStats: nil,
                totalCompleted: 0,
                totalCreated: 0
            )
        case .year:
            return TodoStatsCompletionTrend(
                period: period,
                dailyStats: nil,
                monthlyStats: [],
                totalCompleted: 0,
                totalCreated: 0
            )
        }
    }
}

extension TodoStatsDataItem {
    
    /// 获取优先级分布统计数据
    func getPriorityDistribution() -> TodoStatsPriorityDistribution {
        guard let tasks = tasks, !tasks.isEmpty else {
            return TodoStatsPriorityDistribution(
                period: period,
                highCount: 0,
                mediumCount: 0,
                lowCount: 0,
                noneCount: 0
            )
        }
        
        var highCount: Int = 0
        var mediumCount: Int = 0
        var lowCount: Int = 0
        var noneCount: Int = 0
        for task in tasks {
            switch task.priority {
            case .none:
                noneCount += 1
            case .low:
                lowCount += 1
            case .medium:
                mediumCount += 1
            case .high:
                highCount += 1
            }
        }
        return TodoStatsPriorityDistribution(
            period: period,
            highCount: highCount,
            mediumCount: mediumCount,
            lowCount: lowCount,
            noneCount: noneCount
        )
    }
}
