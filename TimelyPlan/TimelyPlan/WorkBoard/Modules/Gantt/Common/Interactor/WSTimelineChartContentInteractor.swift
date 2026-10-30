//
//  WSTimelineChartContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的内容交互器。
///
/// 按时间刻度取回整个刻度范围内的事项，事项变化时重新取数。
final class WSTimelineChartContentInteractor: WSPluginContentInteractor,
                                              GanttEventChangeDelegate {

    /// 当前时间刻度
    let scale: GanttTimeScale.Scale

    /// 当前展示日期，用于确定时间刻度所在年份
    private(set) var date: Date = .now

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

    // MARK: - 日期

    /// 切换展示日期。仅月份变化时需要重新取数
    func setDate(_ date: Date) {
        guard !self.date.isInSameMonthAs(date) else { return }

        self.date = date
        setNeedsReload()
    }

    // MARK: - 取数

    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let date = self.date
        let timeScale = GanttTimeScale(scale: scale, date: date)
        let range = DateInterval(start: timeScale.startDate, end: timeScale.endDate)
        currentRange = range
        repository.fetchEvents(in: range) { events in
            completion(WSTimelineChartDataItem(timeScale: timeScale, date: date, events: events))
        }
    }

    /// 画廊预览数据：最近一周左右的示例事项
    override func previewDataItem() -> WSPluginDataItem? {
        let timeScale = GanttTimeScale(scale: scale, date: date)
        let today = Date().startOfDay()

        let samples: [(title: String, startOffset: Int, endOffset: Int, progress: CGFloat, color: UInt64)] = [
            (resGetString("Planning"), -6, -3, 1.0, 0xFF9500),
            (resGetString("Reading"), -4, -1, 0.75, 0xFF9F0A),
            (resGetString("Study"), -2, 2, 0.45, 0x0A84FF),
            (resGetString("Workout"), 0, 1, 1.0, 0xFF375F),
            (resGetString("Deep Work"), 1, 4, 0.2, 0x5E5CE6),
            (resGetString("Meditation"), 3, 6, 0.0, 0xAF52DE)
        ]

        let events = samples.enumerated().compactMap { index, sample -> GanttEvent? in
            guard let startDate = today.dateByAddingDays(sample.startOffset),
                  let endDate = today.dateByAddingDays(sample.endOffset) else {
                return nil
            }

            return GanttEvent(id: "preview.\(index)",
                              name: sample.title,
                              startDate: startDate,
                              endDate: endDate.endOfDay(),
                              progress: sample.progress,
                              color: Color(sample.color),
                              source: index % 2 == 0 ? .todo : .goal,
                              sourceItem: NSNull())
        }

        return WSTimelineChartDataItem(timeScale: timeScale, date: date, events: events)
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
