//
//  GoalStatsMonthlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

// MARK: - 月统计

/// 目标记录月统计视图控制器
class GoalStatsMonthlyViewController: GoalStatsContentViewController {

    init(task: GoalTask, date: Date = .now) {
        super.init(task: task, type: .month, date: date)
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
        let barMarks = dataItem.dailyCheckinCountChartMarks { date in
            /// 日期对应的数值为当月第几天
            return CGFloat(date.day)
        }
        let checkinSection = checkinDistributionSectionController(
            title: resGetString("Monthly Record"),
            barMarks: barMarks,
            xAxis: .monthDaysAxis(date: self.date))
        checkinSection.chartItem?.xAxis.guideline?.style = .solid

        /// 打卡时间段分布
        let checkinTimeSection = checkinTimeDistributionSectionController()

        /// 打卡时间分布
        let checkinTimeOfDaySection = checkinTimeOfDaySectionController(
            title: resGetString("Monthly Record Time"),
            xAxis: .monthDaysAxis(date: self.date),
            xValueForDate: { date in
                /// 日期对应的数值为当月第几天
                return CGFloat(date.day)
            })
        checkinTimeOfDaySection.chartItem?.xAxis.guideline?.style = .solid

        return [checkinSection, checkinTimeSection, checkinTimeOfDaySection]
    }
}
