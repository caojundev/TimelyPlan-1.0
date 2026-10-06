//
//  GoalStatsContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

// MARK: - 统计内容视图控制器

/// 目标记录统计内容视图控制器基类
class GoalStatsContentViewController: StatsContentViewController {

    /// 目标任务
    let task: GoalTask

    /// 当前统计条目
    private(set) var dataItem: GoalStatsDataItem?

    init(task: GoalTask,
         type: StatsType,
         date: Date = .now,
         firstWeekday: Weekday = .firstWeekday) {
        self.task = task
        super.init(type: type, date: date, firstWeekday: firstWeekday)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.backViewMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 10.0, right: 16.0)
    }

    // MARK: - 获取记录
    /// 获取当前日期区间内的打卡记录并构建统计条目
    func fetchStatsDataItem(completion: @escaping (GoalStatsDataItem) -> Void) {
        let task = self.task
        let dateRange = self.dateRange
        GoalRepository.fetchRecords(for: task,
                                    fromDate: dateRange.startDate,
                                    toDate: dateRange.endDate) { [weak self] records in
            let item = GoalStatsDataItem(goalTask: task,
                                           dateRange: dateRange,
                                           records: records ?? [])
            self?.dataItem = item
            completion(item)
        }
    }

    // MARK: - 图表区块
    /// 打卡分布区块（柱状图）
    func checkinDistributionSectionController(title: String,
                                              barMarks: [ChartMark],
                                              xAxis: ChartAxis) -> StatsBarChartSectionController {
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.barColor = task.color ?? .primary
        chartItem.xAxis = xAxis
        if barMarks.count > 0 {
            chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks)
        } else {
            chartItem.yAxis = .emptyYAxis()
        }

        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = title
        sectionController.chartItem = chartItem
        return sectionController
    }

    /// 打卡时间段分布区块（柱状图）
    func checkinTimeDistributionSectionController() -> StatsBarChartSectionController {
        let barMarks = dataItem?.hourlyCheckinCountChartMarks() ?? []
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.barColor = task.color ?? .primary
        chartItem.xAxis = .timelineXAxis()
        chartItem.xAxis.guideline?.style = .solid
        chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks, titleOfValue: nil)

        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Record Times Distribution")
        sectionController.chartItem = chartItem
        return sectionController
    }

    /// 打卡时间分布区块（散点图）
    func checkinTimeOfDaySectionController(title: String,
                                           xAxis: ChartAxis,
                                           xValueForDate: (Date) -> CGFloat) -> StatsDotChartSectionController {
        let pointMarks = dataItem?.checkinTimePointChartMarks(xValueForDate: xValueForDate) ?? []
        let chartItem = PointChartItem()
        chartItem.pointMarks = pointMarks
        chartItem.pointColor = task.color ?? .primary
        chartItem.xAxis = xAxis
        chartItem.yAxis = .timelineYAxis()

        let sectionController = StatsDotChartSectionController()
        sectionController.cellItem.headerTitle = title
        sectionController.chartItem = chartItem
        return sectionController
    }
}
