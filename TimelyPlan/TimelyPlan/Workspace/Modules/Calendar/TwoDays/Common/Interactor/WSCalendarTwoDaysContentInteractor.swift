//
//  WSCalendarTwoDaysContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 日历今明两天组件的内容交互器。
///
/// 一次性读取今天零点到明天结束范围内的事项，再按天分组成两列；
/// 事项点击、列表打开与添加事项沿用日历事项交互器基类。
class WSCalendarTwoDaysContentInteractor: WSCalendarEventContentInteractor,
                                          CalendarEventChangeDelegate {

    private enum Metrics {

        /// 列表覆盖的天数
        static let dayCount = 2
    }

    /// 日历数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private var repository: CalendarRepository?

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

    // MARK: - 交互
    /// 点击组件主体不处理：左右两列各自打开对应日期的事项列表
    override func performPrimaryAction() {

    }

    // MARK: - CalendarEventChangeDelegate
    /// 只有与今明两天有交集的事项变化才影响展示内容
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
        /// 一次取两天的数据，再按天分组
        repository.fetchEvents(in: DateInterval.rangeOfDays(firstDate: date, dayCount: Metrics.dayCount)) { events in
            completion(WSCalendarTwoDaysDataItem(events: events, startingAt: date))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：今天 4 条、明天 5 条，超出展示条数时展示更多入口
    override func previewDataItem() -> WSPluginDataItem? {
        let today = Date().startOfDay()
        guard let tomorrow = today.dateByAddingDays(1) else {
            return nil
        }

        let todayEvents = [
            makePreviewEvent(identifier: "preview-today-1",
                             name: resGetString("Team Meeting"),
                             color: Color(0x4286F5),
                             date: today,
                             startHour: 9,
                             endHour: 10),
            makePreviewEvent(identifier: "preview-today-2",
                             name: resGetString("Deep Work"),
                             color: Color(0xC274FF),
                             date: today,
                             startHour: 11,
                             endHour: 12),
            makePreviewEvent(identifier: "preview-today-3",
                             name: resGetString("Workout"),
                             color: Color(0x00CF85),
                             date: today,
                             startHour: 14,
                             endHour: 15),
            makePreviewEvent(identifier: "preview-today-4",
                             name: resGetString("Reading"),
                             color: Color(0x30D158),
                             date: today,
                             startHour: 18,
                             endHour: 19),
        ]

        let tomorrowEvents = [
            makePreviewEvent(identifier: "preview-tomorrow-1",
                             name: resGetString("Review"),
                             color: Color(0xF6BF25),
                             date: tomorrow,
                             startHour: 9,
                             endHour: 10),
            makePreviewEvent(identifier: "preview-tomorrow-2",
                             name: resGetString("Planning"),
                             color: Color(0xF3501D),
                             date: tomorrow,
                             startHour: 11,
                             endHour: 12),
            makePreviewEvent(identifier: "preview-tomorrow-3",
                             name: resGetString("Writing"),
                             color: Color(0xFE887C),
                             date: tomorrow,
                             startHour: 13,
                             endHour: 14),
            makePreviewEvent(identifier: "preview-tomorrow-4",
                             name: resGetString("Study"),
                             color: Color(0x7E64FD),
                             date: tomorrow,
                             startHour: 15,
                             endHour: 16),
            makePreviewEvent(identifier: "preview-tomorrow-5",
                             name: resGetString("Meditation"),
                             color: Color(0x01CFD4),
                             date: tomorrow,
                             startHour: 20,
                             endHour: 21),
        ]

        return WSCalendarTwoDaysDataItem(events: todayEvents + tomorrowEvents, startingAt: today)
    }

    // MARK: - 辅助
    /// 列表取数的时间范围
    private static func makeListRange() -> DateInterval {
        return .rangeOfDays(firstDate: Date(), dayCount: Metrics.dayCount)
    }

    private func makePreviewEvent(identifier: String,
                                  name: String,
                                  color: UIColor,
                                  date: Date,
                                  startHour: Int,
                                  endHour: Int) -> CalendarEvent {
        let start = date.dateByAddingHours(startHour) ?? date
        return CalendarEvent(identifier: identifier,
                             source: .system,
                             name: name,
                             color: color,
                             startDate: start,
                             endDate: date.dateByAddingHours(endHour) ?? start,
                             isAllDay: false,
                             isCompleted: false,
                             sourceItem: NSNull())
    }
}
