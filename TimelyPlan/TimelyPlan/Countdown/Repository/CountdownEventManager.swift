//
//  CountdownEventManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/14.
//

import Foundation
import CoreData

class CountdownEventManager {
    
    /// 数据更新器
    let updater = CountdownEventProcessorUpdater()
    
    /// 默认上下文对象
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    // MARK: - 异步获取倒数日事项
    func fetchActiveEvents(completion: @escaping([CountdownEvent]?) -> Void) {
        CDCountdownEvent.fetchActiveEvents { results in
            completion(results?.toEvents)
        }
    }
    
    func fetchArchivedEvents(completion: @escaping([CountdownEvent]?) -> Void) {
        CDCountdownEvent.fetchArchivedEvents { results in
            completion(results?.toEvents)
        }
    }
    
    /// 异步获取包含提醒的活动倒数日事项
    func fetchNotifiableEvents(completion: @escaping([CountdownEvent]?) -> Void) {
        CDCountdownEvent.fetchNotifiableEvents { results in
            completion(results?.toEvents)
        }
    }
    
    /// 按名称搜索活动倒数日事项
    func searchActiveEvents(containText text: String,
                            completion: @escaping([CountdownEvent]?) -> Void) {
        CDCountdownEvent.searchActiveEvents(containText: text) { results in
            completion(results?.toEvents)
        }
    }
    
    // MARK: - 同步获取倒数日事项
    /// 获取所有倒数日事项
    func getAllEvents() -> [CountdownEvent]? {
        return CDCountdownEvent.getAllEvents()?.toEvents
    }
    
    /// 获取所有活动倒数日事项
    func getActiveEvents() -> [CountdownEvent]? {
        return CDCountdownEvent.getActiveEvents()?.toEvents
    }
    
    /// 获取所有已归档倒数日事项
    func getArchivedEvents() -> [CountdownEvent]? {
        return CDCountdownEvent.getArchivedEvents()?.toEvents
    }
    
    /// 获取已归档倒数日事项数目
    func numberOfArchivedEvents() -> Int {
        return CDCountdownEvent.numberOfArchivedEvents()
    }
    
    /// 获取特定标识的倒数日事项
    func getEvent(withIdentifier identifier: String) -> CountdownEvent? {
        if let content = CDCountdownEvent.getEvent(withIdentifier: identifier) {
            return CountdownEvent(content: content)
        }
        
        return nil
    }
    
    // MARK: - 处理倒数日事项
    /// 创建倒数日事项
    @discardableResult
    func createEvent(with editingEvent: CountdownEditingEvent) -> CountdownEvent? {
        let content = CDCountdownEvent.newEvent(with: editingEvent)
        content.order = CDCountdownEvent.maximumOrder + kOrderedStep
        
        let event = CountdownEvent(content: content)
        updater.didCreateCountdownEvent(event)
        HandyRecord.updateChangeCount()
        return event
    }
    
    /// 更新倒数日事项
    @discardableResult
    func updateEvent(_ event: CountdownEvent,
                     with editingEvent: CountdownEditingEvent) -> CountdownEvent? {
        if event.isSameEvent(as: editingEvent) {
            return nil
        }
        
        if let content = CDCountdownEvent.getEvent(withIdentifier: event.identifier) {
            /// 更新前记录旧值，用于生成改变内容
            let oldEditingEvent = event.editingEvent
            content.update(with: editingEvent)
            
            let updatedEvent = CountdownEvent(content: content)
            let change: CountdownEventChange = .content(oldValue: oldEditingEvent,
                                                        newValue: editingEvent)
            updater.didUpdateCountdownEvent(updatedEvent, with: change)
            HandyRecord.updateChangeCount()
            return updatedEvent
        }
        
        return nil
    }
    
    /// 删除倒数日事项
    func deleteEvent(_ event: CountdownEvent) {
        if let content = CDCountdownEvent.getEvent(withIdentifier: event.identifier) {
            context.delete(content)
            
            /// 先同步落库再通知，保证删除后基于谓词的查询立即生效
            HandyRecord.saveSynchronously()
            
            updater.didDeleteCountdownEvent(event)
        }
    }
    
    /// 设置归档状态
    func setArchived(_ isArchived: Bool, for event: CountdownEvent) {
        guard event.isArchived != isArchived else {
            return
        }
        
        if let content = CDCountdownEvent.getEvent(withIdentifier: event.identifier) {
            content.isArchived = isArchived
            
            /// 先同步落库再通知，保证归档后相关查询立即生效
            HandyRecord.saveSynchronously()
            
            let updatedEvent = CountdownEvent(content: content)
            if isArchived {
                updater.didArchiveCountdownEvent(updatedEvent)
            } else {
                updater.didUnarchiveCountdownEvent(updatedEvent)
            }
        }
    }
    
    /// 重排倒数日事项
    func didEndReorderEvents(with orderedEvents: [CountdownEvent]) {
        CDCountdownEvent.syncOrders(for: orderedEvents)
        HandyRecord.updateChangeCount()
    }
}
