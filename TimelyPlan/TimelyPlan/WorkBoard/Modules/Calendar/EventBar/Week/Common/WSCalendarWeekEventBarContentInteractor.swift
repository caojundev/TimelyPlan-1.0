//
//  WSCalendarWeekEventBarContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历周事项条组件的内容交互器。
///
/// 取本周开始若干周的事项交给内容视图渲染，周数由创建时传入；
/// 事项变化与跨天时重新取数。
class WSCalendarWeekEventBarContentInteractor: WSCalendarEventContentInteractor,
                                               CalendarEventChangeDelegate {

    /// 显示周数
    let weekCount: Int

    /// 日历数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private var repository: CalendarRepository?

    init(plugin: WSPlugin, context: WSPluginContext, weekCount: Int) {
        self.weekCount = max(1, weekCount)
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
    /// 只有与显示范围有交集的事项变化才影响展示内容
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let displayRange = Self.makeDisplayRange(weekCount: weekCount)
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

        let startDate = Self.weekStartDate()
        let weekCount = self.weekCount
        repository.fetchEvents(in: .rangeOfDays(firstDate: startDate,
                                                dayCount: weekCount * DAYS_PER_WEEK)) { events in
            completion(WSCalendarWeekEventBarDataItem(startDate: startDate,
                                                      weekCount: weekCount,
                                                      events: events))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：每周三条事项，另有一条跨周事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let startDate = Self.weekStartDate()
        let names = [resGetString("Team Meeting"), resGetString("Deep Work"), resGetString("Review"),
                     resGetString("Workout"), resGetString("Reading"), resGetString("Planning"),
                     resGetString("Design Sync"), resGetString("Study")]
        let colors: [UIColor] = [Color(0x4286F5), Color(0xC274FF), Color(0xF6BF25), Color(0x00CF85),
                                 Color(0x30D158), Color(0xF3501D), Color(0x7E64FD), Color(0x01CFD4)]
        /// 每周事项落在第几天，以及开始、结束时间
        let slots = [(day: 0, startHour: 9, endHour: 10),
                     (day: 2, startHour: 14, endHour: 16),
                     (day: 4, startHour: 10, endHour: 11)]

        var events: [CalendarEvent] = []
        for week in 0..<weekCount {
            for (slotIndex, slot) in slots.enumerated() {
                guard let date = startDate.dateByAddingDays(week * DAYS_PER_WEEK + slot.day) else {
                    continue
                }

                let nameIndex = (week * slots.count + slotIndex) % names.count
                events.append(makePreviewEvent(identifier: "preview-\(week)-\(slotIndex)",
                                               name: names[nameIndex],
                                               color: colors[nameIndex],
                                               date: date,
                                               startHour: slot.startHour,
                                               endHour: slot.endHour))
            }
        }

        /// 跨天事项：单周时落在本周内，多周时跨过首周与次周
        let spanStartDay = weekCount > 1 ? 5 : 1
        let spanEndDay = weekCount > 1 ? DAYS_PER_WEEK + 2 : 2
        if let spanStartDate = startDate.dateByAddingDays(spanStartDay),
           let spanEndDate = startDate.dateByAddingDays(spanEndDay) {
            events.append(makePreviewEvent(identifier: "preview-span",
                                           name: resGetString("Conference"),
                                           color: Color(0x7E64FD),
                                           startDate: spanStartDate.dateByAddingHours(13) ?? spanStartDate,
                                           endDate: spanEndDate.dateByAddingHours(17) ?? spanEndDate))
        }

        return WSCalendarWeekEventBarDataItem(startDate: startDate,
                                              weekCount: weekCount,
                                              events: events)
    }

    // MARK: - 辅助
    /// 本周的第一天
    private static func weekStartDate() -> Date {
        return Date().firstDayOfWeek(firstWeekday: CalendarSetting.shared.firstWeekday).startOfDay()
    }

    /// 本周开始覆盖显示周数的范围
    private static func makeDisplayRange(weekCount: Int) -> DateInterval {
        return .rangeOfDays(firstDate: weekStartDate(), dayCount: weekCount * DAYS_PER_WEEK)
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
