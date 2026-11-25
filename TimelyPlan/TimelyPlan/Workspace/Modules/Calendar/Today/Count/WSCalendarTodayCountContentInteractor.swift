//
//  WSCalendarTodayCountContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

/// 日历·小·今日事项数目的内容交互器。
///
/// 在今日日期的基础上附带当天事项数目，事项变化时重新取数。
class WSCalendarTodayCountContentInteractor: WSCalendarTodayDateContentInteractor,
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

    // MARK: - CalendarEventChangeDelegate
    /// 只有与今天有交集的事项变化才影响数目
    func calendarEventsDidChange(in ranges: [DateInterval]) {
        let todayRange = DateInterval.rangeOfDay(Date())
        guard ranges.contains(where: { $0.intersects(todayRange) }) else {
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
        repository.fetchEvents(in: .rangeOfDay(date)) { events in
            completion(WSCalendarTodayDateDataItem(date: date, eventCount: events.count))
        }
    }

    // MARK: - 预览数据
    /// 画廊预览数据：固定的日期与事项数目，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        return WSCalendarTodayDateDataItem(date: Date(), eventCount: 3)
    }
}
