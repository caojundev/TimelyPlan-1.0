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
/// 一次性读取今天零点到明天结束范围内的任务，再按日期分组并按时间排序；
/// 任务点击与完成状态点击沿用待办任务交互器基类。
class WSTodoTaskTwoDaysContentInteractor: WSTodoTaskContentInteractor {

    func selectTodayMore() {
        WSTodoListDetailPresenter.showDetail(for: TodoSmartList.today)
    }
    
    func selectTomorrowMore() {
        WSTodoListDetailPresenter.showDetail(for: TodoSmartList.tomorrow)
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let todayDate = Date()
        let tomorrowDate = todayDate.dateByAddingDays(1) ?? todayDate
        let range = DateInterval.rangeOfDays(firstDate: todayDate, dayCount: 2)

        TodoRepository.fetchCalendarEventTasks(in: range, showCompleted: false) { tasks in
            let groups = Self.groupTasks(tasks ?? [],
                                         todayDate: todayDate,
                                         tomorrowDate: tomorrowDate)

            let today = self.makeDay(title: resGetString("Today"), tasks: groups.today)
            let tomorrow = self.makeDay(title: resGetString("Tomorrow"), tasks: groups.tomorrow)

            /// 没有任务时仍下发空数据，保留头部与两列的基本信息
            completion(WSTodoTaskTwoDaysDataItem(today: today,
                                                 tomorrow: tomorrow))
        }
    }

    /// 按任务时间把范围内的任务分为今天、明天两组
    ///
    /// 优先按开始时间归属，开始时间不在范围内时按截止时间归属；
    /// 两天范围外的任务不展示。
    private static func groupTasks(_ tasks: [TodoTask],
                                   todayDate: Date,
                                   tomorrowDate: Date) -> (today: [TodoTask], tomorrow: [TodoTask]) {
        let todayRange = DateInterval.rangeOfDay(todayDate)
        let tomorrowRange = DateInterval.rangeOfDay(tomorrowDate)
        var todayTasks = [TodoTask]()
        var tomorrowTasks = [TodoTask]()

        for task in tasks {
            if let startDate = task.startDate {
                if todayRange.contains(startDate) {
                    todayTasks.append(task)
                    continue
                }

                if tomorrowRange.contains(startDate) {
                    tomorrowTasks.append(task)
                    continue
                }
            }

            if let dueDate = task.dueDate {
                if todayRange.contains(dueDate) {
                    todayTasks.append(task)
                } else if tomorrowRange.contains(dueDate) {
                    tomorrowTasks.append(task)
                }
            }
        }

        return (sortedTasks(todayTasks), sortedTasks(tomorrowTasks))
    }

    /// 全部任务转换为单天数据，详情展示计划与步骤
    private func makeDay(title: String, tasks: [TodoTask]) -> WSTodoTaskTwoDaysDay {
        let items = tasks.map { WSTodoTaskRowItem(task: $0, option: [.schedule, .step]) }
        return WSTodoTaskTwoDaysDay(title: title, items: items)
    }

    /// 依次按开始日期、截止日期升序排序，两者相同再按优先级从高到低，最后按创建日期倒序兜底；
    /// 没有日期的任务排在末尾
    private static func sortedTasks(_ tasks: [TodoTask]) -> [TodoTask] {
        return tasks.sorted { lhs, rhs in
            let lhsStartDate = lhs.startDate ?? .distantFuture
            let rhsStartDate = rhs.startDate ?? .distantFuture
            if lhsStartDate != rhsStartDate {
                return lhsStartDate < rhsStartDate
            }
            
            let lhsDueDate = lhs.dueDate ?? .distantFuture
            let rhsDueDate = rhs.dueDate ?? .distantFuture
            if lhsDueDate != rhsDueDate {
                return lhsDueDate < rhsDueDate
            }
            
            if lhs.priority != rhs.priority {
                return lhs.priority.rawValue > rhs.priority.rawValue
            }
            
            let lhsCreationDate = lhs.creationDate ?? .distantFuture
            let rhsCreationDate = rhs.creationDate ?? .distantFuture
            return lhsCreationDate > rhsCreationDate
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
        /// 示例详情：展示计划与步骤，与待办任务详情一致
        let detail: ASAttributedString = Date().monthDayString.attributedString(textColor: .secondaryLabel)

        var todayItems: [WSTodoTaskRowItem] = []
        for (index, title) in todayTitles.enumerated() {
            let taskItem = makePreviewTaskItem(identifier: "preview.today.\(index)",
                                               name: title,
                                               detail: detail)
            let item = WSTodoTaskRowItem(taskItem: taskItem,
                                         color: priorities[index % priorities.count].color)
            todayItems.append(item)
        }

        var tomorrowItems: [WSTodoTaskRowItem] = []
        for (index, title) in tomorrowTitles.enumerated() {
            let taskItem = makePreviewTaskItem(identifier: "preview.tomorrow.\(index)",
                                               name: title,
                                               detail: detail)
            let item = WSTodoTaskRowItem(taskItem: taskItem,
                                         color: priorities[index % priorities.count].color)
            tomorrowItems.append(item)
        }

        let today = WSTodoTaskTwoDaysDay(title: resGetString("Today"), items: todayItems)
        let tomorrow = WSTodoTaskTwoDaysDay(title: resGetString("Tomorrow"), items: tomorrowItems)
        return WSTodoTaskTwoDaysDataItem(today: today, tomorrow: tomorrow)
    }

    /// 画廊预览用的任务行数据
    private func makePreviewTaskItem(identifier: String,
                                     name: String,
                                     detail: ASAttributedString?) -> WSTodoTaskItem {
        return WSTodoTaskItem(identifier: identifier,
                              name: name,
                              isCompleted: false,
                              checkType: .normal,
                              progress: 0.0,
                              isProgressSet: false,
                              detail: detail)
    }
}
