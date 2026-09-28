//
//  GoalStatsMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

// MARK: - 目标记录统计条目

/// 目标记录统计条目
final class GoalStatsPeriodItem {

    /// 目标任务
    let goalTask: GoalTask

    /// 统计日期区间
    let dateRange: DateRange

    /// 日期区间内的打卡记录
    private(set) var records: [GoalRecord] = []

    init(goalTask: GoalTask, dateRange: DateRange, records: [GoalRecord] = []) {
        self.goalTask = goalTask
        self.dateRange = dateRange
        self.update(records: records)
    }

    // MARK: - 更新
    /// 更新统计记录（仅保留日期区间内的记录）
    func update(records: [GoalRecord]?) {
        guard let records = records else {
            self.records = []
            return
        }

        self.records = records.filter { record in
            guard let date = record.date else {
                return false
            }

            return dateRange.contains(date: date)
        }
    }

    /// 是否有记录
    var isEmpty: Bool {
        return records.isEmpty
    }

    // MARK: - 打卡分布（按天 / 按月）
    /// 每天的打卡次数
    private var dailyCheckinCounts: [DayIntegerKey: Int] {
        var counts = [DayIntegerKey: Int]()
        for record in records {
            guard let day = record.day else {
                continue
            }

            counts[day, default: 0] += 1
        }

        return counts
    }

    /// 每月的打卡次数
    private var monthlyCheckinCounts: [Int: Int] {
        var counts = [Int: Int]()
        for record in records {
            guard let date = record.date else {
                continue
            }

            counts[date.month, default: 0] += 1
        }

        return counts
    }

    /// 按天打卡分布图表标记（周、月）
    func dailyCheckinCountChartMarks(xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        guard let startDate = dateRange.startDate else {
            return []
        }

        let daysCount = dateRange.lastsCount()
        guard daysCount > 0 else {
            return []
        }

        let counts = dailyCheckinCounts
        var marks = [ChartMark]()
        for index in 0..<daysCount {
            guard let date = startDate.dateByAddingDays(index),
                  let count = counts[date.dayIntegerKey], count > 0 else {
                continue
            }

            var mark = ChartMark(x: xValueForDate(date), y: CGFloat(count))
            mark.highlightText = "\(date.monthDayString), \(countText(count))"
            marks.append(mark)
        }

        return marks
    }

    /// 按月打卡分布图表标记（年）
    func monthlyCheckinCountChartMarks() -> [ChartMark] {
        var marks = [ChartMark]()
        for (month, count) in monthlyCheckinCounts where count > 0 {
            var mark = ChartMark(x: CGFloat(month), y: CGFloat(count))
            let symbol = Date.monthSymbol(ofMonth: month)
            mark.highlightText = "\(symbol) • \(countText(count))"
            marks.append(mark)
        }

        return marks
    }

    // MARK: - 打卡时间段分布
    /// 按小时的打卡次数
    private var hourlyCheckinCounts: [Int: Int] {
        var counts = [Int: Int]()
        for record in records {
            guard let date = record.date else {
                continue
            }

            counts[date.hour, default: 0] += 1
        }

        return counts
    }

    /// 按小时打卡时间段分布图表标记
    func hourlyCheckinCountChartMarks() -> [ChartMark] {
        var marks = [ChartMark]()
        for (hour, count) in hourlyCheckinCounts where count > 0 {
            var mark = ChartMark(x: CGFloat(hour), y: CGFloat(count))

            /// 时间字符串
            var toHour = hour + 1
            if toHour == HOURS_PER_DAY {
                toHour = 0
            }

            let timeString = String(format: "%02ld:00~%02ld:00", hour, toHour)
            mark.highlightText = "\(timeString) • \(countText(count))"
            marks.append(mark)
        }

        return marks
    }

    // MARK: - 打卡时间分布
    /// 打卡时间点图表标记（y 轴为记录发生在当天的秒数偏移）
    func checkinTimePointChartMarks(xValueForDate: (Date) -> CGFloat) -> [ChartMark] {
        var marks = [ChartMark]()
        for record in records {
            guard let date = record.date else {
                continue
            }

            let offset = date.offset()
            var mark = ChartMark(x: xValueForDate(date), y: CGFloat(offset))
            mark.highlightText = "\(date.monthDayShortWeekdaySymbolString), \(offset.timeString)"
            marks.append(mark)
        }

        return marks
    }

    // MARK: - 热力图
    /// 每天的记录数值合计
    private var dailyRecordAmounts: [DayIntegerKey: Int64] {
        var amounts = [DayIntegerKey: Int64]()
        for record in records {
            guard let day = record.day else {
                continue
            }

            amounts[day, default: 0] += record.amount
        }

        return amounts
    }

    /// 某天记录的数值合计（无记录时为 nil）
    func recordAmount(on date: Date) -> Int64? {
        return dailyRecordAmounts[date.dayIntegerKey]
    }

    /// 单日最大记录数值（取绝对值，用于热力图分级）
    var maxDailyRecordAmount: Int64 {
        return dailyRecordAmounts.values.map { abs($0) }.max() ?? 0
    }

    // MARK: - Helpers
    /// 打卡次数文本
    private func countText(_ count: Int) -> String {
        let unit: String = resGetString(count > 1 ? "times(count)" : "time(count)")
        return "\(count) \(unit)"
    }
}

// MARK: - 统计内容视图控制器

/// 目标记录统计内容视图控制器基类
class GoalStatsContentViewController: StatsContentViewController {

    /// 目标任务
    let task: GoalTask

    /// 当前统计条目
    private(set) var periodItem: GoalStatsPeriodItem?

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
    func fetchPeriodItem(completion: @escaping (GoalStatsPeriodItem) -> Void) {
        let task = self.task
        let dateRange = self.dateRange
        GoalRepository.fetchRecords(for: task,
                                    fromDate: dateRange.startDate,
                                    toDate: dateRange.endDate) { [weak self] records in
            let item = GoalStatsPeriodItem(goalTask: task,
                                           dateRange: dateRange,
                                           records: records ?? [])
            self?.periodItem = item
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
        let barMarks = periodItem?.hourlyCheckinCountChartMarks() ?? []
        let chartItem = BarChartItem()
        chartItem.barMarks = barMarks
        chartItem.barColor = task.color ?? .primary
        chartItem.xAxis = .timelineXAxis()
        chartItem.xAxis.guideline?.style = .solid
        chartItem.yAxis = .yAxisWithGuideline(chartMarks: barMarks, titleOfValue: nil)

        let sectionController = StatsBarChartSectionController()
        sectionController.cellItem.headerTitle = resGetString("Check-in Times Distribution")
        sectionController.chartItem = chartItem
        return sectionController
    }

    /// 打卡时间分布区块（散点图）
    func checkinTimeOfDaySectionController(title: String,
                                           xAxis: ChartAxis,
                                           xValueForDate: (Date) -> CGFloat) -> StatsDotChartSectionController {
        let pointMarks = periodItem?.checkinTimePointChartMarks(xValueForDate: xValueForDate) ?? []
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
        fetchPeriodItem { [weak self] periodItem in
            guard let self = self else {
                completion([])
                return
            }

            completion(self.sectionControllers(for: periodItem))
        }
    }

    func sectionControllers(for periodItem: GoalStatsPeriodItem) -> [TPCollectionItemSectionController] {
        /// 打卡分布
        let barMarks = periodItem.dailyCheckinCountChartMarks { date in
            /// 日期对应的数值为周索引
            return CGFloat(date.weekIndex(firstWeekday: self.firstWeekday))
        }
        let checkinSection = checkinDistributionSectionController(
            title: resGetString("Weekly Check-in"),
            barMarks: barMarks,
            xAxis: .weekDaysAxis(date: self.date, firstWeekday: self.firstWeekday))

        /// 打卡时间段分布
        let checkinTimeSection = checkinTimeDistributionSectionController()

        /// 打卡时间分布
        let checkinTimeOfDaySection = checkinTimeOfDaySectionController(
            title: resGetString("Weekly Time of Day"),
            xAxis: .weekDaysAxis(date: self.date, firstWeekday: self.firstWeekday),
            xValueForDate: { date in
                /// 日期对应的数值为周索引
                return CGFloat(date.weekIndex(firstWeekday: self.firstWeekday))
            })

        return [checkinSection, checkinTimeSection, checkinTimeOfDaySection]
    }
}

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
        fetchPeriodItem { [weak self] periodItem in
            guard let self = self else {
                completion([])
                return
            }

            completion(self.sectionControllers(for: periodItem))
        }
    }

    func sectionControllers(for periodItem: GoalStatsPeriodItem) -> [TPCollectionItemSectionController] {
        /// 打卡分布
        let barMarks = periodItem.dailyCheckinCountChartMarks { date in
            /// 日期对应的数值为当月第几天
            return CGFloat(date.day)
        }
        let checkinSection = checkinDistributionSectionController(
            title: resGetString("Monthly Check-in"),
            barMarks: barMarks,
            xAxis: .monthDaysAxis(date: self.date))
        checkinSection.chartItem?.xAxis.guideline?.style = .solid

        /// 打卡时间段分布
        let checkinTimeSection = checkinTimeDistributionSectionController()

        /// 打卡时间分布
        let checkinTimeOfDaySection = checkinTimeOfDaySectionController(
            title: resGetString("Monthly Time of Day"),
            xAxis: .monthDaysAxis(date: self.date),
            xValueForDate: { date in
                /// 日期对应的数值为当月第几天
                return CGFloat(date.day)
            })
        checkinTimeOfDaySection.chartItem?.xAxis.guideline?.style = .solid

        return [checkinSection, checkinTimeSection, checkinTimeOfDaySection]
    }
}

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
        fetchPeriodItem { [weak self] periodItem in
            guard let self = self else {
                completion([])
                return
            }

            completion(self.sectionControllers(for: periodItem))
        }
    }

    func sectionControllers(for periodItem: GoalStatsPeriodItem) -> [TPCollectionItemSectionController] {
        /// 打卡分布
        let barMarks = periodItem.monthlyCheckinCountChartMarks()
        let checkinSection = checkinDistributionSectionController(
            title: resGetString("Yearly Check-in"),
            barMarks: barMarks,
            xAxis: .monthsAxis())
        checkinSection.chartItem?.minimumBarMargin = 8.0

        /// 打卡时间段分布
        let checkinTimeSection = checkinTimeDistributionSectionController()

        /// 热力图
        let heatMapSection = heatMapSectionController(for: periodItem)

        return [checkinSection, checkinTimeSection, heatMapSection]
    }

    /// 打卡热力图区块（按天记录数值分级）
    func heatMapSectionController(for periodItem: GoalStatsPeriodItem) -> TPCollectionItemSectionController {
        let maxValue = max(CGFloat(periodItem.maxDailyRecordAmount), 1.0)
        let sectionController = DayHeatMapSectionController()
        sectionController.cellItem.date = self.date
        let levelsCount = sectionController.levelsCount
        sectionController.levelIndexForDate = { date in
            guard let amount = periodItem.recordAmount(on: date), amount != 0 else {
                return 0
            }

            let levelIndex = ceil(CGFloat(abs(amount)) / maxValue * CGFloat(levelsCount))
            return min(Int(levelIndex), levelsCount)
        }

        return sectionController
    }
}

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
