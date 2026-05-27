//
//  TodoStatsCompletionTimeDistribution.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/27.
//

import Foundation

/// 任务完成时间段分布
struct TodoStatsCompletionTimeDistribution {
    
    /// 统计周期
    let period: StatisticsPeriod
    /// 按小时分布的任务完成数量（key: 0~23对应0点~23点，value: 完成数量，不包含数量为0的时段）
    let hourlyDistribution: [Int: Int]
    /// 周期内完成总数
    let totalCompleted: Int
    
    /// 完成高峰时段（小时，0~23）
    var peakHour: Int? {
        guard let maxEntry = hourlyDistribution.max(by: { $0.value < $1.value }), maxEntry.value > 0 else {
            return nil
        }
        return maxEntry.key
    }
    /// 高峰时段完成数量
    var peakCount: Int {
        hourlyDistribution.values.max() ?? 0
    }
}

extension TodoStatsCompletionTimeDistribution {

    /// 柱状图表条目
    func barChartItem() -> BarChartItem {
        let barMarks = hourlyCompletionBarMarks()
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.xAxis = .timelineXAxis()
        chartItem.xAxis.guideline?.style = .solid
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks, titleOfValue: nil)
        } else {
            chartItem.yAxis = .emptyYAxis()
        }
        
        return chartItem
    }
   
    private func hourlyCompletionBarMarks() -> [ChartMark] {
        var marks = [ChartMark]()
        for (hour, count) in hourlyDistribution {
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
    
}

extension TodoStatsDataItem {
    
    /// 获取任务完成时间段分布
    func getCompletionTimeDistribution() -> TodoStatsCompletionTimeDistribution {
        guard let tasks = tasks, !tasks.isEmpty else {
            return TodoStatsCompletionTimeDistribution(
                period: period,
                hourlyDistribution: [:],
                totalCompleted: 0
            )
        }
        
        var hourlyDistribution: [Int: Int] = [:]
        for task in tasks {
            guard let completionDate = task.completionDate else {
                continue
            }
            
            let hour = completionDate.hour
            hourlyDistribution[hour, default: 0] += 1
        }
        
        return TodoStatsCompletionTimeDistribution(
            period: period,
            hourlyDistribution: hourlyDistribution,
            totalCompleted: tasks.count
        )
    }
}
