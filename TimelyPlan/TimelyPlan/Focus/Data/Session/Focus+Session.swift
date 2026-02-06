//
//  Focus+Session.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/22.
//

import Foundation

extension Focus {

    /// 手动添加会话
    func addSession(with record: FocusRecord, isManual: Bool) {
        let session = FocusSession.newSession(with: record, isManual: isManual)
        updater.didAddFocusSession(session, with: record)
        save()
    }
    
    /// 删除会话
    func deleteSession(_ session: FocusSession) {
        context.delete(session)
        updater.didDeleteFocusSession(session)
        save()
    }
    
    /// 更新会话
    func updateSession(_ session: FocusSession, with record: FocusRecord) {
        guard !session.isSameAs(record) else {
            return
        }
        
        session.update(with: record)
        updater.didUpdateFocusSession(session)
        save()
    }
    
    /// 异步获取任务在特定时间区间所有会话数组
    func fetchSessions(forTask task: TaskRepresentable? = nil,
                       timer: FocusTimer? = nil,
                       fromDate: Date,
                       toDate: Date,
                       completion: @escaping([FocusSession]?) -> Void) {
        let predicate = FocusSession.predicate(forTask: task,
                                               timer: timer,
                                               fromDate: fromDate,
                                               toDate: toDate)
        FocusSession.findAll(with: predicate) { results in
            completion(results as? [FocusSession])
        }
    }
    

    func fetchSessions(forTask task: TaskRepresentable? = nil,
                       timer: FocusTimer? = nil,
                       dateRange: DateRange,
                       completion: @escaping([FocusSession]?) -> Void) {
        guard let fromDate = dateRange.startDate, let toDate = dateRange.endDate else {
            completion(nil)
            return
        }
        
        fetchSessions(forTask: task, timer: timer, fromDate: fromDate, toDate: toDate, completion: completion)
    }
    
    /// 获取按开始日期排序的专注会话
    func fetchSessionsSortedByStartDate(forTask task: TaskRepresentable? = nil,
                                        timer: FocusTimer? = nil,
                                        fromDate: Date,
                                        toDate: Date,
                                        completion: @escaping([FocusSession]?) -> Void) {
        let predicate = FocusSession.predicate(forTask: task,
                                               timer: timer,
                                               fromDate: fromDate,
                                               toDate: toDate)
        FocusSession.findAll(with: predicate, sortedBy: FocusSessionKey.startDate, ascending: true) { results in
            completion(results as? [FocusSession])
        }
    }
    
    /// 获取按日分组的专注会话字典
    func fetchSessionsGroupedByDay(forTask task: TaskRepresentable? = nil,
                                    timer: FocusTimer? = nil,
                                    within dateRange: DateRange,
                                    completion: @escaping ([Int32: [FocusSession]]?) -> Void) {
        guard let fromDate = dateRange.startDate, let toDate = dateRange.endDate else {
            completion(nil)
            return
        }
        
        fetchSessionsSortedByStartDate(forTask: task, timer: timer, fromDate: fromDate, toDate: toDate) { sessions in
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
    
    
    /// 获取任务使用计时器在特定日期专注时长
    func getSessionDuration(forTask task: TaskRepresentable? = nil,
                         timer: FocusTimer? = nil,
                         on date: Date) -> Int64 {
        let fromDate = date.startOfDay()
        let toDate = date.endOfDay()
        let predicate = FocusSession.predicate(forTask: task, timer: timer, fromDate: fromDate, toDate: toDate)
        let duration = FocusSession.performAggregateOperation(function: .sum,
                                                              onAttribute: FocusSessionKey.duration,
                                                              withPredicate: predicate,
                                                              in: .defaultContext) as? Int64
        return duration ?? 0
    }
}


