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
        HabitRepository.fetchPeriodItem(for: task, in: period, includeSamples: true) { periodItem in
          let sectionControllers = self.sectionControllers(for: periodItem)
          completion(sectionControllers)
        }
    }

    func sectionControllers(for periodItem: HabitPeriodItem) -> [TPCollectionItemSectionController] {
        let summarySectionController = summarySectionController(for: periodItem)
        let statusPieSectionController = HabitStatusPieChartSectionController(periodItem: periodItem)
        let yearlyBarChartSectionController = yearlyBarChartSectionController(for: periodItem)
        let hourlyCheckinCountSectionContorller = hourlyCheckinCountSectionContorller(for: periodItem)
        let averageScoreSectionController = averageScoreSectionController(for: periodItem)
        let heatMapSectionController = heatMapSectionController(for: periodItem)
        let historySectionController = historySectionController(for: periodItem)
        return [summarySectionController,
                statusPieSectionController,
                yearlyBarChartSectionController,
                hourlyCheckinCountSectionContorller,
                averageScoreSectionController,
                heatMapSectionController,
                historySectionController]
    }
    
    // MARK: - 概览
    func summarySectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let sectionController = StatsSummarySectionController()
        sectionController.summaries = periodItem.summaries()
        return sectionController
    }
    

    func yearlyBarChartSectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let marks = periodItem.monthlyCheckinAmountChartMarks()
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
    
    /// 热力图
    func heatMapSectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let maxValue = CGFloat(periodItem.habitTask.goal.targetAmount)
        let sectionController = DayHeatMapSectionController()
        sectionController.cellItem.date = self.date
        let levelsCount = sectionController.levelsCount
        sectionController.levelIndexForDate = { date in
            guard let record = periodItem.record(on: date) else {
                return 0
            }
            
            let levelIndex = ceil(CGFloat(record.amount) / maxValue * CGFloat(levelsCount))
            return min(Int(levelIndex), levelsCount)
        }
        
        return sectionController
    }
    
    func averageScoreSectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let marks = periodItem.monthlyAverageScoreChartMarks()
        let chartItem = BarChartItem()
        chartItem.minimumBarMargin = 8.0
        chartItem.barMarks = marks
        chartItem.xAxis = .monthsAxis()
        chartItem.yAxis = .scoreAxis()
        
        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Monthly Average Score")
        sectionController.chartItem = chartItem
        return sectionController
    }
    
    func historySectionController(for periodItem: HabitPeriodItem) -> TPCollectionItemSectionController {
        let groupedRecords = periodItem.monthGroupedRecords()
        let sectionController = HabitStatsYearlyHistorySectionController(task: periodItem.habitTask,
                                                                         date: self.date,
                                                                         monthGroupedRecords: groupedRecords)
        return sectionController
    }
    
}
