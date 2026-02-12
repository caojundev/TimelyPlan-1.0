//
//  FocusStatsWeeklyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/9.
//

import Foundation
import UIKit

class FocusStatsWeeklyViewController: FocusStatsContentViewController {
  
    init(date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(type: .week, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        focus.fetchWeeklyStats(forTask: task, timer: timer, inWeekContaining: date, firstWeekday: firstWeekday) { dataItem in
            let sectionControllers = self.sectionControllers(with: dataItem)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(with dataItem: FocusStatsDataItem) -> [TPCollectionItemSectionController] {
        var sectionControllers = [TPCollectionItemSectionController]()
        
        /// 概览
        let summarySectionController = dataItem.summarySectionController(type: type)
        sectionControllers.append(summarySectionController)
        
        /// 详情
        let detailSectionController = detailSectionController(with: dataItem)
        sectionControllers.append(detailSectionController)
        
        let durationSectionController = durationSectionController(with: dataItem)
        let timelineSectionController = timelineSectionController(with: dataItem)
        let scoreTrendsSectionController = scoreTrendsSectionController(with: dataItem)
        let mostFocusedTimeSectionController = dataItem.mostFocusedTimeSectionController
        let historyDaySectionController = dataItem.historyDaySectionController
        sectionControllers.append(contentsOf: [durationSectionController,
                                         timelineSectionController,
                                         scoreTrendsSectionController,
                                         mostFocusedTimeSectionController,
                                         historyDaySectionController])
        return sectionControllers
    }
 
    // MARK: - 专注时长
    func durationSectionController(with dataItem: FocusStatsDataItem) -> TPCollectionItemSectionController {
        let barMarks = dataItem.durationChartMarks(xValueForDate: { date in
            return CGFloat(date.weekIndex(firstWeekday: firstWeekday))
        })
    
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.xAxis = .weekDaysAxis(date: date, firstWeekday: firstWeekday)
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks) { value in
                return Duration(value).title
            }
        } else {
            chartItem.yAxis = .defaultDurationYAxis
        }

        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Weekly Focus")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    // MARK: - 时间线
    func timelineSectionController(with dataItem: FocusStatsDataItem) -> RectangleChartSectionController {
        let xAxis = ChartAxis.weekDaysAxis(date: date, firstWeekday: firstWeekday)
        let rectangleMarks = dataItem.timelineChartMarks { date in
            let index = CGFloat(date.weekIndex(firstWeekday: firstWeekday))
            let xStart = index - xAxis.stepValue / 2.0
            let xEnd = xStart + xAxis.stepValue
            return (xStart, xEnd)
        }
    
        let chartItem = RectangleChartItem()
        chartItem.xAxis = xAxis
        chartItem.yAxis = .timelineYAxis()
        chartItem.rectangleMarks = rectangleMarks
        
        let sectionController = RectangleChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Focus Timeline")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    // MARK: - 平均得分趋势
    func scoreTrendsSectionController(with dataItem: FocusStatsDataItem) -> StatsCurveChartSectionController {
        let dateRange = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        let pointMarks = dataItem.scoreChartMarks(in: dateRange) { date in
            return CGFloat(date.weekIndex(firstWeekday: firstWeekday))
        }
    
        let chartItem = CurveChartItem()
        chartItem.pointMarks = pointMarks
        chartItem.xAxis = .weekDaysAxis(date: date, firstWeekday: firstWeekday)
        chartItem.yAxis = .scoreAxis()
        
        let sectionController = StatsCurveChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Score Trends")
        sectionController.chartItem = chartItem
        return sectionController
    }
}
