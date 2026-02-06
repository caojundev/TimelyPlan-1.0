//
//  FocusStatsMonthlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/9.
//

import Foundation
import UIKit

class FocusStatsMonthlyViewController: FocusStatsContentViewController {
    
    init(date: Date = .now) {
        super.init(type: .month, date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        focus.fetchMonthlyStats(forTask: task, timer: timer, inMonthContaining: date) { dataItem in
            let sectionControllers = self.sectionControllers(with: dataItem)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(with dataItem: FocusStatsDataItem) -> [TPCollectionItemSectionController] {
        var sectionControllers = [TPCollectionItemSectionController]()
        let summarySectionController = dataItem.summarySectionController(type: type)
        sectionControllers.append(summarySectionController)
        
        /// 详情
        let detailSectionController = detailSectionController(with: dataItem)
        sectionControllers.append(detailSectionController)
        
        let durationSectionController = durationSectionController(with: dataItem)
        let scoreTrendsSectionController = scoreTrendsSectionController(with: dataItem)
        let mostFocusedTimeSectionController = dataItem.mostFocusedTimeSectionController
        let historyDaySectionController = dataItem.historyDaySectionController
        sectionControllers.append(contentsOf: [durationSectionController,
                                         scoreTrendsSectionController,
                                         mostFocusedTimeSectionController,
                                         historyDaySectionController])
        return sectionControllers
    }
    
    // MARK: - 专注时长
    func durationSectionController(with dataItem: FocusStatsDataItem) -> TPCollectionItemSectionController {
        let barMarks = dataItem.durationChartMarks(xValueForDate: { date in
            return CGFloat(date.day)
        })
    
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.xAxis = .monthDaysAxis(date: date)
        chartItem.xAxis.guideline?.style = .solid
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks) { value in
                return Duration(value).title
            }
        } else {
            chartItem.yAxis = .defaultDurationYAxis
        }
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Monthly Focus")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    // MARK: - 平均得分趋势
    func scoreTrendsSectionController(with dataItem: FocusStatsDataItem) -> StatsCurveChartSectionController {
        let dateRange = date.rangeOfThisMonth()
        let pointMarks = dataItem.scoreChartMarks(in: dateRange) { date in
            return CGFloat(date.day)
        }
        
        let chartItem = CurveChartItem()
        chartItem.pointMarks = pointMarks
        chartItem.xAxis = .monthDaysAxis(date: date)
        chartItem.yAxis = .scoreAxis()
        
        let sectionController = StatsCurveChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Score Trends")
        sectionController.chartItem = chartItem
        return sectionController
    }
}
