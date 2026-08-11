//
//  CalendarSystemManager.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/29.
//
import Foundation
import UIKit
import EventKit
import EventKitUI

// MARK: - 结果类型封装
enum CalendarManagerResult<T> {
    case success(T)
    case failure(CalendarManagerError)
}

protocol CalendarSystemManagerDelegate: AnyObject {
    func calendarSystemManagerDidUpdate(_ manager: CalendarSystemManager)
}

class CalendarSystemManager: NSObject {
    
    // MARK: - 单例
    static let shared = CalendarSystemManager()
    
    private let eventStore = EKEventStore()
    private let operationQueue = DispatchQueue(label: "com.calendar.operation", qos: .userInitiated)

    private let monitor = CalendarEventMonitor()
    
    private override init() {
        super.init()
        self.monitor.onEventsChanged = { [weak self] in
            CalendarVisibilityManager.shared.resolveVisibleCalendars()
            self?.notifyDelegates()
        }
        
        /// 用户操作日历可见性改变
        CalendarVisibilityManager.shared.onVisibilityChanged = { [weak self] in
            self?.notifyDelegates()
        }
        
        self.requestAccess { [weak self] granted in
            if granted {
                self?.notifyDelegates()
            }
        }
    }
    
    func notifyDelegates() {
        notifyDelegates { (delegate: CalendarSystemManagerDelegate) in
            delegate.calendarSystemManagerDidUpdate(self)
        }
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
    /// 根据设置获取
    func fetchVisibleCalendars(completion: @escaping ([EKCalendar]) -> Void) {
        fetchCalendars { result in
            guard case .success(let calendars) = result else {
                completion([])
                return
            }
            
            let visibleCalendars = CalendarVisibilityManager.shared.resolveVisibleCalendars(from: calendars)
            completion(visibleCalendars)
        }
    }
    
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
            let sortedCalendars = calendars.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }

            DispatchQueue.main.async {
                completion(.success(sortedCalendars))
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
    
    /// 根据设置获取可见日历特定日期范围内的事项
    func fetchVisbleCalendarEvents(from startDate: Date,
                                   to endDate: Date,
                                   completion: @escaping ([EKEvent]) -> Void) {
        fetchVisibleCalendars { [weak self] calendars in
            guard let self = self else {
                completion([])
                return
            }
            
            self.fetchEvents(from: startDate,
                        to: endDate,
                        calendars: calendars) { result in
                guard case .success(let events) = result else {
                    completion([])
                    return
                }
                
                completion(events)
            }
        }
    }
        
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
                     span: EKSpan,
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
                try self.eventStore.save(event, span: span)
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

extension CalendarSystemManager: EKEventEditViewDelegate {
    
    func editEvent(_ event: EKEvent) {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        presentEditViewController(for: event, on: topVC)
    }
    
    // 创建新事件（可选设置默认值）
    func createNewEvent(with dateInfo: TaskDateInfo) {
        guard let topVC = UIViewController.topPresented else {
            return
        }
        
        // 预设默认值
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.isAllDay = dateInfo.isAllDay
        newEvent.startDate = dateInfo.startDate
        newEvent.endDate = dateInfo.endDate
        presentEditViewController(for: newEvent, on: topVC)
    }
    
    func presentEditViewController(for event: EKEvent,
                                   on viewController: UIViewController) {
        let editViewController = EKEventEditViewController()
        editViewController.event = event  // 传入要编辑的事件
        editViewController.eventStore = eventStore
        editViewController.editViewDelegate = self
        viewController.present(editViewController, animated: true)
    }
    
    
    // MARK: - EKEventEditViewDelegate
    
    func eventEditViewController(_ controller: EKEventEditViewController,
                                  didCompleteWith action: EKEventEditViewAction) {
        switch action {
        case .saved:
            debugPrint("事件保存成功")
        case .canceled:
            debugPrint("用户取消编辑")
        case .deleted:
            debugPrint("事件已删除")
        @unknown default:
            break
        }
        
        controller.dismiss(animated: true)
    }
}

// MARK: - 更新/删除确认管理模块
extension CalendarSystemManager {
    
    /// 删除事件类型
    enum UpdateEventType {
        case normal          // 普通事件
        case recurring       // 重复事件
    }
    
    /// 重复事件删除选项
    enum RecurringUpdateOption {
        case thisEvent       // 仅删除此事件
        case futureEvents    // 删除所有未来事件
    }
    
    /// 判断事件的删除类型
    private func determineUpdateType(for event: EKEvent) -> UpdateEventType {
        if event.hasRecurrenceRules || event.isDetached {
            return .recurring
        }
        return .normal
    }
    
    // MARK: - 更新确认
    
    /// 执行带确认的更新操作
    func updateEventWithConfirmation(
        _ event: EKEvent,
        with dateRange: DateInterval,
        completion: @escaping (CalendarManagerResult<Void>) -> Void
    ) {
        showUpdateConfirmation(for: event) { [weak self] confirmed, updateOption in
            guard let self = self, confirmed else {
                return
            }
            
            let span: EKSpan = updateOption == .futureEvents ? .futureEvents : .thisEvent
            event.startDate = dateRange.start
            event.endDate = dateRange.end
            self.updateEvent(event, span: span, completion: completion)
        }
    }
    
    func updateEventWithConfirmation(
        _ event: EKEvent,
        with dateInfo: TaskDateInfo,
        completion: @escaping (CalendarManagerResult<Void>) -> Void
    ) {
        showUpdateConfirmation(for: event) { [weak self] confirmed, updateOption in
            guard let self = self, confirmed else {
                return
            }
            
            let span: EKSpan = updateOption == .futureEvents ? .futureEvents : .thisEvent
            event.startDate = dateInfo.startDate
            event.endDate = dateInfo.endDate
            event.isAllDay = dateInfo.isAllDay
            self.updateEvent(event, span: span, completion: completion)
        }
    }
    
    func showUpdateConfirmation(for event: EKEvent,
                                completion: @escaping (Bool, RecurringUpdateOption?) -> Void) {
        let updateType = determineUpdateType(for: event)
        switch updateType {
        case .normal:
            completion(true, .thisEvent)
        case .recurring:
            showRecurringUpdateAlert(
                event: event,
                completion: completion
            )
        }
    }
    
    private func showRecurringUpdateAlert(
        event: EKEvent,
        completion: @escaping (Bool, RecurringUpdateOption?) -> Void
    ) {
        let title = resGetString("Update Repeating Event")
        let message = resGetString("This is a repeating event")
        let updateThisAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Update This Event Only"),
                                         handleBeforeDismiss: false) { _ in
            completion(true, .thisEvent)
        }
        
        let updateFutureAction = TPAlertAction(type: .destructive,
                                               title: resGetString("Update All Future Events"),
                                               handleBeforeDismiss: false) { _ in
            completion(true, .futureEvents)
        }
        
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"),
                                         handleBeforeDismiss: false) { _ in
            completion(false, nil)
        }
        
        let alertController = TPAlertController(title: title,
                                                message: message,
                                                style: .actionSheet,
                                                actions: [updateThisAction,
                                                          updateFutureAction,
                                                          cancelAction])
        alertController.show()
    }
    
    
    // MARK: - 删除确认
    /// 执行带确认的删除操作
    /// - Parameters:
    ///   - event: 要删除的事件
    ///   - completion: 完成回调
    func deleteEventWithConfirmation(
        _ event: EKEvent,
        completion: @escaping (CalendarManagerResult<Void>) -> Void
    ) {
        showDeleteConfirmation(for: event) { [weak self] confirmed, deleteOption in
            guard let self = self, confirmed else {
                return
            }
            
            let span: EKSpan = deleteOption == .futureEvents ? .futureEvents : .thisEvent
            self.deleteEvent(event, span: span, completion: completion)
        }
    }
    
    /// 显示删除确认弹窗
    /// - Parameters:
    ///   - event: 要删除的事件
    ///   - completion: 完成回调，返回用户的选择结果
    func showDeleteConfirmation(
        for event: EKEvent,
        completion: @escaping (Bool, RecurringUpdateOption?) -> Void
    ) {
        let deleteType = determineUpdateType(for: event)
        
        switch deleteType {
        case .normal:
            showNormalDeleteAlert(
                event: event,
                completion: completion
            )
            
        case .recurring:
            showRecurringDeleteAlert(
                event: event,
                completion: completion
            )
        }
    }
    
    // MARK: - 普通事件删除弹窗
    
    /// 显示普通事件删除确认
    private func showNormalDeleteAlert(
        event: EKEvent,
        completion: @escaping (Bool, RecurringUpdateOption?) -> Void
    ) {
        let title = resGetString("Delete Event")
        let message = resGetString("Are you sure you want to delete this event?")
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"),
                                         handleBeforeDismiss: false) { _ in
            completion(false, nil)
        }
        
        let deleteAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete"),
                                         handleBeforeDismiss: false) { _ in
            completion(true, nil)
        }
        
        let alertController = TPAlertController(title: title,
                                                message: message,
                                                style: .actionSheet,
                                                actions: [deleteAction, cancelAction])
        alertController.show()
    }
    
    // MARK: - 重复事件删除弹窗
    
    /// 显示重复事件删除确认
    private func showRecurringDeleteAlert(
        event: EKEvent,
        completion: @escaping (Bool, RecurringUpdateOption?) -> Void
    ) {
    
        let title = resGetString("Delete Repeating Event")
        var message = resGetString("Are you sure you want to delete this event?")
        message += resGetString("This is a repeating event")
        
        // 仅删除此事件
        let deleteThisAction = TPAlertAction(type: .destructive,
                                         title: resGetString("Delete This Event Only"),
                                         handleBeforeDismiss: false) { _ in
            completion(true, .thisEvent)
        }
        
        // 删除所有未来事件
        let deleteFutureAction = TPAlertAction(type: .destructive,
                                               title: resGetString("Delete All Future Events"),
                                               handleBeforeDismiss: false) { _ in
            completion(true, .futureEvents)
        }
        
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"),
                                         handleBeforeDismiss: false) { _ in
            completion(false, nil)
        }
        
        let alertController = TPAlertController(title: title,
                                                message: message,
                                                style: .actionSheet,
                                                actions: [deleteThisAction,
                                                          deleteFutureAction,
                                                          cancelAction])
        alertController.show()
    }
}
