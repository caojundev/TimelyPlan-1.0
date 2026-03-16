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
        habit.fetchPeriodTask(for: task, in: period) { periodTask in
            let sectionControllers = self.sectionControllers(for: periodTask)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(for periodTask: HabitPeriodTask) -> [TPCollectionItemSectionController] {
        let summarySectionController = summarySectionController(for: periodTask)
        let calendarMonthSectionController = calendarMonthSectionController(for: periodTask)
        let statusPieSectionController = HabitStatusPieChartSectionController(periodTask: periodTask)
        let monthlyBarChartSectionController = monthlyBarChartSectionController(for: periodTask)
        let checkinTimeSectionController = checkinTimeSectionController(for: periodTask)
        let hourlyCheckinCountSectionContorller = hourlyCheckinCountSectionContorller(for: periodTask)
        let scoreTrendsSectionController = scoreTrendsSectionController(for: periodTask)
        let logSectionController = logSectionController(for: periodTask)
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
    func summarySectionController(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
        let sectionController = StatsSummarySectionController()
        sectionController.summaries = periodTask.summaries()
        return sectionController
    }
    
    /// 月日历
    func calendarMonthSectionController(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
       let sectionController = HabitStatsCalendarMonthSectionController(task: periodTask,
                                                                        date: self.date,
                                                                        firstWeekday: self.firstWeekday)
       return sectionController
    }

    func monthlyBarChartSectionController(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
        let barMarks = periodTask.recordAmountChartMarks(in: self.dateRange) { date in
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
    func checkinTimeSectionController(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
        let chartItem = PointChartItem()
        chartItem.pointMarks = periodTask.checkinTimePointMarksForWeek(in: self.dateRange,
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
    func hourlyCheckinCountSectionContorller(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
        let barMarks = periodTask.hourlyCheckInCountChartMarks()
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
    func scoreTrendsSectionController(for periodTask: HabitPeriodTask) -> StatsCurveChartSectionController {
        let pointMarks = periodTask.scoreChartMarks(in: self.dateRange) { date in
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
    
    func logSectionController(for periodTask: HabitPeriodTask) -> HabitStatsLogSectionController {
        let sectionController = HabitStatsLogSectionController(periodTask: periodTask)
        return sectionController
    }
}
