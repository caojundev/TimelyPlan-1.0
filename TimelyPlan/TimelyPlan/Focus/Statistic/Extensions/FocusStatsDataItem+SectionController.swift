//
//  FocusStatsDataItem+SectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/5/17.
//

import Foundation

extension FocusStatsDataItem {
    
    // MARK: - 概览
    func summarySectionController(type: StatsType) -> TPCollectionItemSectionController {
        let sectionController = StatsSummarySectionController()
        sectionController.summaries = StatsSummary.focusSummaries(type: type, dataItem: self)
        return sectionController
    }
    
    // MARK: - 详情饼状图
    func detailSectionController(groupType: FocusStatsDetailGroupType) -> FocusPieChartSectionController {
        let sectionController = FocusPieChartSectionController(dataItem: self, groupType: groupType)
        return sectionController
    }
    
    /// 获取详情饼状图绘制信息
    func detailPieVisual(groupType: FocusStatsDetailGroupType) -> PieVisual {
        let slices: [PieSlice]
        if groupType == .timer {
            slices = self.timerDurationPieSlices()
        } else {
            slices = self.taskDurationPieSlices()
        }
        
        return PieVisual(slices: slices, colors: nil)
    }
    
    
    // MARK: - 最佳专注时间
    var mostFocusedTimeSectionController: StatsBarChartSectionController {
        let barMarks = self.mostFocusedTimeChartMarks()
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.xAxis = .timelineXAxis()
        chartItem.xAxis.guideline?.style = .solid
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks) { value in
                return Duration(value).title
            }
        } else {
            chartItem.yAxis = .defaultDurationYAxis
        }
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Most Focused Time")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    // MARK: - 历史记录
    var historySessionSectionController: FocusStatsHistorySessionSectionController {
        let sectionController = FocusStatsHistorySessionSectionController()
        sectionController.sessions = self.orderedSessions(ascending: false)
        sectionController.dataItem = self
        return sectionController
    }
    
    var historyDaySectionController: FocusStatsHistoryDaySectionController {
        let sectionController = FocusStatsHistoryDaySectionController()
        sectionController.dayInfos = self.orderedDayInfos(ascending: false)
        sectionController.dataItem = self
        return sectionController
    }
    
    func historyMonthSectionController(date: Date) -> FocusStatsHistoryMonthSectionController {
        let sectionController = FocusStatsHistoryMonthSectionController(date: date)
        sectionController.monthDayInfos = self.monthDayInfos
        sectionController.dataItem = self
        return sectionController
    }
}
