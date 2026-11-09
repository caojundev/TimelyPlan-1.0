//
//  WSCalendarMonthEventBarContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历月事项条组件的内容交互器。
///
/// 取当月网格范围内的事项交给内容视图渲染；
/// 事项变化与跨天时重新取数。
class WSCalendarMonthEventBarContentInteractor: WSCalendarEventContentInteractor,
                                               CalendarEventChangeDelegate {

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
    /// 点击组件主体不处理：内容视图按点击位置打开对应日期的事项列表
    override func performPrimaryAction() {

    }

    // MARK: - CalendarEventChangeDelegate
    /// 只有与当月网格有交集的事项变化才影响展示内容
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let displayRange = Self.makeDisplayRange()
        guard ranges.contains(where: { $0.intersects(displayRange) }) else {
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

        let monthDate = Date().startOfMonth()
        repository.fetchEvents(in: Self.makeDisplayRange(monthDate: monthDate)) { events in
            completion(WSCalendarMonthEventBarDataItem(monthDate: monthDate, events: events))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：每周两条事项，另有一条跨周事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let monthDate = Date().startOfMonth()
        let grid = WSCalendarMonthGrid(monthDate: monthDate)
        let names = [resGetString("Team Meeting"), resGetString("Deep Work"), resGetString("Review"),
                     resGetString("Workout"), resGetString("Reading"), resGetString("Planning"),
                     resGetString("Design Sync"), resGetString("Study")]
        let colors: [UIColor] = [Color(0x4286F5), Color(0xC274FF), Color(0xF6BF25), Color(0x00CF85),
                                 Color(0x30D158), Color(0xF3501D), Color(0x7E64FD), Color(0x01CFD4)]

        var events: [CalendarEvent] = []
        for week in 0..<grid.weekCount {
            /// 只落在当月日期上，首尾行天数较少时取前两个可见日期
            let days = grid.days(inWeek: week)
            for (slot, offset) in [0, 2].enumerated() where offset < days.count {
                let date = days[offset]
                let index = (week * 2 + slot) % names.count
                events.append(makePreviewEvent(identifier: "preview-\(week)-\(slot)",
                                               name: names[index],
                                               color: colors[index],
                                               date: date,
                                               startHour: slot == 0 ? 9 : 14,
                                               endHour: slot == 0 ? 10 : 16))
            }
        }

        /// 跨周事项，用于展示事项条的连续占位
        if let spanStartDate = grid.monthStart.dateByAddingDays(3),
           let spanEndDate = grid.monthStart.dateByAddingDays(DAYS_PER_WEEK + 2) {
            events.append(makePreviewEvent(identifier: "preview-span",
                                           name: resGetString("Conference"),
                                           color: Color(0x7E64FD),
                                           startDate: spanStartDate.dateByAddingHours(13) ?? spanStartDate,
                                           endDate: spanEndDate.dateByAddingHours(17) ?? spanEndDate))
        }

        return WSCalendarMonthEventBarDataItem(monthDate: monthDate, events: events)
    }

    // MARK: - 辅助
    /// 当月网格覆盖的范围
    private static func makeDisplayRange(monthDate: Date = Date()) -> DateInterval {
        let grid = WSCalendarMonthGrid(monthDate: monthDate)
        return .rangeOfDays(firstDate: grid.startDate, dayCount: grid.weekCount * DAYS_PER_WEEK)
    }

    private func makePreviewEvent(identifier: String,
                                  name: String,
                                  color: UIColor,
                                  date: Date,
                                  startHour: Int,
                                  endHour: Int) -> CalendarEvent {
        let startDate = date.dateByAddingHours(startHour) ?? date
        return makePreviewEvent(identifier: identifier,
                                name: name,
                                color: color,
                                startDate: startDate,
                                endDate: date.dateByAddingHours(endHour) ?? startDate)
    }

    private func makePreviewEvent(identifier: String,
                                  name: String,
                                  color: UIColor,
                                  startDate: Date,
                                  endDate: Date) -> CalendarEvent {
        return CalendarEvent(identifier: identifier,
                             source: .system,
                             name: name,
                             color: color,
                             startDate: startDate,
                             endDate: endDate,
                             isAllDay: false,
                             isCompleted: false,
                             sourceItem: NSNull())
    }
}
