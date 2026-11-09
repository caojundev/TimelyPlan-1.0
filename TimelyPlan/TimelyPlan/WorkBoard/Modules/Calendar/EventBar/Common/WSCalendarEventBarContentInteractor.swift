//
//  WSCalendarEventBarContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历事项条组件的内容交互器。
///
/// 取最近若干天的事项交给内容视图渲染，天数由创建时传入；
/// 事项变化与跨天时重新取数。各天数的组件共用该交互器，只有取数的日期范围不同。
class WSCalendarEventBarContentInteractor: WSCalendarEventContentInteractor,
                                           CalendarEventChangeDelegate {

    /// 显示的天数
    let dayCount: Int

    /// 日历数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private var repository: CalendarRepository?

    init(plugin: WSPlugin, context: WSPluginContext, dayCount: Int) {
        self.dayCount = max(1, dayCount)
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
    /// 只有与显示范围有交集的事项变化才影响展示内容
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let displayRange = Self.makeDisplayRange(dayCount: dayCount)
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

        let date = Date()
        let dayCount = self.dayCount
        repository.fetchEvents(in: Self.makeDisplayRange(dayCount: dayCount)) { events in
            completion(WSCalendarEventBarDataItem(startDate: date,
                                                  dayCount: dayCount,
                                                  events: events))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：每天一条事项、首日再补一条，另有跨两天与跨三天的事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let startDate = Date().startOfDay()
        let names = [resGetString("Team Meeting"), resGetString("Deep Work"), resGetString("Review"),
                     resGetString("Workout"), resGetString("Reading"), resGetString("Planning"),
                     resGetString("Design Sync"), resGetString("Study")]
        let colors: [UIColor] = [Color(0x4286F5), Color(0xC274FF), Color(0xF6BF25), Color(0x00CF85),
                                 Color(0x30D158), Color(0xF3501D), Color(0x7E64FD), Color(0x01CFD4)]

        var events: [CalendarEvent] = []
        for index in 0..<dayCount {
            guard let date = startDate.dateByAddingDays(index) else {
                continue
            }

            events.append(makePreviewEvent(identifier: "preview-\(index)-am",
                                           name: names[index % names.count],
                                           color: colors[index % colors.count],
                                           date: date,
                                           startHour: 9,
                                           endHour: 10))

            /// 首日再加一条，用于对比同一天的多条事项
            if index == 0 {
                events.append(makePreviewEvent(identifier: "preview-\(index)-pm",
                                               name: names[(index + 3) % names.count],
                                               color: colors[(index + 3) % colors.count],
                                               date: date,
                                               startHour: 14,
                                               endHour: 16))
            }
        }

        /// 跨两天的事项，用于展示事项条的连续占位
        if dayCount > 1, let spanEndDate = startDate.dateByAddingDays(1) {
            events.append(makePreviewEvent(identifier: "preview-span-2",
                                           name: resGetString("Conference"),
                                           color: Color(0x7E64FD),
                                           startDate: startDate.dateByAddingHours(11) ?? startDate,
                                           endDate: spanEndDate.dateByAddingHours(12) ?? spanEndDate))
        }

        /// 跨三天的事项，显示天数足够时才添加
        if dayCount > 3,
           let spanStartDate = startDate.dateByAddingDays(1),
           let spanEndDate = startDate.dateByAddingDays(3) {
            events.append(makePreviewEvent(identifier: "preview-span-3",
                                           name: resGetString("Business Trip"),
                                           color: Color(0xF6BF25),
                                           startDate: spanStartDate.dateByAddingHours(13) ?? spanStartDate,
                                           endDate: spanEndDate.dateByAddingHours(18) ?? spanEndDate))
        }

        return WSCalendarEventBarDataItem(startDate: startDate, dayCount: dayCount, events: events)
    }

    // MARK: - 辅助
    /// 从今天零点开始覆盖显示的天数
    private static func makeDisplayRange(dayCount: Int) -> DateInterval {
        return .rangeOfDays(firstDate: Date(), dayCount: dayCount)
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
