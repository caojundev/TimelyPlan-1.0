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
/// 一次性读取后天零点起七天内的任务，按天统计任务数目并保留任务列表；
/// 任务变化监听、点击任务编辑沿用待办任务交互器基类。
class WSTodoTaskNextTrendsContentInteractor: WSTodoTaskContentInteractor {

    /// 打开「接下来」智能清单
    func selectMore() {
        WSTodoListDetailPresenter.showDetail(for: TodoSmartList.upcoming)
    }

    /// 点击组件打开「接下来」智能清单
    override func performPrimaryAction() {
        selectMore()
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        /// 与「接下来」智能清单一致，从后天开始
        let startDate = Date().dateByAddingDays(2) ?? Date()
        let range = DateInterval.rangeOfDays(firstDate: startDate, dayCount: DAYS_PER_WEEK)

        TodoRepository.fetchCalendarEventTasks(in: range, showCompleted: false) { (tasks: [TodoTask]?) in
            completion(Self.makeDataItem(startDate: startDate, tasks: tasks ?? []))
        }
    }

    /// 按天统计任务数目，并生成按天与时间排列的任务列表
    private static func makeDataItem(startDate: Date,
                                     tasks: [TodoTask]) -> WSTodoTaskNextTrendsDataItem {
        let firstDate = startDate.startOfDay()
        var dayTasks = [[TodoTask]](repeating: [], count: DAYS_PER_WEEK)

        for task in tasks {
            guard let offset = dayOffset(for: task, firstDate: firstDate) else {
                continue
            }

            dayTasks[offset].append(task)
        }

        let days = (0..<DAYS_PER_WEEK).map { index -> WSTodoTaskNextTrendsDay in
            let date = firstDate.dateByAddingDays(index) ?? firstDate
            return WSTodoTaskNextTrendsDay(date: date, count: dayTasks[index].count)
        }

        /// 任务列表按天展开，同一天内按时间排序，详情展示计划与步骤
        let items = dayTasks
            .flatMap { sortedTasks($0) }
            .map { WSTodoTaskRowItem(task: $0, option: [.schedule, .step]) }

        return WSTodoTaskNextTrendsDataItem(startDate: firstDate, days: days, items: items)
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

    /// 依次按开始时间、截止时间升序，两者相同再按优先级从高到低
    private static func sortedTasks(_ tasks: [TodoTask]) -> [TodoTask] {
        return tasks.sorted { lhs, rhs in
            let lhsDate = lhs.startDate ?? lhs.dueDate ?? .distantFuture
            let rhsDate = rhs.startDate ?? rhs.dueDate ?? .distantFuture
            if lhsDate != rhsDate {
                return lhsDate < rhsDate
            }

            return lhs.priority.rawValue > rhs.priority.rawValue
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：固定的七天任务分布与任务列表，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let startDate = (Date().dateByAddingDays(2) ?? Date()).startOfDay()
        let counts = [2, 1, 5, 3, 4, 1, 2]
        let days = counts.enumerated().map {
            (index: Int, count: Int) -> WSTodoTaskNextTrendsDay in
            let date = startDate.dateByAddingDays(index) ?? startDate
            return WSTodoTaskNextTrendsDay(date: date, count: count)
        }

        let priorities: [TodoTaskPriority] = [.high, .medium, .low, .none]
        let titles = [resGetString("Reading"),
                      resGetString("Workout"),
                      resGetString("Writing"),
                      resGetString("Review"),
                      resGetString("Deep Work")]
        let items: [WSTodoTaskRowItem] = titles.enumerated().map {
            (index: Int, title: String) -> WSTodoTaskRowItem in
            let taskItem = WSTodoTaskItem(identifier: "preview.trends.\(index)", name: title)
            return WSTodoTaskRowItem(taskItem: taskItem,
                                     color: priorities[index % priorities.count].color)
        }

        return WSTodoTaskNextTrendsDataItem(startDate: startDate, days: days, items: items)
    }
}
