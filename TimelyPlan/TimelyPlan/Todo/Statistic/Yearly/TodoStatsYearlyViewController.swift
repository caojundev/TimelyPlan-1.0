//
//  TodoStatsYearlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/26.
//

import Foundation
import UIKit

class TodoStatsYearlyViewController: StatsContentViewController {
    
    init(date: Date = .now) {
        super.init(type: .year, date: date)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        let period: StatisticsPeriod = .year(date)
        todo.fetchStatsDataItem(in: period) { dataItem in
            let sectionControllers = self.sectionControllers(for: dataItem)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(for dataItem: TodoStatsDataItem) -> [TPCollectionItemSectionController] {
        let yearCompletionSectionController = yearCompletionSectionController(for: dataItem)
        let prioritySectionController = priorityDistributionSectionController(for: dataItem)
        let completionTimeDistributionSectionController = completionTimeDistributionSectionController(for: dataItem)
        let heatMapSectionController = heatMapSectionController(for: dataItem)
        return [yearCompletionSectionController,
                prioritySectionController,
                completionTimeDistributionSectionController,
                heatMapSectionController]
    }

    /// 年完成
    func yearCompletionSectionController(for dataItem: TodoStatsDataItem) -> TPCollectionItemSectionController {
        let trend = dataItem.getCompletionTrend()
        let chartItem = trend.barChartItem()
        chartItem.minimumBarMargin = 8.0
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Year Completion")
        sectionController.chartItem = chartItem
        return sectionController
    }

    /// 优先级分布
    func priorityDistributionSectionController(for dataItem: TodoStatsDataItem) -> TPCollectionItemSectionController {
        let priorityDistribution = dataItem.getPriorityDistribution()
        let controller = PieChartSectionController()
        let cellItem = controller.cellItem
        cellItem.headerTitle = resGetString("Priority Distribution")
        cellItem.visual = priorityDistribution.pieVisual()
        let slicesCount = cellItem.visual.slices?.count ?? 0
        if slicesCount == 0 {
            cellItem.innerTitleConfig.font = .boldSystemFont(ofSize: 18.0)
            cellItem.innerTitle = resGetString("No Data")
            cellItem.innerSubtitle = nil
        }
        
        return controller
    }
    
    /// 完成时间段分布
    func completionTimeDistributionSectionController(for dataItem: TodoStatsDataItem) -> TPCollectionItemSectionController {
        let completionTimeDistribution = dataItem.getCompletionTimeDistribution()
        let chartItem = completionTimeDistribution.barChartItem()
        chartItem.xAxis.guideline?.style = .solid
        
        let sectionItem = StatsBarChartSectionController()
        sectionItem.cellItem.headerTitle = resGetString("Completion Times Distribution")
        sectionItem.chartItem = chartItem
        return sectionItem
    }
    
    /// 热力图
    func heatMapSectionController(for dataItem: TodoStatsDataItem) -> TPCollectionItemSectionController {
        let heatMap = dataItem.getWorkloadHeatmap()
        
        let sectionController = DayHeatMapSectionController()
        sectionController.cellItem.date = dataItem.period.date
        let levelsCount = sectionController.levelsCount
        sectionController.levelIndexForDate = { date in
            guard let count = heatMap.dailyDistribution[date.dayIntegerKey] else {
                return 0
            }
            
            return min(count, levelsCount)
        }
        
        return sectionController
    }
}
