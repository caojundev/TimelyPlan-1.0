//
//  TodoStatsMonthlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/26.
//

import Foundation
import UIKit

class TodoStatsMonthlyViewController: StatsContentViewController {
    
    init(date: Date = .now) {
        super.init(type: .month, date: date)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
      
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        let period: StatisticsPeriod = .month(date)
        TodoRepository.fetchStatsDataItem(in: period) { dataItem in
            let sectionControllers = self.sectionControllers(for: dataItem)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(for dataItem: TodoStatsDataItem) -> [TPCollectionItemSectionController] {
        let monthCompletionSectionController = monthCompletionSectionController(for: dataItem)
        let prioritySectionController = priorityDistributionSectionController(for: dataItem)
        let completionTimeDistributionSectionController = completionTimeDistributionSectionController(for: dataItem)
        let delayedTagDistributionSectionController = delayedTagDistributionSectionController(for: dataItem)
        let listDistributionSectionController = listDistributionSectionController(for: dataItem)
        return [monthCompletionSectionController,
                prioritySectionController,
                completionTimeDistributionSectionController,
                delayedTagDistributionSectionController,
                listDistributionSectionController]
    }

    /// 月完成
    func monthCompletionSectionController(for dataItem: TodoStatsDataItem) -> TPCollectionItemSectionController {
        let trend = dataItem.getCompletionTrend()
        let chartItem = trend.barChartItem()
        chartItem.xAxis.guideline?.style = .solid
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Monthly Completion Trend")
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
        sectionItem.cellItem.headerTitle = resGetString("Completion Time Distribution")
        sectionItem.chartItem = chartItem
        return sectionItem
    }
    
    /// 拖延标签分布
    func delayedTagDistributionSectionController(for dataItem: TodoStatsDataItem) -> TPCollectionItemSectionController {
        let delayedTagDistribution = dataItem.getDelayedTagDistribution()
        let controller = PieChartSectionController()
        let cellItem = controller.cellItem
        cellItem.headerTitle = resGetString("Delayed Tag Distribution")
        cellItem.visual = delayedTagDistribution.pieVisual()
        let slicesCount = cellItem.visual.slices?.count ?? 0
        if slicesCount == 0 {
            cellItem.innerTitleConfig.font = .boldSystemFont(ofSize: 18.0)
            cellItem.innerTitle = resGetString("No Data")
            cellItem.innerSubtitle = nil
        }
        
        return controller
    }
    
    func listDistributionSectionController(for dataItem: TodoStatsDataItem) -> TPCollectionItemSectionController {
        let listDistribution = dataItem.getListDistribution()
        let controller = BarRankListChartSectionController()
        controller.listItem = listDistribution.barRankListItem()
        let cellItem = controller.cellItem
        cellItem.headerTitle = resGetString("List Distribution")
        return controller
    }
}
