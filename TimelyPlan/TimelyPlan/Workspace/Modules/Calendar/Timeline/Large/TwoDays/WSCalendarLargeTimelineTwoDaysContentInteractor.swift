//
//  WSCalendarLargeTimelineTwoDaysContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

/// 日历·大·两天时间线的内容交互器。
///
/// 一次取到今天与明天展示范围内的事项再按天分组：
/// 左侧跟随当前时间，右侧固定明天的 09:00 ~ 16:00。
class WSCalendarLargeTimelineTwoDaysContentInteractor: WSCalendarEventContentInteractor,
                                                       CalendarEventChangeDelegate {

    /// 左侧展示的小时数
    private let hourCount = 6

    /// 日历数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private var repository: CalendarRepository?

    /// 整点刷新
    private let hourUpdater = TPHourUpdater()

    /// 当前数据对应的起始小时
    private var loadedStartHour: Int?

    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)

        guard context == .dashboard else {
            return
        }

        let repository = CalendarRepository()
        self.repository = repository
        /// 观察者由数据仓库弱引用持有，无需手动移除
        repository.addUpdaterDelegate(self)

        hourUpdater.start { [weak self] in
            self?.reloadIfHourChanged()
        }
    }

    // MARK: - 交互
    /// 点击组件主体不处理：事项与空白位置的点击由时间线视图响应
    override func performPrimaryAction() {

    }

    // MARK: - CalendarEventChangeDelegate
    /// 只有与今天或明天的展示范围有交集的事项变化才影响展示内容
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let date = Date()
        let todayInterval = WSCalendarTimelineRange.interval(at: date, hourCount: hourCount)
        let tomorrowInterval = WSCalendarTimelineTwoDaysDataItem.tomorrowInterval(at: date)
        guard ranges.contains(where: { $0.intersects(todayInterval) || $0.intersects(tomorrowInterval) }) else {
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
        loadedStartHour = WSCalendarTimelineRange.startHour(at: date, hourCount: hourCount)

        /// 一次取到今天展示范围开始到明天展示范围结束
        let start = WSCalendarTimelineRange.interval(at: date, hourCount: hourCount).start
        let end = WSCalendarTimelineTwoDaysDataItem.tomorrowInterval(at: date).end
        repository.fetchEvents(in: DateInterval(start: start, end: end)) { events in
            completion(WSCalendarTimelineTwoDaysDataItem(events: events,
                                                         at: date,
                                                         todayHourCount: self.hourCount))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：今天与明天各放两条示例事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let date = Date()
        let todayInterval = WSCalendarTimelineRange.interval(at: date, hourCount: hourCount)
        let tomorrowInterval = WSCalendarTimelineTwoDaysDataItem.tomorrowInterval(at: date)

        let events = [
            makePreviewEvent(identifier: "preview-two-days-today-1",
                             name: resGetString("Team Meeting"),
                             color: Color(0x4286F5),
                             startDate: todayInterval.start,
                             startMinute: 30,
                             durationMinute: 45),
            makePreviewEvent(identifier: "preview-two-days-today-2",
                             name: resGetString("Deep Work"),
                             color: Color(0xC274FF),
                             startDate: todayInterval.start,
                             startMinute: 120,
                             durationMinute: 90),
            makePreviewEvent(identifier: "preview-two-days-tomorrow-1",
                             name: resGetString("Review"),
                             color: Color(0xF6BF25),
                             startDate: tomorrowInterval.start,
                             startMinute: 30,
                             durationMinute: 60),
            makePreviewEvent(identifier: "preview-two-days-tomorrow-2",
                             name: resGetString("Workout"),
                             color: Color(0x00CF85),
                             startDate: tomorrowInterval.start,
                             startMinute: 210,
                             durationMinute: 60),
        ]

        return WSCalendarTimelineTwoDaysDataItem(events: events, at: date, todayHourCount: hourCount)
    }

    // MARK: - 辅助
    /// 当前整点变化后重新取数
    private func reloadIfHourChanged() {
        guard let loadedStartHour = loadedStartHour,
              WSCalendarTimelineRange.startHour(at: Date(), hourCount: hourCount) != loadedStartHour else {
            return
        }

        pluginDataDidChange()
    }

    private func makePreviewEvent(identifier: String,
                                  name: String,
                                  color: UIColor,
                                  startDate: Date,
                                  startMinute: Int,
                                  durationMinute: Int) -> CalendarEvent {
        let start = startDate.dateByAddingMinutes(startMinute) ?? startDate
        return CalendarEvent(identifier: identifier,
                             source: .system,
                             name: name,
                             color: color,
                             startDate: start,
                             endDate: start.dateByAddingMinutes(durationMinute) ?? start,
                             isAllDay: false,
                             isCompleted: false,
                             sourceItem: NSNull())
    }
}
