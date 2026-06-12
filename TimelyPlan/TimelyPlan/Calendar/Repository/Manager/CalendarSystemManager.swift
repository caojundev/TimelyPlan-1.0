//
//  CalendarSystemManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/29.
//
import Foundation
import EventKit

// MARK: - 自定义错误类型
enum CalendarManagerError: Error, LocalizedError {
    case accessDenied
    case calendarNotFound
    case saveFailed(Error)
    case removeFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .accessDenied:
            return "没有权限访问日历"
        case .calendarNotFound:
            return "未找到默认日历"
        case .saveFailed(let error):
            return "保存事件失败: \(error.localizedDescription)"
        case .removeFailed(let error):
            return "删除事件失败: \(error.localizedDescription)"
        }
    }
}

// MARK: - 结果类型封装
enum CalendarManagerResult<T> {
    case success(T)
    case failure(CalendarManagerError)
}

class CalendarSystemManager {
    
    // MARK: - 单例
    static let shared = CalendarSystemManager()
    
    private let eventStore = EKEventStore()
    private let operationQueue = DispatchQueue(label: "com.calendar.operation", qos: .userInitiated)
    
    private init() {
        // 不在初始化时请求权限，按需请求
    }
    
    // MARK: - 权限管理
    
    /// 请求日历访问权限
    func requestAccess(completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    debugPrint("请求日历权限失败: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
        
    #warning("iOS 17支持: info.plist 添加 NSCalendarsFullAccessUsageDescription，InfoPlist.strings 添加本地化描述")
        /*
        if #available(iOS 17.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("请求日历权限失败: \(error.localizedDescription)")
                    }
                    completion(granted)
                }
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("请求日历权限失败: \(error.localizedDescription)")
                    }
                    completion(granted)
                }
            }
        }
        */
    }
    
    /// 检查当前权限状态
    var authorizationStatus: EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: .event)
    }
    
    /// 检查是否有权限
    var hasAccess: Bool {
        #warning("iOS 17支持")
        return authorizationStatus == .authorized
        //return authorizationStatus == .authorized || authorizationStatus == .fullAccess
    }
    
    // MARK: - 权限验证
    
    /// 验证权限的通用方法
    private func validateAccess() -> CalendarManagerError? {
        guard hasAccess else {
            return .accessDenied
        }
        return nil
    }
    
    // MARK: - 日历操作
    
    /// 获取所有日历
    func fetchCalendars(completion: @escaping (CalendarManagerResult<[EKCalendar]>) -> Void) {
        operationQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let error = self.validateAccess() {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let calendars = self.eventStore.calendars(for: .event)
            DispatchQueue.main.async {
                completion(.success(calendars))
            }
        }
    }
    
    /// 获取分组日历
    func fetchGroupedCalendars(completion: @escaping (CalendarManagerResult<[EKSource: [EKCalendar]]>) -> Void) {
        fetchCalendars { result in
            switch result {
            case .success(let calendars):
                let grouped = Dictionary(grouping: calendars) { $0.source! }
                completion(.success(grouped))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetchSortedGroupedCalendars(completion: @escaping ([(EKSource, [EKCalendar])]) -> Void) {
        fetchGroupedCalendars { result in
            guard case .success(let dic) = result else {
                completion([])
                return
            }
            
            let sortedItems = dic.sorted {
                if $0.key.sourceType != $1.key.sourceType {
                    return $0.key.sourceType.rawValue < $1.key.sourceType.rawValue
                }
                
                return $0.key.title.localizedCaseInsensitiveCompare($1.key.title) == .orderedAscending
            }
            
            completion(sortedItems)
        }
    }
    
    /// 根据类型筛选日历
    func fetchCalendars(ofType type: EKCalendarType, completion: @escaping (CalendarManagerResult<[EKCalendar]>) -> Void) {
        fetchCalendars { result in
            switch result {
            case .success(let calendars):
                let filtered = calendars.filter { $0.type == type }
                completion(.success(filtered))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 来源操作
    
    /// 获取所有日历来源
    func fetchSources(completion: @escaping (CalendarManagerResult<[EKSource]>) -> Void) {
        operationQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let error = self.validateAccess() {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let sources = self.eventStore.sources
            DispatchQueue.main.async {
                completion(.success(sources))
            }
        }
    }
    
    /// 获取排序后的日历来源
    func fetchSortedSources(completion: @escaping (CalendarManagerResult<[EKSource]>) -> Void) {
        fetchSources { result in
            switch result {
            case .success(let sources):
                let sorted = sources.sorted { source1, source2 in
                    if source1.sourceType != source2.sourceType {
                        return source1.sourceType.rawValue < source2.sourceType.rawValue
                    }
                    return source1.title.localizedCaseInsensitiveCompare(source2.title) == .orderedAscending
                }
                completion(.success(sorted))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 事件操作
    
    /// 获取指定时间范围内的事件
    func fetchEvents(from startDate: Date, to endDate: Date,
                     calendars: [EKCalendar]? = nil,
                     completion: @escaping (CalendarManagerResult<[EKEvent]>) -> Void) {
        operationQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let error = self.validateAccess() {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let predicate = self.eventStore.predicateForEvents(
                withStart: startDate,
                end: endDate,
                calendars: calendars
            )
            let events = self.eventStore.events(matching: predicate)
            
            DispatchQueue.main.async {
                completion(.success(events))
            }
        }
    }
    
    /// 根据标识符获取事件
    func fetchEvent(withIdentifier identifier: String,
                    completion: @escaping (CalendarManagerResult<EKEvent?>) -> Void) {
        operationQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let error = self.validateAccess() {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            let event = self.eventStore.event(withIdentifier: identifier)
            DispatchQueue.main.async {
                completion(.success(event))
            }
        }
    }
    
    /// 添加新事件
    func addEvent(title: String,
                  startDate: Date,
                  endDate: Date,
                  notes: String? = nil,
                  location: String? = nil,
                  calendar: EKCalendar? = nil,
                  alarms: [EKAlarm]? = nil,
                  recurrenceRules: [EKRecurrenceRule]? = nil,
                  completion: @escaping (CalendarManagerResult<EKEvent>) -> Void) {
        
        operationQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let error = self.validateAccess() {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let targetCalendar = calendar ?? self.eventStore.defaultCalendarForNewEvents else {
                DispatchQueue.main.async {
                    completion(.failure(.calendarNotFound))
                }
                return
            }
            
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.notes = notes
            event.location = location
            event.calendar = targetCalendar
            
            if let alarms = alarms {
                event.alarms = alarms
            }
            
            if let recurrenceRules = recurrenceRules {
                event.recurrenceRules = recurrenceRules
            }
            
            do {
                try self.eventStore.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    completion(.success(event))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }
    
    /// 更新现有事件
    func updateEvent(_ event: EKEvent,
                     completion: @escaping (CalendarManagerResult<Void>) -> Void) {
        operationQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let error = self.validateAccess() {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                try self.eventStore.save(event, span: .thisEvent)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.saveFailed(error)))
                }
            }
        }
    }
    
    /// 删除事件
    func deleteEvent(_ event: EKEvent,
                     span: EKSpan = .thisEvent,
                     completion: @escaping (CalendarManagerResult<Void>) -> Void) {
        operationQueue.async { [weak self] in
            guard let self = self else { return }
            
            if let error = self.validateAccess() {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            do {
                try self.eventStore.remove(event, span: span)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.removeFailed(error)))
                }
            }
        }
    }
    
    // MARK: - 便捷方法
    
    /// 检查某个时间段是否有事件
    func hasEvents(from startDate: Date, to endDate: Date,
                   completion: @escaping (Bool) -> Void) {
        fetchEvents(from: startDate, to: endDate) { result in
            switch result {
            case .success(let events):
                completion(!events.isEmpty)
            case .failure:
                completion(false)
            }
        }
    }
    
    /// 获取今天的日历事件
    func fetchTodayEvents(completion: @escaping (CalendarManagerResult<[EKEvent]>) -> Void) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            completion(.failure(.calendarNotFound))
            return
        }
        fetchEvents(from: startOfDay, to: endOfDay, completion: completion)
    }
}
