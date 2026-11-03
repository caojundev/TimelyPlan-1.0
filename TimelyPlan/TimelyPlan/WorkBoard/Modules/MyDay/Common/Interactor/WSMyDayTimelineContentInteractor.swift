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
class WSMyDayTimelineContentInteractor: WSMyDayEventsContentInteractor {
    
    /// 点击事项时才需要，避免初始化时提前创建
    private lazy var eventProcessor = MyDayEventProcessor()
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let repository = repository else {
            completion(nil)
            return
        }
        
        let date = Date()
        repository.fetchEvents(in: .rangeOfDay(date)) { events in
            /// 下发今天的全部事项，由时间线视图按当前时间过滤出正在进行与将要发生的事项
            completion(WSMyDayTimelineDataItem(date: date, events: events))
        }
    }
    
    // MARK: - 条目操作
    /// 点击某一行时，打开该行对应事项的详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let item = dataItem as? WSMyDayTimelineEventItem else {
            return
        }
        
        eventProcessor.clickEvent(item.event)
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
