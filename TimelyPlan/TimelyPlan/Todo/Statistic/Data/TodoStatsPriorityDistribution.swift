//
//  TodoStatsPriorityDistribution.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/27.
//

import Foundation

/// 优先级分布
struct TodoStatsPriorityDistribution {
    let period: StatisticsPeriod
    let highCount: Int
    let mediumCount: Int
    let lowCount: Int
    let noneCount: Int
    
    var total: Int { highCount + mediumCount + lowCount + noneCount }
}

extension TodoStatsPriorityDistribution {
    
    /// 饼状图信息
    func pieVisual() -> PieVisual {
        let total = total
        guard total > 0 else {
            return PieVisual(slices: [])
        }
        
        var infos: [(priority: TodoTaskPriority, count: Int)] = []
        for priority in TodoTaskPriority.allCases {
            var count: Int = 0
            switch priority {
            case .none:
                count = noneCount
            case .low:
                count = lowCount
            case .medium:
                count = mediumCount
            case .high:
                count = highCount
            }
            
            if count > 0 {
                infos.append((priority, count))
            }
        }
        
        infos = infos.sorted { $0.count > $1.count }
        var slices: [PieSlice] = []
        for info in infos {
            let title = info.priority.title
            let detail = "\(info.count)"
            let percent = Double(info.count) / Double(total)
            let slice = PieSlice(title: title, detail: detail, percent: percent)
            slices.append(slice)
        }
        
        let colors = infos.map { $0.priority.color }
        return PieVisual(slices: slices, colors: colors)
    }
}
