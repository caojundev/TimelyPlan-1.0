//
//  WSCalendarTimelineContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/9.
//

import Foundation
import UIKit

/// 日历时间线组件的内容交互器。
///
/// 取当前整点起 `hourCount` 个小时内的事项；整点变化时重新取数，让展示范围跟随当前时间移动。
class WSCalendarTimelineContentInteractor: WSCalendarEventContentInteractor,
                                           CalendarEventChangeDelegate {

    /// 展示的小时数，由组件尺寸决定
    let hourCount: Int

    /// 日历数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private var repository: CalendarRepository?

    /// 整点刷新
    private let hourUpdater = TPHourUpdater()

    /// 当前数据对应的起始小时
    private var loadedStartHour: Int?

    init(plugin: WSPlugin, context: WSPluginContext, hourCount: Int) {
        self.hourCount = hourCount
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
    /// 只有与展示范围有交集的事项变化才影响展示内容
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let interval = WSCalendarTimelineRange.interval(hourCount: hourCount)
        guard ranges.contains(where: { $0.intersects(interval) }) else {
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
        repository.fetchEvents(in: WSCalendarTimelineRange.interval(at: date, hourCount: hourCount)) { events in
            completion(WSCalendarTimelineDataItem(events: events, at: date, hourCount: self.hourCount))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：在展示范围内放三条示例事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let date = Date()
        let interval = WSCalendarTimelineRange.interval(at: date, hourCount: hourCount)
        let events = [
            makePreviewEvent(identifier: "preview-timeline-1",
                             name: resGetString("Team Meeting"),
                             color: Color(0x4286F5),
                             startDate: interval.start,
                             startMinute: 30,
                             durationMinute: 45),
            makePreviewEvent(identifier: "preview-timeline-2",
                             name: resGetString("Deep Work"),
                             color: Color(0xC274FF),
                             startDate: interval.start,
                             startMinute: 75,
                             durationMinute: 60),
            makePreviewEvent(identifier: "preview-timeline-3",
                             name: resGetString("Review"),
                             color: Color(0xF6BF25),
                             startDate: interval.start,
                             startMinute: 150,
                             durationMinute: 50),
        ]

        return WSCalendarTimelineDataItem(events: events, at: date, hourCount: hourCount)
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
