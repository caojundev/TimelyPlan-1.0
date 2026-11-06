//
//  WSTodoTaskNextTrendsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 内容交互器

/// 待办接下来七天组件的内容交互器。
///
/// 一次性读取今天零点起七天内的任务，按天统计任务数目；
/// 任务变化监听、点击任务编辑沿用待办任务交互器基类。
class WSTodoTaskNextTrendsContentInteractor: WSTodoTaskContentInteractor {

    /// 点击组件打开「接下来」智能清单
    override func performPrimaryAction() {
        WSTodoListDetailPresenter.showDetail(for: TodoSmartList.upcoming)
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let startDate = Date()
        let range = DateInterval.rangeOfDays(firstDate: startDate, dayCount: DAYS_PER_WEEK)

        TodoRepository.fetchCalendarEventTasks(in: range, showCompleted: false) { (tasks: [TodoTask]?) in
            completion(Self.makeDataItem(startDate: startDate, tasks: tasks ?? []))
        }
    }

    /// 按天统计任务数目，生成展示数据
    private static func makeDataItem(startDate: Date,
                                     tasks: [TodoTask]) -> WSTodoTaskNextTrendsDataItem {
        let firstDate = startDate.startOfDay()
        var counts = [Int](repeating: 0, count: DAYS_PER_WEEK)

        for task in tasks {
            guard let offset = dayOffset(for: task, firstDate: firstDate) else {
                continue
            }

            counts[offset] += 1
        }

        let days: [WSTodoTaskNextTrendsDay] = counts.enumerated().map {
            (index: Int, count: Int) -> WSTodoTaskNextTrendsDay in
            let date = firstDate.dateByAddingDays(index) ?? firstDate
            return WSTodoTaskNextTrendsDay(date: date, count: count)
        }

        return WSTodoTaskNextTrendsDataItem(startDate: firstDate, days: days)
    }

    /// 优先按开始日期归属，开始日期不在范围内时按截止日期归属
    private static func dayOffset(for task: TodoTask, firstDate: Date) -> Int? {
        for date in [task.startDate, task.dueDate].compactMap({ $0 }) {
            let offset = firstDate.daysBetween(date)
            if offset >= 0 && offset < DAYS_PER_WEEK {
                return offset
            }
        }

        return nil
    }

    // MARK: - 预览数据
    /// 画廊预览数据：固定的七天任务分布，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let startDate = Date().startOfDay()
        let counts = [2, 1, 5, 3, 4, 1, 2]
        let days: [WSTodoTaskNextTrendsDay] = counts.enumerated().map {
            (index: Int, count: Int) -> WSTodoTaskNextTrendsDay in
            let date = startDate.dateByAddingDays(index) ?? startDate
            return WSTodoTaskNextTrendsDay(date: date, count: count)
        }

        return WSTodoTaskNextTrendsDataItem(startDate: startDate, days: days)
    }
}
