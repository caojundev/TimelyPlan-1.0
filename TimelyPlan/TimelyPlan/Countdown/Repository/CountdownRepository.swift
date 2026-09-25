//
//  CountdownRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation

struct CountdownUpdaterOption: OptionSet {
    
    let rawValue: Int
    
    static let event = CountdownUpdaterOption(rawValue: 1 << 1)
    
    /// 所有
    static let all: CountdownUpdaterOption = [.event]
}


class CountdownRepository {
    
    // MARK: - 数据管理器
    private static let eventManager = CountdownEventManager()
    
    // MARK: - 注册远程数据变更
    private static var isRemoteChangeObserved = false
    private static func observeRemoteChangeIfNeeded() {
        if isRemoteChangeObserved {
            return
        }
        
        isRemoteChangeObserved = true
        HandyRecord.observeRemoteChange { changeInfo in
            let entityNames = changeInfo.entityNames
            if entityNames.contains(.countdownEvent) {
                let results = changeInfo.extractCountdownEvent()
                eventManager.updater.didChangeRemoteCountdownEvent(with: results)
            }
        }
    }
    
    /// 添加更新器代理对象
    static func addUpdater(_ updater: AnyObject, for option: CountdownUpdaterOption = .all) {
        observeRemoteChangeIfNeeded()
        
        if option.contains(.event) {
            eventManager.updater.addDelegate(updater)
        }
    }
    
    /// 移除更新器代理对象
    static func removeUpdater(_ updater: AnyObject) {
        eventManager.updater.removeDelegate(updater)
    }
    
    // MARK: - 获取
    /// 获取所有倒数日事项
    static func getAllEvents() -> [CountdownEvent] {
        return eventManager.getAllEvents() ?? []
    }
    
    /// 获取所有活动倒数日事项
    static func getActiveEvents() -> [CountdownEvent] {
        return eventManager.getActiveEvents() ?? []
    }
    
    /// 获取所有已归档倒数日事项
    static func getArchivedEvents() -> [CountdownEvent] {
        return eventManager.getArchivedEvents() ?? []
    }
    
    /// 获取已归档倒数日事项数目
    static func numberOfArchivedEvents() -> Int {
        return eventManager.numberOfArchivedEvents()
    }
    
    /// 获取特定标识的倒数日事项
    static func getEvent(withIdentifier identifier: String) -> CountdownEvent? {
        return eventManager.getEvent(withIdentifier: identifier)
    }
    
    /// 异步获取所有活动倒数日事项
    static func fetchActiveEvents(completion: @escaping ([CountdownEvent]?) -> Void) {
        eventManager.fetchActiveEvents(completion: completion)
    }
    
    /// 异步获取所有已归档倒数日事项
    static func fetchArchivedEvents(completion: @escaping ([CountdownEvent]?) -> Void) {
        eventManager.fetchArchivedEvents(completion: completion)
    }
    
    /// 异步获取包含提醒的活动倒数日事项
    static func fetchNotifiableEvents(completion: @escaping ([CountdownEvent]?) -> Void) {
        eventManager.fetchNotifiableEvents(completion: completion)
    }
    
    /// 异步搜索活动倒数日事项（按名称，不区分大小写）
    static func searchActiveEvents(containText text: String,
                                   completion: @escaping ([CountdownEvent]?) -> Void) {
        eventManager.searchActiveEvents(containText: text, completion: completion)
    }
    
    // MARK: - 处理倒数日事项
    /// 创建倒数日事项
    @discardableResult
    static func createEvent(with editingEvent: CountdownEditingEvent) -> CountdownEvent? {
        return eventManager.createEvent(with: editingEvent)
    }
    
    /// 更新倒数日事项
    @discardableResult
    static func updateEvent(_ event: CountdownEvent,
                            with editingEvent: CountdownEditingEvent) -> CountdownEvent? {
        return eventManager.updateEvent(event, with: editingEvent)
    }
    
    /// 更新倒数日事项在「我的一天」中的显示方式
    @discardableResult
    static func updateEvent(_ event: CountdownEvent,
                            myDayDisplayMode: CountdownDisplayMode) -> CountdownEvent? {
        guard event.myDayDisplayMode != myDayDisplayMode else {
            return nil
        }
        
        var editingEvent = event.editingEvent
        editingEvent.myDayDisplayMode = myDayDisplayMode
        return updateEvent(event, with: editingEvent)
    }
    
    /// 归档倒数日事项
    static func archiveEvent(_ event: CountdownEvent) {
        eventManager.setArchived(true, for: event)
    }
    
    /// 取消归档倒数日事项
    static func unarchiveEvent(_ event: CountdownEvent) {
        eventManager.setArchived(false, for: event)
    }
    
    /// 删除倒数日事项
    static func deleteEvent(_ event: CountdownEvent) {
        eventManager.deleteEvent(event)
    }
    
    /// 重排倒数日事项
    static func didEndReorderEvents(with orderedEvents: [CountdownEvent]) {
        eventManager.didEndReorderEvents(with: orderedEvents)
    }
}
