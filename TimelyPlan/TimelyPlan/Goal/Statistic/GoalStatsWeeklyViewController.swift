//
//  GoalStatsWeeklyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

// MARK: - 周统计

/// 目标记录周统计视图控制器
class GoalStatsWeeklyViewController: GoalStatsContentViewController {

    init(task: GoalTask, date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(task: task, type: .week, date: date, firstWeekday: firstWeekday)
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
            /// 日期对应的数值为周索引
            return CGFloat(date.weekIndex(firstWeekday: self.firstWeekday))
        }
        let checkinSection = checkinDistributionSectionController(
            title: resGetString("Weekly Record"),
            barMarks: barMarks,
            xAxis: .weekDaysAxis(date: self.date, firstWeekday: self.firstWeekday))

        /// 打卡时间段分布
        let checkinTimeSection = checkinTimeDistributionSectionController()

        /// 打卡时间分布
        let checkinTimeOfDaySection = checkinTimeOfDaySectionController(
            title: resGetString("Weekly Record Time"),
            xAxis: .weekDaysAxis(date: self.date, firstWeekday: self.firstWeekday),
            xValueForDate: { date in
                /// 日期对应的数值为周索引
                return CGFloat(date.weekIndex(firstWeekday: self.firstWeekday))
            })

        return [checkinSection, checkinTimeSection, checkinTimeOfDaySection]
    }
}
