//
//  WSMyDayUpcomingContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 内容交互器

/// 我的一天·临近事项的内容交互器。
///
/// 读取今天的全部事项后只保留非全天事项下发给内容视图，
/// 展示哪一条由内容视图按当前时间解析；事项变化时重新取数。
class WSMyDayUpcomingContentInteractor: WSPluginContentInteractor, MyDayEventChangeDelegate {
    
    /// 我的一天数据仓库。仅仪表盘取数时创建，画廊只渲染预览数据
    private var repository: MyDayRepository?
    
    /// 点击事项时才需要，避免初始化时提前创建
    private lazy var eventProcessor = MyDayEventProcessor()
    
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
            /// 下发今天的全部事项，由内容视图按当前时间解析需要展示的事项
            completion(WSMyDayUpcomingDataItem(date: date, events: events))
        }
    }
    
    // MARK: - 主操作
    /// 点击组件：打开当前展示事项的详情
    override func performPrimaryAction() {
        guard let dataItem = dataItem as? WSMyDayUpcomingDataItem,
              let display = WSMyDayUpcomingResolver.resolve(events: dataItem.events, at: Date()) else {
            return
        }
        
        eventProcessor.clickEvent(display.item.event)
    }
    
    // MARK: - 重叠事项
    /// 点击重叠事项入口：弹出当天的时间线
    func clickOverlapping() {
        showTimeline()
    }
    
    // MARK: - 弹出
    /// 弹出当天的时间线
    private func showTimeline() {
        let viewController = MyDaySingleDateTimelineViewController(date: Date())
        let navController = UINavigationController(rootViewController: viewController)
        navController.show()
    }
    
    // MARK: - 预览数据
    /// 画廊预览数据：固定展示一条正在进行的事项与一条重叠事项，不受用户数据影响
    override func previewDataItem() -> WSPluginDataItem? {
        let now = Date()
        let ongoingStart = now.addingTimeInterval(TimeInterval(-45 * SECONDS_PER_MINUTE))
        let ongoingEnd = now.addingTimeInterval(TimeInterval(45 * SECONDS_PER_MINUTE))
        let readingStart = now.addingTimeInterval(TimeInterval(10 * SECONDS_PER_MINUTE))
        let readingEnd = now.addingTimeInterval(TimeInterval(70 * SECONDS_PER_MINUTE))
        
        let ongoingEvent = MyDayEvent(identifier: "preview-ongoing",
                                      source: .calendar,
                                      name: resGetString("Deep Work"),
                                      color: Color(0x0A84FF),
                                      startDate: ongoingStart,
                                      endDate: ongoingEnd,
                                      isAllDay: false,
                                      isCompleted: false,
                                      sourceItem: NSNull())
        let readingEvent = MyDayEvent(identifier: "preview-reading",
                                      source: .calendar,
                                      name: resGetString("Reading"),
                                      color: Color(0x30D158),
                                      startDate: readingStart,
                                      endDate: readingEnd,
                                      isAllDay: false,
                                      isCompleted: false,
                                      sourceItem: NSNull())
        
        return WSMyDayUpcomingDataItem(date: Date().startOfDay(), events: [ongoingEvent, readingEvent])
    }
}
