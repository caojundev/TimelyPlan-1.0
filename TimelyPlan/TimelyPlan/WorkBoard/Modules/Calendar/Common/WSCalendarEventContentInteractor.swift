//
//  WSCalendarEventContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历事项类组件的内容交互器基类。
///
/// 统一事项相关交互：点击组件打开今天的事项列表，点击「更多」打开对应日期的列表，
/// 点击事项打开详情；列表内点击添加按钮时，关闭列表后继续快速添加事项。
class WSCalendarEventContentInteractor: WSPluginContentInteractor {

    /// 点击事项时才需要，避免初始化时提前创建
    private lazy var eventProcessor = CalendarEventProcessor()

    /// 事项快速添加管理器。首次添加时按容器视图控制器创建
    private var quickAddManager: TodoTaskQuickAddManager?

    // MARK: - 交互
    /// 点击组件：打开今天的事项列表
    override func performPrimaryAction() {
        openEventList(on: Date())
    }

    /// 点击事项行：打开对应事项的详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let item = dataItem as? WSCalendarEventRowItem,
              let event = item.event else {
            return
        }

        eventProcessor.clickEvent(event)
    }

    // MARK: - 事项列表
    /// 打开指定日期的事项列表。列表内点击添加按钮时，关闭列表后继续添加事项
    func openEventList(on date: Date) {
        let options = CalendarEventListOptions(date: date)
        CalendarPresenter.showEventList(with: options) { [weak self] in
            self?.addEvent(on: date)
        }
    }

    // MARK: - 添加事项
    /// 添加事项：与日历主页的添加按钮一致，按所选日期快速添加一条全天待办
    private func addEvent(on date: Date) {
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
}
