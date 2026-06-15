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

class FocusRepository {
    
    // MARK: - 单例
    static let shared = FocusRepository()
    
    private init() {}
    
    // MARK: - 私有管理器
    /// 系统计时器管理器
    private static let systemTimerManager = FocusSystemTimerManager()
    
    /// 用户计时器管理器
    private static let userTimerManager = FocusUserTimerManager()
    
    /// 会话管理器
    private static let sessionManager = FocusSessionManager()
    
    // MARK: - 添加处理更新器
    /// 添加更新器代理对象
    static func addUpdater(_ updater: AnyObject, for option: FocusUpdaterOption = .all) {
        if option.contains(.timer) {
            userTimerManager.updater.addDelegate(updater)
        }
        
        if option.contains(.session) {
            sessionManager.updater.addDelegate(updater)
        }
    }
    
    // MARK: - 默认计时器
    /// 所有默认计时器
    static func allDefaultTimers() -> [FocusSystemTimer] {
        return systemTimerManager.allTimers
    }
    
    /// 默认计时器
    static func defaultTimer() -> FocusSystemTimer {
        return systemTimerManager.defaultTimer
    }
    
    // MARK: - 获取用户计时器
    static func fetchActiveTimers(completion: @escaping([FocusTimer]?) -> Void) {
        userTimerManager.fetchActiveTimers(completion: completion)
    }
    
    static func fetchArchivedTimers(completion: @escaping([FocusTimer]?) -> Void) {
        userTimerManager.fetchArchivedTimers(completion: completion)
    }
    
    /// 获取所有活动计时器
    static func getActiveTimers() -> [FocusTimer]? {
        return userTimerManager.getActiveTimers()
    }

    /// 获取所有已归档计时器
    static func getArchivedTimers() -> [FocusTimer]? {
        return userTimerManager.getArchivedTimers()
    }
    
    /// 获取归档计时器数目
    static func numberOfArchivedTimers() -> Int {
        return userTimerManager.numberOfArchivedTimers()
    }
    
    static func getTimer(withFeature feature: TimerFeature) -> FocusTimerRepresentable? {
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
    static func searchActiveTimers(containText text: String, completion:(@escaping([FocusTimer]?) -> Void)) {
        userTimerManager.searchActiveTimers(containText: text, completion: completion)
    }
    
    // MARK: - 处理用户计时器
    static func createTimer(with editingTimer: FocusEditingTimer) {
        userTimerManager.createTimer(with: editingTimer)
    }

    static func createTimer(with editingTimer: FocusEditingTimer, in timers: [FocusTimer]?) {
        userTimerManager.createTimer(with: editingTimer, in: timers)
    }
    
    static func updateTimer(_ timer: FocusTimer, with editingTimer: FocusEditingTimer) {
        let oldFeature = timer.feature
        let newTimer = userTimerManager.updateTimer(timer, with: editingTimer)
        guard let newTimer = newTimer else {
            return
        }
        
        if let newFeature = newTimer.feature, oldFeature != newFeature {
           updateSession(with: newFeature)
        }
    }
    
    static func setArchived(_ isArchived: Bool, for timer: FocusTimer) {
        userTimerManager.setArchived(isArchived, for: timer)
    }
        
    static func deleteTimer(_ timer: FocusTimer) {
        userTimerManager.deleteTimer(timer)
    }
    
    static func reorderTimer(in timers: [FocusTimer], fromIndex: Int, toIndex: Int) {
        userTimerManager.reorderTimer(in: timers, fromIndex: fromIndex, toIndex: toIndex)
    }
    
    static func moveTimer(_ timer: FocusTimer, in timers: [FocusTimer], toTop: Bool = true) {
        userTimerManager.moveTimer(timer, in: timers, toTop: toTop)
    }
    
    // MARK: - 获取会话
    static func fetchDuration(forTask task: TaskRepresentable? = nil,
                       timer: FocusTimer? = nil,
                       completion: @escaping(Int64) -> Void) {
        sessionManager.fetchDuration(forTask: task, timer: timer, completion: completion)
    }
    
    static func getTotalDuration(for timer: FocusTimer? = nil) -> Int64 {
        return sessionManager.getTotalDuration(for: timer)
    }
    
    /// 异步获取日期当日所有专注会话
    static func fetchSessions(for date: Date, includeArchivedTimer: Bool, completion: @escaping([FocusSession]?) -> Void) {
        sessionManager.fetchSessions(for: date,
                                        includeArchivedTimer: includeArchivedTimer,
                                        completion: completion)
    }
    
    static func fetchSessions(forTask task: TaskRepresentable? = nil,
                       timer: FocusTimer? = nil,
                       dateRange: DateRange,
                       includeArchivedTimer: Bool,
                       completion: @escaping([FocusSession]?) -> Void) {
        sessionManager.fetchSessions(forTask: task,
                                     timer: timer,
                                     dateRange: dateRange,
                                     includeArchivedTimer: includeArchivedTimer,
                                     completion: completion)
    }
        
    
    /// 获取按日分组的专注会话字典
    static func fetchSessionsGroupedByDay(forTask task: TaskRepresentable? = nil,
                                   timer: FocusTimer? = nil,
                                   within dateRange: DateRange,
                                   includeArchivedTimer: Bool = true,
                                   completion: @escaping ([Int32: [FocusSession]]?) -> Void) {
        sessionManager.fetchSessionsGroupedByDay(forTask: task,
                                                 timer: timer,
                                                 within: dateRange,
                                                 includeArchivedTimer: includeArchivedTimer,
                                                 completion: completion)
    }
    
    
    // MARK: - 处理会话
    static func addSessions(with records: [FocusRecord]) {
        sessionManager.addSessions(with: records)
    }
    
    /// 手动添加会话
    static func addSession(with record: FocusRecord, isManual: Bool) {
        sessionManager.addSession(with: record, isManual: isManual)
    }
    
    /// 删除会话
    static func deleteSession(_ session: FocusSession) {
        sessionManager.deleteSession(session)
    }
    
    /// 更新会话
    static func updateSession(_ session: FocusSession, with record: FocusRecord) {
        sessionManager.updateSession(session, with: record)
    }
    
    static func updateSession(with feature: TimerFeature) {
        sessionManager.updateSession(with: feature)
    }
    
    static func updateSession(with feature: TaskFeature) {
        sessionManager.updateSession(with: feature)
    }
}

// MARK: - 统计数据
extension FocusRepository {
    
    // MARK: - 获取特定任务统计数据
    /// 获取日统计数据
    static func fetchDailyStats(forTask task: TaskRepresentable? = nil,
                         timer: FocusTimer? = nil,
                         on date: Date,
                         includeArchivedTimer: Bool,
                         completion: @escaping(FocusStatsDataItem) -> Void) {
        let dateRange = date.rangeOfThisDay()
        fetchStats(forTask: task,
                   timer: timer,
                   dateRange: dateRange,
                   includeArchivedTimer: includeArchivedTimer,
                   completion: completion)
    }
    
    /// 获取周统计数据
    static func fetchWeeklyStats(forTask task: TaskRepresentable? = nil,
                          timer: FocusTimer? = nil,
                          inWeekContaining date: Date,
                          firstWeekday: Weekday = .firstWeekday,
                          includeArchivedTimer: Bool,
                          completion: @escaping(FocusStatsDataItem) -> Void) {
        let dateRange = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        fetchStats(forTask: task,
                   timer: timer,
                   dateRange: dateRange,
                   includeArchivedTimer: includeArchivedTimer,
                   completion: completion)
    }
    
    /// 获取月统计数据
    static func fetchMonthlyStats(forTask task: TaskRepresentable? = nil,
                           timer: FocusTimer? = nil,
                           inMonthContaining date: Date,
                           includeArchivedTimer: Bool,
                           completion: @escaping(FocusStatsDataItem) -> Void) {
        let dateRange = date.rangeOfThisMonth()
        fetchStats(forTask: task,
                   timer: timer,
                   dateRange: dateRange,
                   includeArchivedTimer: includeArchivedTimer,
                   completion: completion)
    }
    
    /// 获取年数据
    static func fetchYearlyStats(forTask task: TaskRepresentable? = nil,
                          timer: FocusTimer? = nil,
                          inYearContaining date: Date,
                          includeArchivedTimer: Bool,
                          completion: @escaping(FocusStatsDataItem) -> Void) {
        let dateRange = date.rangeOfThisYear()
        fetchStats(forTask: task,
                   timer: timer,
                   dateRange: dateRange,
                   includeArchivedTimer: includeArchivedTimer,
                   completion: completion)
    }
    
    private static func fetchStats(forTask task: TaskRepresentable? = nil,
                            timer: FocusTimer? = nil,
                            dateRange: DateRange,
                            includeArchivedTimer: Bool,
                            completion: @escaping(FocusStatsDataItem) -> Void) {
        fetchSessions(forTask: task,
                      timer: timer,
                      dateRange: dateRange,
                      includeArchivedTimer: includeArchivedTimer) { sessions in
            let item = FocusStatsDataItem(task: task, timer: timer, dateRange: dateRange, sessions: sessions)
            completion(item)
        }
    }
}
