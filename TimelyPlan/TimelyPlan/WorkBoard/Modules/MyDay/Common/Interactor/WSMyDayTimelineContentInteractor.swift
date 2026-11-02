//
//  WSMyDayTimelineContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 我的一天·时间线的内容交互器，中、大尺寸共用。
///
/// 读取今天的全部事项后，只保留当前时间正在进行与尚未开始的非全天事项；
/// 展示条数由内容视图按可用高度决定。
class WSMyDayTimelineContentInteractor: WSPluginContentInteractor, MyDayEventChangeDelegate {
    
    /// 我的一天数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private var repository: MyDayRepository?
    
    override init(plugin: WSPlugin, context: WSPluginContext) {
        super.init(plugin: plugin, context: context)
        
        /// 画廊不访问数据仓库，避免连带创建数据源观察者与系统日历
        guard context == .dashboard else {
            return
        }
        
        let repository = MyDayRepository()
        self.repository = repository
        /// 观察者由数据仓库弱引用持有，无需手动移除
        repository.addUpdaterDelegate(self)
    }
    
    // MARK: - MyDayEventChangeDelegate
    /// 只有与今天有交集的事项变化才影响展示内容
    func myDayEventsDidChange(in ranges: [DateInterval]) {
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
            /// 正在进行或尚未结束的非全天事项
            let now = Date()
            let displayEvents = events.filter { !$0.isAllDay && $0.endDate > now }
            completion(WSMyDayTimelineDataItem(date: date, events: displayEvents))
        }
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示若干示例事项，覆盖进行中、重叠、实线与虚线连接等场景
    override func previewDataItem() -> WSPluginDataItem? {
        let now = Date()
        let examples: [(title: String, color: UIColor, offset: TimeInterval, duration: TimeInterval)] = [
            (resGetString("Deep Work"), Color(0x0A84FF), -20 * 60, 60 * 60),
            (resGetString("Reading"), Color(0x30D158), 20 * 60, 60 * 60),
            (resGetString("Project Launch"), Color(0xFF9F0A), 140 * 60, 30 * 60),
            (resGetString("Family Trip"), Color(0xFF6482), 175 * 60, 60 * 60),
            (resGetString("Graduation"), Color(0xAF52DE), 280 * 60, 30 * 60),
            (resGetString("Vacation"), Color(0x64D2FF), 315 * 60, 10 * 60)
        ]
        
        let events = examples.enumerated().map { index, example -> MyDayEvent in
            return MyDayEvent(identifier: "preview-\(index)",
                              source: .calendar,
                              name: example.title,
                              color: example.color,
                              startDate: now.addingTimeInterval(example.offset),
                              endDate: now.addingTimeInterval(example.offset + example.duration),
                              isAllDay: false,
                              isCompleted: false,
                              sourceItem: NSNull())
        }
        
        return WSMyDayTimelineDataItem(date: now.startOfDay(), events: events)
    }
}
