//
//  WSTimelineChartContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的内容交互器
///
/// 按时间刻度取回展示范围内的事项，只保留与展示范围相交的前若干个事项；事项变化时重新取数。
final class WSTimelineChartContentInteractor: WSPluginContentInteractor,
                                              GanttEventChangeDelegate {

    /// 当前时间刻度
    let scale: GanttTimeScale.Scale

    private let repository = GanttRepository()

    /// 最近一次取数的日期范围
    private var currentRange: DateInterval?

    init(plugin: WSPlugin, context: WSPluginContext, scale: GanttTimeScale.Scale) {
        self.scale = scale
        super.init(plugin: plugin, context: context)

        repository.addUpdaterDelegate(self)
    }

    deinit {
        repository.removeUpdaterDelegate(self)
    }

    // MARK: - 取数

    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let timeRange = WSTimelineChartTimeRange(scale: scale, date: Date())
        let range = timeRange.dateInterval
        currentRange = range

        repository.fetchEvents(in: range) { events in
            /// 只保留与展示范围相交的事项，按顺序取前面若干个
            let visibleEvents = events
                .filter { timeRange.intersects(start: $0.startDate, end: $0.endDate) }
                .prefix(WSTimelineChartConfig.eventRowCount)

            completion(WSTimelineChartDataItem(timeRange: timeRange, events: Array(visibleEvents)))
        }
    }

    /// 画廊预览数据：在展示范围内生成示例事项
    override func previewDataItem() -> WSPluginDataItem? {
        let timeRange = WSTimelineChartTimeRange(scale: scale, date: Date())
        let range = timeRange.dateInterval

        let samples: [(title: String, startRatio: Double, endRatio: Double, progress: CGFloat, color: UInt64)] = [
            (resGetString("Planning"), 0.05, 0.25, 1.0, 0xFF9500),
            (resGetString("Reading"), 0.2, 0.45, 0.75, 0xFF9F0A),
            (resGetString("Study"), 0.35, 0.6, 0.45, 0x0A84FF),
            (resGetString("Workout"), 0.45, 0.55, 1.0, 0xFF375F),
            (resGetString("Deep Work"), 0.55, 0.75, 0.2, 0x5E5CE6),
            (resGetString("Meditation"), 0.7, 0.95, 0.0, 0xAF52DE)
        ]

        let duration = range.duration
        let events = samples.enumerated().compactMap { index, sample -> GanttEvent? in
            let startDate = range.start.addingTimeInterval(duration * sample.startRatio)
            let endDate = range.start.addingTimeInterval(duration * sample.endRatio)
            guard endDate > startDate else { return nil }

            return GanttEvent(id: "preview.\(index)",
                              name: sample.title,
                              startDate: startDate,
                              endDate: endDate,
                              progress: sample.progress,
                              color: Color(sample.color),
                              source: index % 2 == 0 ? .todo : .goal,
                              sourceItem: NSNull())
        }

        return WSTimelineChartDataItem(timeRange: timeRange, events: events)
    }

    // MARK: - 交互

    /// 打开事项详情
    func openEvent(_ event: GanttEvent) {
        GanttEventProcessor().clickEvent(event)
    }

    // MARK: - GanttEventChangeDelegate

    func ganttEventsDidChange(in ranges: [DateInterval]) {
        guard let currentRange = currentRange,
              ranges.contains(where: { $0.intersects(currentRange) }) else {
            return
        }

        pluginDataDidChange()
    }
}
