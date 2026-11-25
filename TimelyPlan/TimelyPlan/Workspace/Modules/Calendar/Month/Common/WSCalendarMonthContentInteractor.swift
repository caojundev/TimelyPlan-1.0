//
//  WSCalendarMonthContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/8.
//

import Foundation
import UIKit

/// 日历月历组件的内容交互器。
///
/// 复用年份视图的事项取数器按月取数，按天汇总颜色后交给月历视图绘制指示点；
/// 点击某天打开该天的事项列表，添加事项沿用日历事项交互器基类。
class WSCalendarMonthContentInteractor: WSCalendarEventContentInteractor,
                                        CalendarEventChangeDelegate {

    /// 事项取数器。仅仪表盘取数时创建，画廊只渲染预览数据
    private var eventsFetcher: CalendarYearEventsFetcher?

    /// 展示的月份数量，与内容视图展示的月份数量保持一致
    var monthCount: Int {
        return 1
    }

    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)

        guard context == .dashboard else {
            return
        }

        let eventsFetcher = CalendarYearEventsFetcher()
        self.eventsFetcher = eventsFetcher
        /// 观察者由数据仓库弱引用持有，无需手动移除
        eventsFetcher.addEventChangeDelegate(self)
    }

    // MARK: - 交互
    /// 点击组件主体不处理：由月历视图按点击的日期打开事项列表
    override func performPrimaryAction() {

    }

    // MARK: - CalendarEventChangeDelegate
    /// 只有与展示月份有交集的事项变化才影响展示内容
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let monthRanges = displayMonthDates.compactMap {
            Calendar.current.monthInterval(year: $0.year, month: $0.month)
        }
        guard ranges.contains(where: { range in
            return monthRanges.contains { $0.intersects(range) }
        }) else {
            return
        }

        pluginDataDidChange()
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let eventsFetcher = eventsFetcher else {
            completion(nil)
            return
        }

        let monthDates = displayMonthDates
        var eventsInfos = [CalendarMonthEventsInfo?](repeating: nil, count: monthDates.count)
        let group = DispatchGroup()

        for (index, monthDate) in monthDates.enumerated() {
            group.enter()
            eventsFetcher.fetchEventsForMonth(year: monthDate.year, month: monthDate.month) { info in
                eventsInfos[index] = info
                group.leave()
            }
        }

        group.notify(queue: .main) {
            let months = monthDates.enumerated().map { index, monthDate in
                return WSCalendarMonthItem(monthDate: monthDate,
                                           dayEventColors: Self.makeDayEventColors(from: eventsInfos[index]))
            }
            completion(WSCalendarMonthDataItem(months: months, today: Date()))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：当月若干天带上示例事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let months = displayMonthDates.map {
            return WSCalendarMonthItem(monthDate: $0,
                                       dayEventColors: Self.makePreviewDayEventColors(in: $0))
        }

        return WSCalendarMonthDataItem(months: months, today: Date())
    }

    // MARK: - 辅助
    /// 展示的月份，从当月开始
    private var displayMonthDates: [Date] {
        let currentMonth = Date().startOfMonth()
        return (0..<monthCount).compactMap {
            return currentMonth.dateByAddingMonths($0)
        }
    }

    /// 事项绘制信息转成「日 -> 颜色」
    private static func makeDayEventColors(from eventsInfo: CalendarMonthEventsInfo?) -> [Int: [UIColor]] {
        guard let eventsInfo = eventsInfo else {
            return [:]
        }

        var dayEventColors: [Int: [UIColor]] = [:]
        for dayEvent in eventsInfo.dayEvents where !dayEvent.indicatorColors.isEmpty {
            dayEventColors[dayEvent.day] = dayEvent.indicatorColors
        }

        return dayEventColors
    }

    /// 预览用的示例事项颜色
    private static func makePreviewDayEventColors(in monthDate: Date) -> [Int: [UIColor]] {
        let sampleColors: [UIColor] = [Color(0x4286F5), Color(0x00CF85), Color(0xF6BF25), Color(0xC274FF)]
        let samples: [(day: Int, colorCount: Int)] = [(3, 3), (8, 1), (15, 2), (22, 3)]
        let daysCount = monthDate.numberOfDaysInMonth()

        var dayEventColors: [Int: [UIColor]] = [:]
        for sample in samples where sample.day <= daysCount {
            dayEventColors[sample.day] = Array(sampleColors.prefix(sample.colorCount))
        }

        return dayEventColors
    }
}
