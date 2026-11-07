//
//  WSCalendarUpcomingContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·最近事项的内容交互器。
///
/// 取最近若干天的事项按天分组后下发给内容视图；事项变化与跨天时重新取数。
class WSCalendarUpcomingContentInteractor: WSPluginContentInteractor, CalendarEventChangeDelegate {

    private enum Metrics {

        /// 列表覆盖的天数
        static let dayCount = 7
    }

    /// 日历数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private var repository: CalendarRepository?

    /// 点击事项时才需要，避免初始化时提前创建
    private lazy var eventProcessor = CalendarEventProcessor()

    /// 事项快速添加管理器。首次添加时按容器视图控制器创建
    private var quickAddManager: TodoTaskQuickAddManager?

    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)

        guard context == .dashboard else {
            return
        }

        let repository = CalendarRepository()
        self.repository = repository
        /// 观察者由数据仓库弱引用持有，无需手动移除
        repository.addUpdaterDelegate(self)
    }

    // MARK: - CalendarEventChangeDelegate
    /// 只有与列表时间范围有交集的事项变化才影响展示内容
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let listRange = Self.makeListRange()
        guard ranges.contains(where: { $0.intersects(listRange) }) else {
            return
        }

        pluginDataDidChange()
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let repository = repository else {
            completion(nil)
            return
        }

        let date = Date()
        repository.fetchEvents(in: DateInterval.rangeOfDays(firstDate: date, dayCount: Metrics.dayCount)) { events in
            completion(WSCalendarDayEventsDataItem(events: events,
                                                   startingAt: date,
                                                   dayCount: Metrics.dayCount))
        }
    }

    // MARK: - 交互
    /// 点击组件：打开今天的事项列表
    override func performPrimaryAction() {
        showEventList(on: Date())
    }

    /// 点击事项行：打开对应事项的详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let item = dataItem as? WSCalendarEventRowItem,
              let event = item.event else {
            return
        }

        eventProcessor.clickEvent(event)
    }

    /// 点击「更多」：打开被折叠那天的完整事项列表
    func clickMoreEvents(on date: Date) {
        showEventList(on: date)
    }

    // MARK: - 预览数据
    /// 画廊预览数据：固定的三天事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let today = Date().startOfDay()
        guard let tomorrow = today.dateByAddingDays(1) else {
            return nil
        }

        let events = [
            makePreviewEvent(identifier: "preview-today-1",
                             name: resGetString("Team Meeting"),
                             color: Color(0x4286F5),
                             startDate: today.dateByAddingHours(9),
                             endDate: today.dateByAddingHours(10)),
            makePreviewEvent(identifier: "preview-today-2",
                             name: resGetString("Deep Work"),
                             color: Color(0xC274FF),
                             startDate: today.dateByAddingHours(14),
                             endDate: today.dateByAddingHours(16)),
            makePreviewEvent(identifier: "preview-tomorrow",
                             name: resGetString("Reading"),
                             color: Color(0x30D158),
                             startDate: tomorrow.dateByAddingHours(10),
                             endDate: tomorrow.dateByAddingHours(11)),
        ]

        return WSCalendarDayEventsDataItem(events: events, startingAt: today, dayCount: Metrics.dayCount)
    }

    // MARK: - 辅助
    /// 列表取数的时间范围
    private static func makeListRange() -> DateInterval {
        return .rangeOfDays(firstDate: Date(), dayCount: Metrics.dayCount)
    }

    /// 打开指定日期的事项列表。列表内点击添加按钮时，关闭列表后继续添加事项
    private func showEventList(on date: Date) {
        let options = CalendarEventListOptions(date: date)
        CalendarPresenter.showEventList(with: options) { [weak self] in
            self?.addTask(on: date)
        }
    }

    // MARK: - 添加事项
    /// 添加事项：与日历主页的添加按钮一致，按所选日期快速添加一条全天待办
    private func addTask(on date: Date) {
        guard let viewController = UIViewController.topPresented else {
            return
        }
        
        /// 容器视图控制器变化后管理器需要重建
        if quickAddManager?.containerViewController == nil {
            let options = TodoQuickAddOptions(showMoreSetting: false,
                                              forbidContinuousAdd: true)
            quickAddManager = TodoTaskQuickAddManager(containerViewController: viewController,
                                                      options: options)
        }

        quickAddManager?.show(with: Self.makeQuickAddTask(on: date))
    }

    /// 添加内容与日历主页一致：所选日期为全天，提醒取日历设置中的全天提醒
    private static func makeQuickAddTask(on date: Date) -> TodoQuickAddTask {
        let schedule = TaskSchedule(dateInfo: TaskDateInfo(date: date),
                                    reminder: CalendarSetting.shared.allDayEventReminder,
                                    repeatRule: nil)
        let task = TodoQuickAddTask()
        task.schedule = schedule
        return task
    }

    private func makePreviewEvent(identifier: String,
                                  name: String,
                                  color: UIColor,
                                  startDate: Date?,
                                  endDate: Date?) -> CalendarEvent {
        let start = startDate ?? Date()
        return CalendarEvent(identifier: identifier,
                             source: .system,
                             name: name,
                             color: color,
                             startDate: start,
                             endDate: endDate ?? start,
                             isAllDay: false,
                             isCompleted: false,
                             sourceItem: NSNull())
    }
}
