//
//  HabitStatsMonthlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitStatsMonthlyViewController: HabitStatsContentViewController {
  
    init(task: HabitTask, date: Date = .now) {
        super.init(task: task, type: .month, date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        let period = HabitDatePeriod(date: self.date, mode: .month)
        HabitRepository.fetchPeriodItem(for: task, in: period, includeSamples: true) { periodItem in
            let sectionControllers = self.sectionControllers(for: periodItem)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(for periodItem: HabitPeriodItem) -> [TPCollectionItemSectionController] {
        let summarySectionController = summarySectionController(for: periodItem)
        let calendarMonthSectionController = calendarMonthSectionController(for: periodItem)
        let statusPieSectionController = HabitStatusPieChartSectionController(periodItem: periodItem)
        let monthlyBarChartSectionController = monthlyBarChartSectionController(for: periodItem)
        let checkinTimeSectionController = checkinTimeSectionController(for: periodItem)
        let hourlyCheckinCountSectionContorller = hourlyCheckinCountSectionContorller(for: periodItem)
        let scoreTrendsSectionController = scoreTrendsSectionController(for: periodItem)
        let logSectionController = logSectionController(for: periodItem)
        return [summarySectionController,
                calendarMonthSectionController,
                statusPieSectionController,
                monthlyBarChartSectionController,
                checkinTimeSectionController,
                hourlyCheckinCountSectionContorller,
                scoreTrendsSectionController,
                logSectionController]
    }
 
    // MARK: - 概览
    func summarySectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let sectionController = StatsSummarySectionController()
        sectionController.summaries = periodItem.summaries()
        return sectionController
    }
    
    /// 月日历
    func calendarMonthSectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
       let sectionController = HabitStatsCalendarMonthSectionController(periodItem: periodItem,
                                                                        date: self.date,
                                                                        firstWeekday: self.firstWeekday)
       return sectionController
    }

    func monthlyBarChartSectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let barMarks = periodItem.recordAmountChartMarks(in: self.dateRange) { date in
            return CGFloat(date.day)
        }
        
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.xAxis = .monthDaysAxis(date: date)
        chartItem.xAxis.guideline?.style = .solid
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks)
        } else {
            chartItem.yAxis = .scoreAxis()
        }
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Monthly Check-in")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    /// 日打卡时间
    func checkinTimeSectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let chartItem = PointChartItem()
        chartItem.pointMarks = periodItem.checkinTimePointMarksForWeek(in: self.dateRange,
                                                                       xValueForDate: { date in
            return CGFloat(date.day)
        })
        
        chartItem.xAxis.guideline?.style = .solid
        chartItem.xAxis = .monthDaysAxis(date: date)
        chartItem.yAxis = .timelineYAxis()

        let sectionItem = StatsDotChartSectionController()
        sectionItem.cellItem.headerTitle = resGetString("Monthly Time of Day")
        sectionItem.chartItem = chartItem
        return sectionItem
    }
    
    /// 按小时打卡次数
    func hourlyCheckinCountSectionContorller(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let barMarks = periodItem.hourlyCheckInCountChartMarks()
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.xAxis = .timelineXAxis()
        chartItem.xAxis.guideline?.style = .solid
        chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks, titleOfValue: nil)

        let sectionItem = StatsBarChartSectionController()
        sectionItem.cellItem.headerTitle = resGetString("Check-in Times Distribution")
        sectionItem.chartItem = chartItem
        return sectionItem
    }
    
    // MARK: - 得分趋势
    func scoreTrendsSectionController(for periodItem: HabitPeriodItem) -> StatsBarChartSectionController {
        let barMarks = periodItem.scoreChartMarks(in: self.dateRange) { date in
            return CGFloat(date.day)
        }
    
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.xAxis = .monthDaysAxis(date: date)
        chartItem.yAxis = .scoreAxis()
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Score Trends")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    func logSectionController(for periodItem: HabitPeriodItem) -> HabitStatsLogSectionController {
        let sectionController = HabitStatsLogSectionController(periodItem: periodItem)
        return sectionController
    }
}
