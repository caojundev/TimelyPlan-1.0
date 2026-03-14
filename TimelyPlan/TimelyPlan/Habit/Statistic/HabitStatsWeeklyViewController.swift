//
//  HabitStatsWeeklyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitStatsWeeklyViewController: HabitStatsContentViewController {
  
    init(task: HabitTask, date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(task: task, type: .week, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        let period = HabitDatePeriod(date: self.date, mode: .week, firstWeekday: self.firstWeekday)
        habit.fetchPeriodTask(for: task, in: period) { periodTask in
            let sectionControllers = self.sectionControllers(for: periodTask)
            completion(sectionControllers)
        }
    }
    
    func sectionControllers(for periodTask: HabitPeriodTask) -> [TPCollectionItemSectionController] {
        let weeklyBarChartSectionController = weeklyBarChartSectionController(for: periodTask)
        let checkinTimeSectionController = checkinTimeSectionController(for: periodTask)
        return [weeklyBarChartSectionController,
                checkinTimeSectionController]
    }
 
    /// 周柱状图
    func weeklyBarChartSectionController(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
        let barMarks = periodTask.recordAmountChartMarks(in: self.dateRange) { date in
            /// 日期对应的数值为周索引
            return CGFloat(date.weekIndex(firstWeekday: self.firstWeekday))
        }
        
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.xAxis = .weekDaysAxis(date: date, firstWeekday: firstWeekday)
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks)
        } else {
            chartItem.yAxis = .scoreAxis()
        }
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Weekly Check-in")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    /// 日打卡时间
    func checkinTimeSectionController(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
        
        let chartItem = PointChartItem()
        chartItem.pointMarks = periodTask.checkinTimePointMarksForWeek(in: self.dateRange,
                                                                       xValueForDate: { date in
            let weekIndex = date.weekIndex(firstWeekday: self.firstWeekday)
            return CGFloat(weekIndex)
        })
        
        chartItem.xAxis = .weekDaysAxis(date: date, firstWeekday: firstWeekday)
        chartItem.yAxis = .timelineYAxis()

        let sectionItem = StatsDotChartSectionController()
        sectionItem.cellItem.headerTitle = resGetString("Weekly Time of Day")
        sectionItem.chartItem = chartItem
        return sectionItem
    }
}
