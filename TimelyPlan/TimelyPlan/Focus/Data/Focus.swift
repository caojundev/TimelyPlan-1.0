//
//  Focus.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/23.
//

import Foundation
import CoreData

struct FocusUpdaterOption: OptionSet {
    
    let rawValue: Int
    
    /// 计时器
    static let timer = FocusUpdaterOption(rawValue: 1 << 1)
    
    /// 会话
    static let session = FocusUpdaterOption(rawValue: 2 << 1)
    
    /// 所有
    static let all: FocusUpdaterOption = [.timer, .session]
}

class Focus {
    
    /// 系统计时器管理器
    private let systemTimerManager = FocusSystemTimerManager()
    
    /// 用户计时器管理器
    private let userTimerManager = FocusUserTimerManager()
    
    /// 会话管理器
    private let sessionManager = FocusSessionManager()
    
    // MARK: - 添加处理更新器
    /// 添加更新器代理对象
    func addUpdater(_ updater: AnyObject, for option: FocusUpdaterOption = .all) {
        if option.contains(.timer) {
            self.userTimerManager.updater.addDelegate(updater)
        }
        
        if option.contains(.session) {
            self.sessionManager.updater.addDelegate(updater)
        }
    }
    
    // MARK: - 默认计时器
    /// 所有默认计时器
    func allDefaultTimers() -> [FocusSystemTimer] {
        return systemTimerManager.allTimers
    }
    
    /// 默认计时器
    func defaultTimer() -> FocusSystemTimer {
        return systemTimerManager.defaultTimer
    }
    
    // MARK: - 获取用户计时器
    /// 获取所有活动计时器
    func getActiveTimers() -> [FocusTimer]? {
        return userTimerManager.getActiveTimers()
    }

    /// 获取所有已归档计时器
    func getArchivedTimers() -> [FocusTimer]? {
        return userTimerManager.getArchivedTimers()
    }
    
    /// 获取归档计时器数目
    func numberOfArchivedTimers() -> Int {
        return userTimerManager.numberOfArchivedTimers()
    }
    
    func getTimer(withFeature feature: TimerFeature) -> FocusTimerRepresentable? {
        if feature.isNone {
            return nil
        }
        
        if feature.isDefaultTimer {
            /// 默认计时器
            return systemTimerManager.timer(of: feature)
        }
        
        /// 用户计时器
        return userTimerManager.getTimer(withFeature: feature)
    }
    
    /// 搜索计时器
    func searchActiveTimers(containText text: String, completion:(@escaping([FocusTimer]?) -> Void)) {
        userTimerManager.searchActiveTimers(containText: text, completion: completion)
    }
    
    // MARK: - 处理用户计时器
    func createTimer(with editingTimer: FocusEditingTimer) {
        userTimerManager.createTimer(with: editingTimer)
    }

    func createTimer(with editingTimer: FocusEditingTimer, in timers: [FocusTimer]?) {
        userTimerManager.createTimer(with: editingTimer, in: timers)
    }
    
    func updateTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        userTimerManager.updateTimer(timer, with: editingTimer)
    }
    
    func setArchived(_ isArchived: Bool, for timer: FocusTimer) {
        userTimerManager.setArchived(isArchived, for: timer)
    }
        
    func deleteTimer(_ timer: FocusTimer) {
        userTimerManager.deleteTimer(timer)
    }
    
    func reorderTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        userTimerManager.reorderTimer(in: timers, fromIndex: fromIndex, toIndex: toIndex)
    }
    
    func moveTimer(_ timer: FocusTimer, in timers: [FocusTimer], toTop: Bool = true) {
        userTimerManager.moveTimer(timer, in: timers, toTop: toTop)
    }
    
    // MARK: - 获取会话
    func getTotalDuration(for timer: FocusTimer? = nil) -> Int64 {
        return sessionManager.getTotalDuration(for: timer)
    }
    
    /// 异步获取日期当日所有专注会话
    func fetchSessions(for date: Date, completion: @escaping([FocusSession]?) -> Void) {
        sessionManager.fetchSessions(for: date, completion: completion)
    }
    
    func fetchSessions(forTask task: TaskRepresentable? = nil,
                       timer: FocusTimer? = nil,
                       dateRange: DateRange,
                       completion: @escaping([FocusSession]?) -> Void) {
        sessionManager.fetchSessions(forTask: task,
                                     timer: timer,
                                     dateRange: dateRange,
                                     completion: completion)
    }
        
    
    /// 获取按日分组的专注会话字典
    func fetchSessionsGroupedByDay(forTask task: TaskRepresentable? = nil,
                                    timer: FocusTimer? = nil,
                                    within dateRange: DateRange,
                                    completion: @escaping ([Int32: [FocusSession]]?) -> Void) {
        sessionManager.fetchSessionsGroupedByDay(forTask: task,
                                                 timer: timer,
                                                 within: dateRange,
                                                 completion: completion)
    }
    
    
    // MARK: - 处理会话
    func addSessions(with records: [FocusRecord]) {
        sessionManager.addSessions(with: records)
    }
    
    /// 手动添加会话
    func addSession(with record: FocusRecord, isManual: Bool) {
        sessionManager.addSession(with: record, isManual: isManual)
    }
    
    /// 删除会话
    func deleteSession(_ session: FocusSession) {
        sessionManager.deleteSession(session)
    }
    
    /// 更新会话
    func updateSession(_ session: FocusSession, with record: FocusRecord) {
        sessionManager.updateSession(session, with: record)
    }
}
