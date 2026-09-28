//
//  GoalStatsMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

// MARK: - 统计主视图控制器

/// 目标记录统计主视图控制器（周 / 月 / 年）
class GoalStatsMainViewController: StatsMainViewController,
                                   GoalRecordProcessorDelegate {

    /// 目标任务
    let task: GoalTask

    init(task: GoalTask, type: StatsType = .week, date: Date = .now) {
        self.task = task
        let allowTypes: [StatsType] = [.week, .month, .year]
        super.init(type: type, allowTypes: allowTypes, date: date)
        GoalRepository.addUpdater(self, for: [.record])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let vc = GoalStatsWeeklyViewController(task: task,
                                              date: date,
                                              firstWeekday: .firstWeekday)
        return vc
    }

    override func monthlyStatsViewController() -> UIViewController! {
        let vc = GoalStatsMonthlyViewController(task: task, date: date)
        return vc
    }

    override func yearlyStatsViewController() -> UIViewController! {
        let vc = GoalStatsYearlyViewController(task: task, date: date)
        return vc
    }
    
    private func reloadContentViewController() {
        if let viewController = contentViewController as? GoalStatsContentViewController {
            viewController.reloadData()
        }
    }

    // MARK: - GoalRecordProcessorDelegate
    func didChangeRemoteGoalRecord(with results: EntityChangeResults<GoalRecord>?) {
        reloadContentViewController()
    }

    func didCreateGoalRecord(_ record: GoalRecord, for task: GoalTask) {
        guard task.identifier == self.task.identifier else {
            return
        }

        reloadContentViewController()
    }

    func didUpdateGoalRecord(_ record: GoalRecord, for task: GoalTask, with change: GoalRecordChange) {
        guard task.identifier == self.task.identifier else {
            return
        }

        reloadContentViewController()
    }

    func didDeleteGoalRecords(for task: GoalTask?, in dateRange: DateRange?) {
        if let task = task, task.identifier != self.task.identifier {
            return
        }

        reloadContentViewController()
    }
}
