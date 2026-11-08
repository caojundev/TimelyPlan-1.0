//
//  WSCalendarUpcomingContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·最近事项的内容交互器。
///
/// 取最近若干天的事项按天分组后下发给内容视图；事项变化与跨天时重新取数。
class WSCalendarUpcomingContentInteractor: WSCalendarEventContentInteractor,
                                          CalendarEventChangeDelegate {

    private enum Metrics {

        /// 列表覆盖的天数
        static let dayCount = 7
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

    // MARK: - 预览数据
    /// 画廊预览数据：固定的两天示例事项，不受用户数据影响
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
                             name: resGetString("Review"),
                             color: Color(0xF6BF25),
                             startDate: today.dateByAddingHours(11),
                             endDate: today.dateByAddingHours(12)),
            makePreviewEvent(identifier: "preview-today-3",
                             name: resGetString("Deep Work"),
                             color: Color(0xC274FF),
                             startDate: today.dateByAddingHours(14),
                             endDate: today.dateByAddingHours(16)),
            makePreviewEvent(identifier: "preview-today-4",
                             name: resGetString("Workout"),
                             color: Color(0x00CF85),
                             startDate: today.dateByAddingHours(18),
                             endDate: today.dateByAddingHours(19)),
            makePreviewEvent(identifier: "preview-tomorrow-1",
                             name: resGetString("Reading"),
                             color: Color(0x30D158),
                             startDate: tomorrow.dateByAddingHours(10),
                             endDate: tomorrow.dateByAddingHours(11)),
            makePreviewEvent(identifier: "preview-tomorrow-2",
                             name: resGetString("Planning"),
                             color: Color(0xF3501D),
                             startDate: tomorrow.dateByAddingHours(13),
                             endDate: tomorrow.dateByAddingHours(14)),
            makePreviewEvent(identifier: "preview-tomorrow-3",
                             name: resGetString("Writing"),
                             color: Color(0xFE887C),
                             startDate: tomorrow.dateByAddingHours(15),
                             endDate: tomorrow.dateByAddingHours(16)),
        ]

        return WSCalendarDayEventsDataItem(events: events, startingAt: today, dayCount: Metrics.dayCount)
    }

    // MARK: - 辅助
    /// 列表取数的时间范围
    private static func makeListRange() -> DateInterval {
        return .rangeOfDays(firstDate: Date(), dayCount: Metrics.dayCount)
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
