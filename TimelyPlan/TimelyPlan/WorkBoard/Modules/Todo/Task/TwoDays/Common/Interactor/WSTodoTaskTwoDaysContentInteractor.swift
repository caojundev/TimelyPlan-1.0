//
//  WSTodoTaskTwoDaysContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 待办今明两天组件的内容交互器。
///
/// 分别读取今天、明天的任务并按时间排序，任务点击与完成状态点击沿用待办任务交互器基类。
class WSTodoTaskTwoDaysContentInteractor: WSTodoTaskContentInteractor {

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let todayDate = Date()
        let tomorrowDate = todayDate.dateByAddingDays(1) ?? todayDate
        let group = DispatchGroup()
        var todayTasks = [TodoTask]()
        var tomorrowTasks = [TodoTask]()

        /// 两天的查询互不依赖，并行查询后统一回调
        group.enter()
        fetchTasks(on: todayDate) { tasks in
            todayTasks = tasks
            group.leave()
        }

        group.enter()
        fetchTasks(on: tomorrowDate) { tasks in
            tomorrowTasks = tasks
            group.leave()
        }

        group.notify(queue: .main) { [weak self] in
            guard let self = self else {
                return
            }

            let today = self.makeDay(title: resGetString("Today"), tasks: todayTasks)
            let tomorrow = self.makeDay(title: resGetString("Tomorrow"), tasks: tomorrowTasks)

            guard !today.items.isEmpty || !tomorrow.items.isEmpty else {
                completion(nil)
                return
            }

            completion(WSTodoTaskTwoDaysDataItem(today: today,
                                                 tomorrow: tomorrow))
        }
    }

    /// 读取指定日期的任务，只保留开始或截止在该天的任务
    private func fetchTasks(on date: Date, completion: @escaping ([TodoTask]) -> Void) {
        let range = DateInterval.rangeOfDay(date)
        TodoRepository.fetchCalendarEventTasks(in: range, showCompleted: false) { tasks in
            let matchedTasks = (tasks ?? []).filter { task in
                if let startDate = task.startDate, range.contains(startDate) {
                    return true
                }

                if let dueDate = task.dueDate, range.contains(dueDate) {
                    return true
                }

                return false
            }

            completion(Self.sortedTasks(matchedTasks))
        }
    }

    /// 全部任务转换为单天数据
    private func makeDay(title: String, tasks: [TodoTask]) -> WSTodoTaskTwoDaysDay {
        let items = tasks.map { WSTodoTaskTwoDaysItem(task: $0) }
        return WSTodoTaskTwoDaysDay(title: title, items: items)
    }

    /// 按计划时间排序，没有时间的任务排在末尾
    private static func sortedTasks(_ tasks: [TodoTask]) -> [TodoTask] {
        return tasks.sorted { lhs, rhs in
            switch (lhs.startDate, rhs.startDate) {
            case let (lhsDate?, rhsDate?):
                return lhsDate < rhsDate
            case (nil, _?):
                return false
            case (_?, nil):
                return true
            default:
                return false
            }
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：今天 4 条、明天 5 条，超出展示条数时展示更多入口
    override func previewDataItem() -> WSPluginDataItem? {
        let priorities: [TodoTaskPriority] = [.high, .medium, .low, .none]
        let todayTitles = [resGetString("Reading"),
                           resGetString("Workout"),
                           resGetString("Writing"),
                           resGetString("Planning")]
        let tomorrowTitles = [resGetString("Review"),
                              resGetString("Deep Work"),
                              resGetString("Coding"),
                              resGetString("Study"),
                              resGetString("Meditation")]

        var todayItems: [WSTodoTaskTwoDaysItem] = []
        for (index, title) in todayTitles.enumerated() {
            let taskItem = makePreviewTaskItem(identifier: "preview.today.\(index)", name: title)
            let item = WSTodoTaskTwoDaysItem(taskItem: taskItem,
                                             color: priorities[index % priorities.count].color)
            todayItems.append(item)
        }

        var tomorrowItems: [WSTodoTaskTwoDaysItem] = []
        for (index, title) in tomorrowTitles.enumerated() {
            let taskItem = makePreviewTaskItem(identifier: "preview.tomorrow.\(index)", name: title)
            let item = WSTodoTaskTwoDaysItem(taskItem: taskItem,
                                             color: priorities[index % priorities.count].color)
            tomorrowItems.append(item)
        }

        let today = WSTodoTaskTwoDaysDay(title: resGetString("Today"), items: todayItems)
        let tomorrow = WSTodoTaskTwoDaysDay(title: resGetString("Tomorrow"), items: tomorrowItems)
        return WSTodoTaskTwoDaysDataItem(today: today, tomorrow: tomorrow)
    }

    /// 画廊预览用的任务行数据
    private func makePreviewTaskItem(identifier: String, name: String) -> WSTodoTaskItem {
        return WSTodoTaskItem(identifier: identifier,
                              name: name,
                              isCompleted: false,
                              checkType: .normal,
                              progress: 0.0,
                              isProgressSet: false,
                              detail: nil)
    }
}
