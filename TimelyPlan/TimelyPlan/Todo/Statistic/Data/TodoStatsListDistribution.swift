//
//  TodoStatsListDistribution.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/28.
//

import Foundation
import UIKit

struct TodoStatsListDistribution {
    
    let period: StatisticsPeriod
    
    let listDistribution: [TodoListFeature: Int]
    
    var maxCount: Int {
        listDistribution.values.max() ?? 0
    }
}

extension TodoStatsListDistribution {
    
    func barRankListItem() -> BarRankListItem {
        guard listDistribution.count > 0 else {
            return BarRankListItem(slices: [])
        }
        
        let distributions = listDistribution.sorted { $0.value > $1.value }
        var slices: [BarRankListSlice] = []
        for (list, count) in distributions {
            let detail = "\(count)"
            let color = list.color ?? .grayPrimary
            let slice = BarRankListSlice(title: list.displayName,
                                         detail: detail,
                                         value: Double(count),
                                         threshold: Double(maxCount),
                                         barColor: color)
            slices.append(slice)
        }
        
        let listItem = BarRankListItem(slices: slices, maxDisplayCount: 6) { othersSlice in
            othersSlice.detail = "\(Int(othersSlice.value))"
        }
        
        return listItem
    }
}

extension TodoStatsDataItem {
    
    func getListDistribution() -> TodoStatsListDistribution {
        guard let tasks = tasks, !tasks.isEmpty else {
            return TodoStatsListDistribution(
                period: period,
                listDistribution: [:]
            )
        }
        
        var distribution: [TodoListFeature: Int] = [:]
        let inboxList = TodoSmartList.inbox.feature
        for task in tasks {
            let list = task.list ?? inboxList
            distribution[list, default: 0] += 1
        }
        
        return TodoStatsListDistribution (
            period: period,
            listDistribution: distribution
        )
    }
}
