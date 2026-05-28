//
//  TodoStatsDelayedTagDistribution.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/28.
//

import Foundation

/// 拖延标签分布
struct TodoStatsDelayedTagDistribution {
    
    let period: StatisticsPeriod
    
    let tagDistribution: [TodoTag: Int]
    
    var total: Int {
        tagDistribution.values.reduce(0, +)
    }
}

extension TodoStatsDelayedTagDistribution {
    
    /// 饼状图信息
    func pieVisual() -> PieVisual {
        let total = total
        guard total > 0 else {
            return PieVisual(slices: [])
        }
        
        let distributions = tagDistribution.sorted { $0.value > $1.value }
        var slices: [PieSlice] = []
        for distribution in distributions {
            let title = distribution.key.name
            let detail = "\(distribution.value)"
            let percent = Double(distribution.value) / Double(total)
            let slice = PieSlice(title: title, detail: detail, percent: percent)
            slices.append(slice)
        }
        
        let colors = distributions.map { $0.key.color }
        return PieVisual(slices: slices, colors: colors)
    }
}

extension TodoStatsDataItem {
    
    func getDelayedTagDistribution() -> TodoStatsDelayedTagDistribution {
        guard let tasks = tasks, !tasks.isEmpty else {
            return TodoStatsDelayedTagDistribution(
                period: period,
                tagDistribution: [:]
            )
        }
        
        var distribution: [TodoTag: Int] = [:]
        for task in tasks {
            guard let tags = task.tags,
                    tags.count > 0,
                    let completionDate = task.completionDate,
                    let dateInfo = task.schedule?.dateInfo,
                    dateInfo.endDate < completionDate else {
                continue
            }
            
            for tag in tags {
                distribution[tag,  default: 0] += 1
            }
        }
        
        return TodoStatsDelayedTagDistribution (
            period: period,
            tagDistribution: distribution
        )
    }
}
