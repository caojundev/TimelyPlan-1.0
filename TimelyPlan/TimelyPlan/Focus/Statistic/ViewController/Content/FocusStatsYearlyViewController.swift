//
//  FocusStatsYearlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/9.
//

import Foundation
import UIKit

class FocusStatsYearlyViewController: FocusStatsContentViewController {

    init(date: Date = .now) {
        super.init(type: .year, date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        focus.fetchYearlyStats(forTask: task, timer: timer, inYearContaining: date) { dataItem in
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
        let heatMapSectionController = heatMapSectionController(with: dataItem)
        let historyMonthSectionController = dataItem.historyMonthSectionController(date: date)
        sectionControllers.append(contentsOf: [durationSectionController,
                                         scoreTrendsSectionController,
                                         mostFocusedTimeSectionController,
                                         heatMapSectionController,
                                         historyMonthSectionController])
        return sectionControllers
    }
    
    // MARK: - 专注时长
    func durationSectionController(with dataItem: FocusStatsDataItem) -> TPCollectionItemSectionController {
        let barMarks = dataItem.monthDurationChartMarks()
        let chartItem = BarChartItem()
        chartItem.minimumBarMargin = 8.0
        chartItem.barMarks = barMarks
        chartItem.xAxis = .monthsAxis()
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks) { value in
                return Duration(value).title
            }
        } else {
            chartItem.yAxis = .defaultDurationYAxis
        }
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Yearly Focus")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    // MARK: - 平均得分趋势
    func scoreTrendsSectionController(with dataItem: FocusStatsDataItem) -> StatsCurveChartSectionController {
        let pointMarks = dataItem.monthAverageScoreChartMarks()
        let chartItem = CurveChartItem()
        chartItem.pointMarks = pointMarks
        chartItem.xAxis = .monthsAxis()
        chartItem.yAxis = .scoreAxis()
        
        let sectionController = StatsCurveChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Score Trends")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    /// 年度热力图
    func heatMapSectionController(with dataItem: FocusStatsDataItem) -> TPCollectionItemSectionController {
        let sectionController = DayHeatMapSectionController()
        sectionController.cellItem.mapInfo = heatMapInfo()
        sectionController.cellItem.date = self.date
        
        let dayInfos = dataItem.dayInfos
        sectionController.levelIndexForDate = { [weak self] date in
            let duration = dayInfos?[date.dayStringKey]?.duration ?? 0
            let index = self?.levelIndex(of: duration) ?? 0
            return index
        }

        return sectionController
    }
    
    private func levelIndex(of duration: Duration) -> Int {
        if duration > 3 * SECONDS_PER_HOUR {
            return 4
        } else if duration > 2 * SECONDS_PER_HOUR {
            return 3
        } else if duration > SECONDS_PER_HOUR {
            return 2
        } else if duration > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    private func heatMapInfo() -> HeatMapInfo {
        let infos: [(color: UIColor, string: String?)] = [
        (kHeatMapNoneColor, "0m"),
        (kHeatMapLevelColor.withAlphaComponent(0.1), "0~1h"),
        (kHeatMapLevelColor.withAlphaComponent(0.4), "1~2h"),
        (kHeatMapLevelColor.withAlphaComponent(0.7), "2~3h"),
        (kHeatMapLevelColor, ">3h")
        ]
        
        var levels = [HeatMapLevel]()
        for info in infos {
            let level = HeatMapLevel(color: info.color, info: info.string)
            levels.append(level)
        }
        
        let mapInfo = HeatMapInfo(levels: levels)
        return mapInfo
    }
}
