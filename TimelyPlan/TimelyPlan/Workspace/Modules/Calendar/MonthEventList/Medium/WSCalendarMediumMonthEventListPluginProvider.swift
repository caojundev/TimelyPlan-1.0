//
//  WSCalendarMediumMonthEventListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 日历·中·月历与事项列表的组件提供者。
class WSCalendarMediumMonthEventListPluginProvider: WSPluginProvider {

    var type: WSPluginType {
        return .Calendar.mediumMonthEventList
    }

    func makeContentView() -> WSPluginContentView {
        return WSCalendarMediumMonthEventListContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCalendarMonthEventListContentInteractor(plugin: plugin, context: context)
    }
}

// MARK: - 内容交互器

/// 日历·中·月历与事项列表的内容交互器。
///
/// 一次取本月事项：一部分汇总成每天的事项指示颜色给左侧月历，
/// 另一部分从今天起按天分组给右侧列表。
class WSCalendarMonthEventListContentInteractor: WSCalendarEventContentInteractor,
                                                 CalendarEventChangeDelegate {

    /// 每天最多保留的指示颜色数量，与指示层的绘制上限一致
    private static let maximumDayColorCount = 3

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
    /// 点击组件主体不处理：左侧月历按点击日期打开列表，右侧列表由行与「更多」各自响应
    override func performPrimaryAction() {

    }

    // MARK: - CalendarEventChangeDelegate
    /// 只有与本展示月份有交集的事项变化才影响展示内容
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let monthRange = DateInterval.rangeOfMonth(containing: Date())
        guard ranges.contains(where: { $0.intersects(monthRange) }) else {
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

        let monthStart = Date().startOfMonth()
        repository.fetchEvents(in: DateInterval.rangeOfMonth(containing: monthStart)) { events in
            completion(Self.makeDataItem(events: events, monthDate: monthStart))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：今天与明天带上示例事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let today = Date().startOfDay()
        let events = [
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
                             name: resGetString("Review"),
                             color: Color(0xF6BF25),
                             date: today,
                             startHour: 15,
                             endHour: 16),
            makePreviewEvent(identifier: "preview-tomorrow-1",
                             name: resGetString("Workout"),
                             color: Color(0x00CF85),
                             date: today.dateByAddingDays(1) ?? today,
                             startHour: 9,
                             endHour: 10),
            makePreviewEvent(identifier: "preview-tomorrow-2",
                             name: resGetString("Reading"),
                             color: Color(0x30D158),
                             date: today.dateByAddingDays(1) ?? today,
                             startHour: 20,
                             endHour: 21),
        ]

        return Self.makeDataItem(events: events, monthDate: today.startOfMonth())
    }

    // MARK: - 辅助
    /// 组装数据：本月每天的事项颜色 + 今天起的事项分组
    private static func makeDataItem(events: [CalendarEvent],
                                     monthDate: Date,
                                     today: Date = Date()) -> WSCalendarMonthEventListDataItem {
        let daysCount = monthDate.numberOfDaysInMonth()
        let monthRange = DateInterval.rangeOfMonth(containing: monthDate)
        let todayStart = today.startOfDay()
        /// 已过去的天不再列出，只汇总今天及之后
        let listStart = max(monthDate, todayStart)
        let listDayCount = max(daysCount - Date.days(fromDate: monthDate, toDate: listStart), 1)

        return WSCalendarMonthEventListDataItem(monthDate: monthDate,
                                                today: today,
                                                dayEventColors: makeDayEventColors(events: events,
                                                                                   monthRange: monthRange,
                                                                                   daysCount: daysCount),
                                                dayEvents: WSCalendarDayEventsDataItem(events: events,
                                                                                       startingAt: listStart,
                                                                                       dayCount: listDayCount))
    }

    /// 按月内每天汇总事项颜色，跨天事项会出现在它覆盖的每一天
    private static func makeDayEventColors(events: [CalendarEvent],
                                           monthRange: DateInterval,
                                           daysCount: Int) -> [Int: [UIColor]] {
        let calendar = Calendar.current
        var dayEventColors: [Int: [UIColor]] = [:]

        for event in events {
            let eventStart = max(event.startDate, monthRange.start)
            let eventEnd = min(event.endDate, monthRange.end)
            guard eventStart <= eventEnd else {
                continue
            }

            let startDay = calendar.component(.day, from: eventStart)
            let endDay = calendar.component(.day, from: eventEnd)
            for day in startDay...endDay where day >= 1 && day <= daysCount {
                var colors = dayEventColors[day] ?? []
                guard colors.count < maximumDayColorCount, !colors.contains(event.color) else {
                    continue
                }

                colors.append(event.color)
                dayEventColors[day] = colors
            }
        }

        return dayEventColors
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
