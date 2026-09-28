//
//  GoalStatsYearlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

// MARK: - 年统计

/// 目标记录年统计视图控制器
class GoalStatsYearlyViewController: GoalStatsContentViewController {

    init(task: GoalTask, date: Date = .now) {
        super.init(task: task, type: .year, date: date)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        fetchStatsDataItem { [weak self] dataItem in
            guard let self = self else {
                completion([])
                return
            }

            completion(self.sectionControllers(for: dataItem))
        }
    }

    func sectionControllers(for dataItem: GoalStatsDataItem) -> [TPCollectionItemSectionController] {
        /// 打卡分布
        let barMarks = dataItem.monthlyCheckinCountChartMarks()
        let checkinSection = checkinDistributionSectionController(
            title: resGetString("Yearly Check-in"),
            barMarks: barMarks,
            xAxis: .monthsAxis())
        checkinSection.chartItem?.minimumBarMargin = 8.0

        /// 打卡时间段分布
        let checkinTimeSection = checkinTimeDistributionSectionController()

        /// 热力图
        let heatMapSection = heatMapSectionController(for: dataItem)

        return [checkinSection, checkinTimeSection, heatMapSection]
    }

    /// 打卡热力图区块（按天记录数值分级）
    func heatMapSectionController(for dataItem: GoalStatsDataItem) -> TPCollectionItemSectionController {
        let maxValue = max(CGFloat(dataItem.maxDailyRecordAmount), 1.0)
        let sectionController = DayHeatMapSectionController()
        sectionController.cellItem.date = self.date
        let levelsCount = sectionController.levelsCount
        sectionController.levelIndexForDate = { date in
            guard let amount = dataItem.recordAmount(on: date), amount != 0 else {
                return 0
            }

            let levelIndex = ceil(CGFloat(abs(amount)) / maxValue * CGFloat(levelsCount))
            return min(Int(levelIndex), levelsCount)
        }

        return sectionController
    }
}
