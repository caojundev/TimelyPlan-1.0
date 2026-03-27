//
//  FocusSessionManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/23.
//

import Foundation
import CoreData

class FocusSessionManager {
    
    /// 数据更新器
    let updater = FocusSessionProcessorUpdater()
    
    private func createSession(with record: FocusRecord, isManual: Bool) -> FocusSession {
        let content = CDFocusSession.newSession(with: record, isManual: isManual)
        let session = FocusSession(content: content)
        return session
    }
    
    private func save(with completion: (() -> Void)?) {
        HandyRecord.save { success, error in
            completion?()
        }
    }
    
    // MARK: - 处理会话
    func addSessions(with records: [FocusRecord]) {
        var sessions = [FocusSession]()
        for record in records {
            let session = createSession(with: record, isManual: false)
            sessions.append(session)
        }
        
        if sessions.count > 0 {
            save { [weak self] in
                self?.updater.didAddFocusSessions(sessions)
            }
        }
    }
    
    /// 手动添加会话
    func addSession(with record: FocusRecord, isManual: Bool) {
        let session = createSession(with: record, isManual: isManual)
        save { [weak self] in
            self?.updater.didAddFocusSessions([session])
        }
    }
    
    /// 删除会话
    func deleteSession(_ session: FocusSession) {
        if let content = CDFocusSession.getSession(withIdentifier: session.identifier) {
            NSManagedObjectContext.defaultContext.delete(content)
            save { [weak self] in
                self?.updater.didDeleteFocusSession(session)
            }
        }
    }
    
    /// 更新会话
    func updateSession(_ session: FocusSession, with record: FocusRecord) {
        guard !session.isSameAs(record) else {
            return
        }
        
        if let content = CDFocusSession.getSession(withIdentifier: session.identifier) {
            content.update(with: record)
            save { [weak self] in
                self?.updater.didUpdateFocusSession(session)
            }
        }
    }
    
    // MARK: - 获取会话
    /// 异步获取任务在特定时间区间所有会话数组
    func fetchSessions(forTask task: TaskRepresentable? = nil,
                       timer: FocusTimer? = nil,
                       fromDate: Date,
                       toDate: Date,
                       includeArchivedTimer: Bool,
                       completion: @escaping([FocusSession]?) -> Void) {
        CDFocusSession.fetchSessions(forTask: task,
                                     timer: timer,
                                     fromDate: fromDate,
                                     toDate: toDate,
                                     includeArchivedTimer: includeArchivedTimer) { results in
            completion(results?.sessions)
        }
    }
    
    func fetchSessions(forTask task: TaskRepresentable? = nil,
                       timer: FocusTimer? = nil,
                       dateRange: DateRange,
                       includeArchivedTimer: Bool,
                       completion: @escaping([FocusSession]?) -> Void) {
        CDFocusSession.fetchSessions(forTask: task,
                                     timer: timer,
                                     dateRange: dateRange,
                                     includeArchivedTimer: includeArchivedTimer) { results in
            completion(results?.sessions)
        }
    }
    
    /// 获取按日分组的专注会话字典
    func fetchSessionsGroupedByDay(forTask task: TaskRepresentable? = nil,
                                    timer: FocusTimer? = nil,
                                    within dateRange: DateRange,
                                   includeArchivedTimer: Bool,
                                    completion: @escaping ([Int32: [FocusSession]]?) -> Void) {
        guard let fromDate = dateRange.startDate, let toDate = dateRange.endDate else {
            completion(nil)
            return
        }
    
        fetchSessionsSortedByStartDate(forTask: task,
                                       timer: timer,
                                       fromDate: fromDate,
                                       toDate: toDate,
                                       includeArchivedTimer: includeArchivedTimer) { sessions in
            guard let sessions = sessions, sessions.count > 0 else {
                completion(nil)
                return
            }

            var results = [Int32: [FocusSession]]()
            for session in sessions {
                guard let key = session.startDate?.dayIntegerKey else {
                    continue
                }
                
                var daySessions = results[key] ?? []
                daySessions.append(session)
                results[key] = daySessions
            }
        
            completion(results)
        }
    }
    
    /// 获取按开始日期排序的专注会话
    private func fetchSessionsSortedByStartDate(forTask task: TaskRepresentable? = nil,
                                                timer: FocusTimer? = nil,
                                                fromDate: Date,
                                                toDate: Date,
                                                includeArchivedTimer: Bool,
                                                completion: @escaping([FocusSession]?) -> Void) {
        CDFocusSession.fetchSessionsSortedByStartDate(forTask: task,
                                                      timer: timer,
                                                      fromDate: fromDate,
                                                      toDate: toDate,
                                                      includeArchivedTimer: includeArchivedTimer) { results in
            completion(results?.sessions)
        }
    }

    /// 异步获取日期当日所有专注会话
    func fetchSessions(for date: Date,
                       includeArchivedTimer: Bool,
                       completion: @escaping([FocusSession]?) -> Void) {
        let dateRange = date.rangeOfThisDay()
        fetchSessions(forTask: nil,
                      timer: nil,
                      dateRange: dateRange,
                      includeArchivedTimer: includeArchivedTimer,
                      completion: completion)
    }
    
    /// 获取任务使用计时器在特定日期专注时长
    func getSessionDuration(forTask task: TaskRepresentable? = nil,
                            timer: FocusTimer? = nil,
                            on date: Date) -> Int64 {
        return CDFocusSession.getSessionDuration(forTask: task, timer: timer, on: date)
    }
    
    /// 获取计时器总专注时间
    func getTotalDuration(for timer: FocusTimer? = nil) -> Int64 {
        return CDFocusSession.getTotalDuration(for: timer)
    }
    
    func fetchDuration(forTask task: TaskRepresentable? = nil,
                       timer: FocusTimer? = nil,
                       completion: @escaping(Int64) -> Void) {
        CDFocusSession.fetchDuration(forTask: task, timer: timer, completion: completion)
    }
}
