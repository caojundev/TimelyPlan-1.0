//
//  CalendarManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/29.
//

import Foundation
import EventKit

class CalendarManager {
    
    private let eventStore = EKEventStore()
    
    // MARK: - 单例模式（如果需要）
    static let shared = CalendarManager()
    
    private init() {
        requestAccess()
    }
    
    // MARK: - 权限管理
    
    /// 请求日历访问权限
    func requestAccess(completion: ((Bool, Error?) -> Void)? = nil) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            if let completion = completion {
                completion(granted, error)
            }
        }
    }
    
    /// 检查当前权限状态
    func checkAuthorizationStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    // MARK: - 日历操作
    
    /// 获取所有日历
    func fetchCalendars(completion: @escaping ([EKCalendar]?) -> Void) {
        switch checkAuthorizationStatus() {
        case .authorized:
            let calendars = eventStore.calendars(for: .event)
            completion(calendars)
        default:
            print("没有权限访问日历")
            completion(nil)
        }
    }
    
    func fetchGroupedCalendars(completion: @escaping ([EKSource: [EKCalendar]]?) -> Void) {
        fetchCalendars { calendars in
            guard let calendars = calendars else {
                completion(nil)
                return
            }
            
            let groupedCalendars = Dictionary(grouping: calendars, by: { $0.source! })
            completion(groupedCalendars)
        }
    }
    
    /// 获取排序后的日历来源
    func fetchSortedSources() -> [EKSource] {
        let sources = eventStore.sources
        
        // 按来源类型和标题排序
        return sources.sorted {
            // 先按来源类型排序
            if $0.sourceType != $1.sourceType {
                return $0.sourceType.rawValue < $1.sourceType.rawValue
            }
            // 同类型按标题排序
            return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
    }
    
    // MARK: - 来源操作
    
    /// 获取排序后的日历来源
    func fetchSortedSources(completion: @escaping ([EKSource]?) -> Void) {
        switch checkAuthorizationStatus() {
        case .authorized:
            let sources = eventStore.sources
            // 按来源类型和标题排序
            let sortedSources = sources.sorted {
                if $0.sourceType != $1.sourceType {
                    return $0.sourceType.rawValue < $1.sourceType.rawValue
                }
                return $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
            completion(sortedSources)
        default:
            print("没有权限访问日历来源")
            completion(nil)
        }
    }
    
    // MARK: - 事件操作
    
    /// 获取指定时间范围内的事件
    func fetchEvents(startDate: Date, endDate: Date, completion: @escaping ([EKEvent]?) -> Void) {
        switch checkAuthorizationStatus() {
        case .authorized:
            let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
            let events = eventStore.events(matching: predicate)
            completion(events)
        default:
            print("没有权限访问事件")
            completion(nil)
        }
    }
    
    /// 添加新事件到默认日历
    func addEvent(title: String, startDate: Date, endDate: Date, completion: @escaping (Bool, Error?) -> Void) {
        switch checkAuthorizationStatus() {
        case .authorized:
            let event = EKEvent(eventStore: eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try eventStore.save(event, span: .thisEvent)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        default:
            completion(false, NSError(domain: "No access", code: 0, userInfo: [NSLocalizedDescriptionKey: "没有权限访问日历"]))
        }
    }
    
    /// 删除指定事件
    func deleteEvent(_ event: EKEvent, completion: @escaping (Bool, Error?) -> Void) {
        switch checkAuthorizationStatus() {
        case .authorized:
            do {
                try eventStore.remove(event, span: .thisEvent)
                completion(true, nil)
            } catch {
                completion(false, error)
            }
        default:
            completion(false, NSError(domain: "No access", code: 0, userInfo: [NSLocalizedDescriptionKey: "没有权限访问日历"]))
        }
    }
}
