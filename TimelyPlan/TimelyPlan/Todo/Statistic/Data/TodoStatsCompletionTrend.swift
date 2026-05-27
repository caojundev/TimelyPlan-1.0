//
//  TodoStatsCompletionTrend.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/27.
//

import Foundation

/// 单日统计数据单元（周/月维度使用）
struct TodoDailyStats {
    /// 日期
    let date: Date
    /// 当日完成任务数
    let completedCount: Int
    /// 当日创建任务数
    let createdCount: Int
}

/// 单月统计数据单元（年维度使用）
struct TodoMonthlyStats {
    /// 月份（如 2026-05）
    let month: Date
    /// 当月完成任务总数
    let completedCount: Int
    /// 当月创建任务总数
    let createdCount: Int
}

/// 完成趋势统计结果
struct TodoStatsCompletionTrend {
    /// 统计周期
    let period: StatisticsPeriod
    /// 周/月维度：每日统计数据
    let dailyStats: [TodoDailyStats]?
    /// 年维度：每月统计数据
    let monthlyStats: [TodoMonthlyStats]?
    /// 周期内完成总数
    let totalCompleted: Int
    /// 周期内创建总数
    let totalCreated: Int
}

extension TodoStatsCompletionTrend {
    
    /// 柱状图表条目
    func barChartItem() -> BarChartItem {
        let chartItem = BarChartItem()
        switch period {
        case .week(let date, let firstWeekday):
            chartItem.xAxis = .weekDaysAxis(date: date, firstWeekday: firstWeekday)
            chartItem.barMarks = dailyBarChartMarks{ date in
                return CGFloat(date.weekIndex(firstWeekday: firstWeekday))
            }
        case .month(let date):
            chartItem.xAxis = .monthDaysAxis(date: date, startFromZero: true)
            chartItem.barMarks = dailyBarChartMarks{ date in
                return CGFloat(date.day)
            }
        case .year(_):
            chartItem.xAxis = .monthsAxis()
            chartItem.barMarks = monthlyBarChartMarks()
        }
        
        if chartItem.barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: chartItem.barMarks)
        } else {
            chartItem.yAxis = .scoreAxis()
        }
        
        return chartItem
    }
    
    private func dailyBarChartMarks(xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        guard let dailyStats = dailyStats else {
            return []
        }
        
        var marks = [ChartMark]()
        for dailyStat in dailyStats {
            let date = dailyStat.date
            let x = xValueForDate(date)
            var mark = ChartMark(x: x, y: CGFloat(dailyStat.completedCount))
            mark.highlightText = "\(date.monthDayString), \(dailyStat.completedCount)"
            marks.append(mark)
        }
        
        return marks
    }
    
    private func monthlyBarChartMarks() -> [ChartMark] {
        guard let monthlyStats = monthlyStats else {
            return []
        }
        
        var marks = [ChartMark]()
        for monthlyStat in monthlyStats {
            let month = monthlyStat.month.month
            var barMark = ChartMark(x: CGFloat(month), y: CGFloat(monthlyStat.completedCount))
            let symbol = Date.monthSymbol(ofMonth: month)
            barMark.highlightText = "\(symbol) • \(monthlyStat.completedCount)"
            marks.append(barMark)
        }

        return marks
    }
}


/*

// MARK: - 统计数据模型
/// 二、积压与完成率
struct BacklogAndCompletionRate {
    let period: StatisticsPeriod
    let newIncompleteCount: Int          // 周期内新增未完成
    let completionRate: Double           // 0~1
}

/// 四、按时完成率
struct OnTimeCompletionRate {
    let period: StatisticsPeriod
    let onTimeCount: Int
    let totalWithDueDate: Int
    var rate: Double {
        guard totalWithDueDate > 0 else { return 0 }
        return Double(onTimeCount) / Double(totalWithDueDate)
    }
}

/// 五、延期标签分析
struct DelayedTagItem {
    let tagName: String
    let delayedCount: Int
}

struct DelayedTagAnalysis {
    let period: StatisticsPeriod
    let items: [DelayedTagItem]
}

/// 六、工作负载热力图
struct WorkloadHeatmap {
    let period: StatisticsPeriod
    
    // 小时热力（0~23时），索引即小时
    let hourlyCreationHeat: [Int]        // 每个小时创建的任务数
    let hourlyCompletionHeat: [Int]      // 每个小时完成的任务数
    
    // 周热力（1=周日~7=周六），索引0为周日
    let weekdayCompletionHeat: [Int]     // 每周各天完成的任务数
}

/// 七、特定功能使用情况
struct FeatureUsageStats {
    let period: StatisticsPeriod
    
    // 我的一天
    let myDayAddedCount: Int
    let myDayCompletedCount: Int
    var myDayHitRate: Double {
        guard myDayAddedCount > 0 else { return 0 }
        return Double(myDayCompletedCount) / Double(myDayAddedCount)
    }
    
    // 步骤进度
    let totalTasksWithSteps: Int
    let averageStepProgress: Double      // 0~1
}

/// 八、生产力总分
struct ProductivityScore {
    let period: StatisticsPeriod
    let score: Double                    // 0~100
    let onTimeRate: Double
    let completionRate: Double
    let highPriorityRatio: Double
    let myDayHitRate: Double
}

/// 聚合所有统计结果
struct TodoStatisticsReport {
    let period: StatisticsPeriod
    let trend: CreationCompletionTrend
    let backlog: BacklogAndCompletionRate
    let priorityDistribution: PriorityDistribution
    let onTimeCompletion: OnTimeCompletionRate
    let delayedTags: DelayedTagAnalysis
    let heatmap: WorkloadHeatmap
    let featureUsage: FeatureUsageStats
    let productivityScore: ProductivityScore
}


// MARK: - 统计计算引擎

class TodoStatsEngine {
    
    /// 日历实例，处理日期边界
    private let calendar: Calendar = {
        var cal = Calendar.current
        cal.firstWeekday = 1 // 周日为一周第一天，可按需调整
        return cal
    }()
    
    // MARK: - 公开接口
    
    /// 根据周期和任务数组，生成完整统计报告
    func generateReport(for period: StatisticsPeriod, tasks: [TodoTask]) -> TodoStatisticsReport {
        let (startDate, endDate) = dateRange(for: period)
        
        // 过滤周期内的所有相关任务：
        // - 创建时间在周期内
        // - 或完成时间在周期内
        // - 或周期开始时已存在且未完成（用于计算积压）
        let tasksInPeriod = tasks.filter { task in
            if let creation = task.creationDate, creation >= startDate && creation <= endDate {
                return true
            }
            if let completion = task.completionDate, completion >= startDate && completion <= endDate {
                return true
            }
            if let creation = task.creationDate, creation < startDate, !task.isCompleted {
                return true
            }
            if task.isCompleted, let completion = task.completionDate, completion < startDate {
                return false
            }
            return false
        }
        
        let trend = calculateTrend(period: period, tasks: tasksInPeriod, startDate: startDate, endDate: endDate)
        let backlog = calculateBacklog(period: period, tasks: tasksInPeriod, startDate: startDate, endDate: endDate)
        let priority = calculatePriorityDistribution(period: period, tasks: tasksInPeriod, startDate: startDate, endDate: endDate)
        let onTime = calculateOnTimeCompletion(period: period, tasks: tasksInPeriod, startDate: startDate, endDate: endDate)
        let delayedTags = calculateDelayedTags(period: period, tasks: tasksInPeriod, startDate: startDate, endDate: endDate)
        let heatmap = calculateHeatmap(period: period, tasks: tasksInPeriod, startDate: startDate, endDate: endDate)
        let feature = calculateFeatureUsage(period: period, tasks: tasksInPeriod, startDate: startDate, endDate: endDate)
        
        let productivityScore = ProductivitityScore(
            period: period,
            score: calculateProductivityScore(
                onTimeRate: onTime.rate,
                completionRate: backlog.completionRate,
                highPriorityRatio: Double(priority.highCount) / Double(max(priority.total, 1)),
                myDayHitRate: feature.myDayHitRate
            ),
            onTimeRate: onTime.rate,
            completionRate: backlog.completionRate,
            highPriorityRatio: Double(priority.highCount) / Double(max(priority.total, 1)),
            myDayHitRate: feature.myDayHitRate
        )
        
        return TodoStatisticsReport(
            period: period,
            trend: trend,
            backlog: backlog,
            priorityDistribution: priority,
            onTimeCompletion: onTime,
            delayedTags: delayedTags,
            heatmap: heatmap,
            featureUsage: feature,
            productivityScore: productivityScore
        )
    }
    
    // MARK: - 各维度计算
    
    private func calculateTrend(period: StatisticsPeriod, tasks: [TodoTask], startDate: Date, endDate: Date) -> CreationCompletionTrend {
        let created = tasks.filter { task in
            guard let date = task.creationDate else { return false }
            return date >= startDate && date <= endDate
        }.count
        
        let completed = tasks.filter { task in
            guard let date = task.completionDate else { return false }
            return date >= startDate && date <= endDate
        }.count
        
        return CreationCompletionTrend(period: period, createdCount: created, completedCount: completed)
    }
    
    private func calculateBacklog(period: StatisticsPeriod, tasks: [TodoTask], startDate: Date, endDate: Date) -> BacklogAndCompletionRate {
        // 周期开始时已存在的未完成任务
        let preExistingIncomplete = tasks.filter { task in
            guard let creation = task.creationDate else { return false }
            return creation < startDate && !task.isCompleted
        }.count
        
        // 周期内新创建的任务
        let createdInPeriod = tasks.filter { task in
            guard let creation = task.creationDate else { return false }
            return creation >= startDate && creation <= endDate
        }.count
        
        // 周期内新创建但未完成的任务
        let newIncomplete = tasks.filter { task in
            guard let creation = task.creationDate else { return false }
            return creation >= startDate && creation <= endDate && !task.isCompleted
        }.count
        
        // 周期内完成的任务（不限创建时间）
        let completedInPeriod = tasks.filter { task in
            guard let completion = task.completionDate else { return false }
            return completion >= startDate && completion <= endDate
        }.count
        
        let denominator = preExistingIncomplete + createdInPeriod
        let rate: Double = denominator > 0 ? Double(completedInPeriod) / Double(denominator) : 0
        
        return BacklogAndCompletionRate(period: period, newIncompleteCount: newIncomplete, completionRate: rate)
    }
    
    private func calculatePriorityDistribution(period: StatisticsPeriod, tasks: [TodoTask], startDate: Date, endDate: Date) -> PriorityDistribution {
        // 只统计周期内完成的任务
        let completedTasks = tasks.filter { task in
            guard let completion = task.completionDate else { return false }
            return completion >= startDate && completion <= endDate
        }
        
        let high = completedTasks.filter { $0.priority == .high }.count
        let medium = completedTasks.filter { $0.priority == .medium }.count
        let low = completedTasks.filter { $0.priority == .low }.count
        let none = completedTasks.filter { $0.priority == .none }.count
        
        return PriorityDistribution(period: period, highCount: high, mediumCount: medium, lowCount: low, noneCount: none)
    }
    
    private func calculateOnTimeCompletion(period: StatisticsPeriod, tasks: [TodoTask], startDate: Date, endDate: Date) -> OnTimeCompletionRate {
        // 周期内完成且有截止日期的任务
        let completedWithDueDate = tasks.filter { task in
            guard let completion = task.completionDate,
                  let dueDate = task.dueDate,
                  completion >= startDate && completion <= endDate else {
                return false
            }
            return true
        }
        
        let onTime = completedWithDueDate.filter { task in
            guard let completion = task.completionDate, let dueDate = task.dueDate else {
                return false
            }
            return completion <= dueDate
        }.count
        
        return OnTimeCompletionRate(period: period, onTimeCount: onTime, totalWithDueDate: completedWithDueDate.count)
    }
    
    private func calculateDelayedTags(period: StatisticsPeriod, tasks: [TodoTask], startDate: Date, endDate: Date) -> DelayedTagAnalysis {
        // 逾期完成的任务
        let delayedTasks = tasks.filter { task in
            guard let completion = task.completionDate,
                  let dueDate = task.dueDate,
                  completion >= startDate && completion <= endDate else {
                return false
            }
            return completion > dueDate
        }
        
        var tagCountMap: [String: Int] = [:]
        for task in delayedTasks {
            guard let tags = task.tags else { continue }
            for tag in tags {
                tagCountMap[tag.name, default: 0] += 1
            }
        }
        
        let items = tagCountMap.map { DelayedTagItem(tagName: $0.key, delayedCount: $0.value) }
            .sorted { $0.delayedCount > $1.delayedCount }
        
        return DelayedTagAnalysis(period: period, items: items)
    }
    
    private func calculateHeatmap(period: StatisticsPeriod, tasks: [TodoTask], startDate: Date, endDate: Date) -> WorkloadHeatmap {
        var hourlyCreation = Array(repeating: 0, count: 24)
        var hourlyCompletion = Array(repeating: 0, count: 24)
        var weekdayCompletion = Array(repeating: 0, count: 7) // 0=Sunday
        
        // 只统计周期内的数据
        for task in tasks {
            if let creation = task.creationDate, creation >= startDate && creation <= endDate {
                let hour = calendar.component(.hour, from: creation)
                hourlyCreation[hour] += 1
            }
            
            if let completion = task.completionDate, completion >= startDate && completion <= endDate {
                let hour = calendar.component(.hour, from: completion)
                hourlyCompletion[hour] += 1
                
                let weekday = calendar.component(.weekday, from: completion) - 1
                weekdayCompletion[weekday] += 1
            }
        }
        
        return WorkloadHeatmap(
            period: period,
            hourlyCreationHeat: hourlyCreation,
            hourlyCompletionHeat: hourlyCompletion,
            weekdayCompletionHeat: weekdayCompletion
        )
    }
    
    private func calculateFeatureUsage(period: StatisticsPeriod, tasks: [TodoTask], startDate: Date, endDate: Date) -> FeatureUsageStats {
        // 我的一天
        let myDayTasks = tasks.filter { $0.isAddedToMyDay }
        let myDayCompleted = myDayTasks.filter { task in
            guard let completion = task.completionDate else { return false }
            return completion >= startDate && completion <= endDate
        }
        
        // 步骤进度
        let tasksWithSteps = tasks.filter { $0.stepCount > 0 }
        let totalProgress = tasksWithSteps.reduce(0.0) { result, task in
            guard task.stepCount > 0 else { return result }
            return result + Double(task.stepCompletedCount) / Double(task.stepCount)
        }
        let avgProgress: Double = tasksWithSteps.isEmpty ? 0 : totalProgress / Double(tasksWithSteps.count)
        
        return FeatureUsageStats(
            period: period,
            myDayAddedCount: myDayTasks.count,
            myDayCompletedCount: myDayCompleted.count,
            totalTasksWithSteps: tasksWithSteps.count,
            averageStepProgress: avgProgress
        )
    }
    
    private func calculateProductivityScore(onTimeRate: Double, completionRate: Double, highPriorityRatio: Double, myDayHitRate: Double) -> Double {
        // 加权公式：按时完成率40% + 周期完成率30% + 高优占比20% + 我的一天命中率10%
        let score = onTimeRate * 100 * 0.4 +
                    completionRate * 100 * 0.3 +
                    highPriorityRatio * 100 * 0.2 +
                    myDayHitRate * 100 * 0.1
        return min(100, max(0, score))
    }
    
    // MARK: - 日期工具
    
    private func dateRange(for period: StatisticsPeriod) -> (start: Date, end: Date) {
        switch period {
        case .week(let date):
            // 获取该周的第一天（周日）0:00
            var startComponents = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
            startComponents.weekday = 1
            startComponents.hour = 0
            startComponents.minute = 0
            startComponents.second = 0
            let start = calendar.date(from: startComponents) ?? date
            
            // 该周最后一天（周六）23:59:59
            let end = calendar.date(byAdding: DateComponents(day: 6, hour: 23, minute: 59, second: 59), to: start) ?? date
            
            return (start, end)
            
        case .month(let date):
            var startComponents = calendar.dateComponents([.year, .month], from: date)
            startComponents.day = 1
            startComponents.hour = 0
            startComponents.minute = 0
            startComponents.second = 0
            let start = calendar.date(from: startComponents) ?? date
            
            var endComponents = DateComponents()
            endComponents.month = 1
            endComponents.day = -1
            endComponents.hour = 23
            endComponents.minute = 59
            endComponents.second = 59
            let end = calendar.date(byAdding: endComponents, to: start) ?? date
            
            return (start, end)
            
        case .year(let date):
            var startComponents = calendar.dateComponents([.year], from: date)
            startComponents.month = 1
            startComponents.day = 1
            startComponents.hour = 0
            startComponents.minute = 0
            startComponents.second = 0
            let start = calendar.date(from: startComponents) ?? date
            
            var endComponents = DateComponents()
            endComponents.year = 1
            endComponents.day = -1
            endComponents.hour = 23
            endComponents.minute = 59
            endComponents.second = 59
            let end = calendar.date(byAdding: endComponents, to: start) ?? date
            
            return (start, end)
        }
    }
}
*/
