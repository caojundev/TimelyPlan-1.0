//
//  TodoStatsWeeklyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/26.
//

import Foundation
import UIKit

class TodoStatsWeeklyViewController: StatsContentViewController {
  
    init(date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(type: .week, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        let period: StatisticsPeriod = .week(date, firstWeekday)
        todo.fetchStatsDataItem(in: period) { dataItem in
            let sectionControllers = self.sectionControllers(for: dataItem)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(for dataItem: TodoStatsDataItem) -> [TPCollectionItemSectionController] {
        let weekCompletionSectionController = weekCompletionSectionController(for: dataItem)
        let prioritySectionController = priorityDistributionSectionController(for: dataItem)
        return [weekCompletionSectionController,
                prioritySectionController]
    }

    /// 周完成
    func weekCompletionSectionController(for dataItem: TodoStatsDataItem) -> TPCollectionItemSectionController {
        let trend = dataItem.getCompletionTrend()
        let chartItem = trend.barChartItem()
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Week Completion")
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
}
