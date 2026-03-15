//
//  HabitStatsYearlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitStatsYearlyViewController: HabitStatsContentViewController {
  
      init(task: HabitTask, date: Date = .now) {
          super.init(task: task, type: .year, date: date)
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      
      override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
          let period = HabitDatePeriod(date: self.date, mode: .year)
          habit.fetchPeriodTask(for: task, in: period) { periodTask in
              let sectionControllers = self.sectionControllers(for: periodTask)
              completion(sectionControllers)
          }
      }
      
      func sectionControllers(for periodTask: HabitPeriodTask) -> [TPCollectionItemSectionController] {
          let statusPieSectionController = statusPieSectionController(for: periodTask)
          let yearlyBarChartSectionController = yearlyBarChartSectionController(for: periodTask)
          let hourlyCheckinCountSectionContorller = hourlyCheckinCountSectionContorller(for: periodTask)
          let heatMapSectionController = heatMapSectionController(for: periodTask)
          return [statusPieSectionController,
                  yearlyBarChartSectionController,
                  hourlyCheckinCountSectionContorller,
                  heatMapSectionController]
      }
    
    func statusPieSectionController(for periodTask: HabitPeriodTask) -> PieChartSectionController {
        let sectionController = PieChartSectionController()
        sectionController.visual = periodTask.statusDayCountPieVisual()
        return sectionController
    }

    func yearlyBarChartSectionController(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
        let marks = periodTask.monthlyCheckinAmountChartMarks()
        let chartItem = BarChartItem()
        chartItem.minimumBarMargin = 8.0
        chartItem.barMarks = marks
        chartItem.xAxis = .monthsAxis()
        if marks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: marks)
        } else {
            chartItem.yAxis = .scoreAxis()
        }

        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Yearly Check-in")
        sectionController.chartItem = chartItem
        return sectionController
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
    
    /// 热力图
    func heatMapSectionController(for periodTask: HabitPeriodTask) -> TPCollectionItemSectionController {
        let maxValue = CGFloat(periodTask.habitTask.goal.targetAmount)
        let sectionController = DayHeatMapSectionController()
        sectionController.cellItem.date = self.date
        let levelsCount = sectionController.levelsCount
        sectionController.levelIndexForDate = { date in
            guard let record = periodTask.record(on: date) else {
                return 0
            }
            
            let levelIndex = ceil(CGFloat(record.amount) / maxValue * CGFloat(levelsCount))
            return min(Int(levelIndex), levelsCount)
        }
        
        return sectionController
    }
}
