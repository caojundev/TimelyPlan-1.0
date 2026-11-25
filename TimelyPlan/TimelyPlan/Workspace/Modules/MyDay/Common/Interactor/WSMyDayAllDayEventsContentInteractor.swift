//
//  WSMyDayAllDayEventsContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 我的一天·全天事项的内容交互器，各尺寸共用。
///
/// 读取今天的全部事项后只保留全天事项下发给内容视图；
/// 事项变化时重新取数，跨天刷新由基类的零点监听统一处理。
class WSMyDayAllDayEventsContentInteractor: WSMyDayEventsContentInteractor {
    
    /// 点击事项时才需要，避免初始化时提前创建
    private lazy var eventProcessor = MyDayEventProcessor()
    
    /// 画廊预览数据，按天缓存，避免画廊滚动时反复构造
    private static var cachedPreviewData: (date: Date, dataItem: WSMyDayAllDayEventsDataItem)?
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        guard let repository = repository else {
            completion(nil)
            return
        }
        
        let date = Date()
        repository.fetchEvents(in: .rangeOfDay(date)) { events in
            /// 没有全天事项时同样下发数据条目，由内容视图在头部下方展示空白提示
            completion(WSMyDayAllDayEventsDataItem(date: date, events: events.allDayEvents))
        }
    }
    
    // MARK: - 条目操作
    /// 点击某一行时，打开该行对应事项的详情
    override func performAction(with dataItem: WSPluginDataItem) {
        guard let item = dataItem as? WSMyDayAllDayEventItem else {
            /// 显示时间线
            openTimeline()
            return
        }
        
        eventProcessor.clickEvent(item.event)
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示若干示例全天事项，不受用户数据影响。
    /// 预览内容不变，按天缓存，画廊滚动复用单元格时不再重复构造
    override func previewDataItem() -> WSPluginDataItem? {
        let date = Date().startOfDay()
        if let cached = Self.cachedPreviewData, cached.date == date {
            return cached.dataItem
        }
        
        let dataItem = makePreviewDataItem(on: date)
        Self.cachedPreviewData = (date, dataItem)
        return dataItem
    }
    
    /// 构造预览数据。覆盖多种来源，让行视图展示不同类型的图标
    private func makePreviewDataItem(on date: Date) -> WSMyDayAllDayEventsDataItem {
        let startDate = date.startOfDay()
        let endDate = date.endOfDay()
        let examples: [(title: String, color: UIColor, source: MyDayEventSource, isCompleted: Bool)] = [
            (resGetString("Holiday"), Color(0xFF9F0A), .calendar, false),
            (resGetString("Birthday"), Color(0xFF375F), .todo, false),
            (resGetString("Family Trip"), Color(0x30D158), .goal, false),
            (resGetString("Trip Departure"), Color(0x09AFFF), .habit, false),
            (resGetString("Anniversary"), Color(0xAF52DE), .countdown, false),
            (resGetString("Project Launch"), Color(0xFF6482), .focus, false),
            (resGetString("Vacation"), Color(0x64D2FF), .calendar, false),
            (resGetString("Graduation"), Color(0xBF5AF2), .todo, true)
        ]
        
        let events = examples.enumerated().map { index, example -> MyDayEvent in
            return MyDayEvent(identifier: "preview-\(index)",
                              source: example.source,
                              name: example.title,
                              color: example.color,
                              startDate: startDate,
                              endDate: endDate,
                              isAllDay: true,
                              isCompleted: example.isCompleted,
                              sourceItem: MyDayEvent.previewSourceItem(for: example.source,
                                                                       title: example.title,
                                                                       color: example.color,
                                                                       date: endDate))
        }
        
        return WSMyDayAllDayEventsDataItem(date: date, events: events)
    }
}
