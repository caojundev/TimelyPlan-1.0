//
//  TodoStatsWorkloadHeatmap.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/27.
//

import Foundation

struct TodoStatsWorkloadHeatmap {
    
    let period: StatisticsPeriod
    
    /// 按天分布的任务完成数量（key: 日期整型数值 ，value: 完成数量，不包含数量为0的天）
    let dailyDistribution: [DayIntegerKey: Int]
}

extension TodoStatsDataItem {
    
    /// 获取任务完成时间段分布
    func getWorkloadHeatmap() -> TodoStatsWorkloadHeatmap {
        guard let tasks = tasks, !tasks.isEmpty else {
            return TodoStatsWorkloadHeatmap(
                period: period,
                dailyDistribution: [:]
            )
        }
        
        var dailyDistribution: [DayIntegerKey: Int] = [:]
        for task in tasks {
            guard let completionDate = task.completionDate else {
                continue
            }
            
            let day = completionDate.dayIntegerKey
            dailyDistribution[day, default: 0] += 1
        }
        
        return TodoStatsWorkloadHeatmap(
            period: period,
            dailyDistribution: dailyDistribution
        )
    }
}
