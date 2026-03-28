//
//  CDFocusSession+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/23.
//

import Foundation

struct FocusSessionKey {
    static let identifier = "identifier"
    static let timerType = "timerType"
    static let timerID = "timerID"
    static let taskType = "taskType"
    static let taskID = "taskID"
    static let startDate = "startDate"
    static let endDate = "endDate"
    static let duration = "duration"
}

// MARK: - Predicate
extension CDFocusSession {
    
    // MARK: - Conditions
    /// 获取任务对应的条件数组
    static func taskConditions(for task: TaskRepresentable) -> [PredicateCondition] {
        let feature = task.feature
        let conditions: [PredicateCondition] = [
            (FocusSessionKey.taskType, .equal(feature.type.rawValue)),
            (FocusSessionKey.taskID, .equal(feature.identifier))
        ]
        
        return conditions
    }
    
    static func timerCondition(for timer: FocusTimer) -> PredicateCondition? {
        return (FocusSessionKey.timerID, .equal(timer.identifier))
    }
    
    static func excludeArchivedTimersCondition() -> PredicateCondition? {
        guard let identifiers = CDFocusTimer.getArchivedTimers()?.identifiers else {
            return nil
        }
        
        return (FocusSessionKey.timerID, .notBelongsTo(identifiers))
    }
    
    /// 获取开始日期在特定范围内的条件
    static func startDateCondition(fromDate: Date?, toDate: Date?) -> PredicateCondition? {
        if let fromDate = fromDate, let toDate = toDate {
            return (FocusSessionKey.startDate, .between(fromDate, toDate))
        } else if let fromDate = fromDate {
            return (FocusSessionKey.startDate, .greaterThanOrEqual(fromDate))
        } else if let toDate = toDate {
            return (FocusSessionKey.startDate, .lessThanOrEqual(toDate))
        } else {
            return nil
        }
    }
    
    // MARK: - Predicate
    /// 特定任务在日期范围内所有会话
    static func predicate(forTask task: TaskRepresentable? = nil,
                          timer: FocusTimer? = nil,
                          fromDate: Date?,
                          toDate: Date?,
                          includeArchivedTimer: Bool) -> NSPredicate {
        var conditions = [PredicateCondition]()
        if let task = task {
            conditions.append(contentsOf: taskConditions(for: task))
        }
        
        if let timer = timer, let condition = timerCondition(for: timer) {
            conditions.append(condition)
        }
        
        if let startDateCondition = startDateCondition(fromDate: fromDate, toDate: toDate) {
            conditions.append(startDateCondition)
        }
        
        if !includeArchivedTimer {
            if let condition = excludeArchivedTimersCondition() {
                conditions.append(condition)
            }
        }
        
        let predicate = conditions.andPredicate()
        return predicate
    }
    
    
}

extension CDFocusSession {
    // MARK: - 获取会话
    /// 异步获取任务在特定时间区间所有会话数组
    static func fetchSessions(forTask task: TaskRepresentable? = nil,
                              timer: FocusTimer? = nil,
                              fromDate: Date,
                              toDate: Date,
                              includeArchivedTimer: Bool,
                              completion: @escaping([CDFocusSession]?) -> Void) {
        let predicate = predicate(forTask: task,
                                  timer: timer,
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  includeArchivedTimer: includeArchivedTimer)
        findAll(with: predicate) { results in
            completion(results as? [CDFocusSession])
        }
    }
    
    static func fetchSessions(forTask task: TaskRepresentable? = nil,
                              timer: FocusTimer? = nil,
                              dateRange: DateRange,
                              includeArchivedTimer: Bool,
                              completion: @escaping([CDFocusSession]?) -> Void) {
        guard let fromDate = dateRange.startDate, let toDate = dateRange.endDate else {
            completion(nil)
            return
        }
        
        fetchSessions(forTask: task,
                      timer: timer,
                      fromDate: fromDate,
                      toDate: toDate,
                      includeArchivedTimer: includeArchivedTimer,
                      completion: completion)
    }
    
    /// 获取按开始日期排序的专注会话
    static func fetchSessionsSortedByStartDate(forTask task: TaskRepresentable? = nil,
                                               timer: FocusTimer? = nil,
                                               fromDate: Date,
                                               toDate: Date,
                                               includeArchivedTimer: Bool,
                                               completion: @escaping([CDFocusSession]?) -> Void) {
        let predicate = predicate(forTask: task,
                                  timer: timer,
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  includeArchivedTimer: includeArchivedTimer)
        findAll(with: predicate, sortedBy: FocusSessionKey.startDate, ascending: true) { results in
            completion(results as? [CDFocusSession])
        }
    }
    
    /// 异步获取日期当日所有专注会话
    static func fetchSessions(for date: Date, includeArchivedTimer: Bool, completion: @escaping([CDFocusSession]?) -> Void) {
        let dateRange = date.rangeOfThisDay()
        fetchSessions(forTask: nil,
                      timer: nil,
                      dateRange: dateRange,
                      includeArchivedTimer: includeArchivedTimer,
                      completion: completion)
    }
    
    /// 获取特定标识对应的专注会话
    static func getSession(withIdentifier identifier: String) -> CDFocusSession? {
        let condition: PredicateCondition = (FocusSessionKey.identifier, .equal(identifier))
        let predicate = NSPredicate.predicate(with: condition)
        return findFirst(withPredicate: predicate, in: .defaultContext)
    }
    
    /// 获取任务使用计时器在特定日期专注时长
    static func getSessionDuration(forTask task: TaskRepresentable? = nil,
                                   timer: FocusTimer? = nil,
                                   on date: Date) -> Int64 {
        let fromDate = date.startOfDay()
        let toDate = date.endOfDay()
        let predicate = predicate(forTask: task,
                                  timer: timer,
                                  fromDate: fromDate,
                                  toDate: toDate,
                                  includeArchivedTimer: true)
        return totalDuration(with: predicate)
    }
    
    /// 获取计时器总专注时间
    static func getTotalDuration(for timer: FocusTimer? = nil) -> Int64 {
        let predicate = predicate(forTask: nil,
                                  timer: timer,
                                  fromDate: nil,
                                  toDate: nil,
                                  includeArchivedTimer: true)
        return totalDuration(with: predicate)
    }
    
    
    private static func totalDuration(with predicate: NSPredicate) -> Int64 {
        let duration = performAggregateOperation(function: .sum,
                                                 onAttribute: FocusSessionKey.duration,
                                                 withPredicate: predicate,
                                                 in: .defaultContext) as? Int64
        return duration ?? 0
    }
    
    /// 异步获取总专注时长
    static func fetchDuration(forTask task: TaskRepresentable? = nil,
                              timer: FocusTimer? = nil,
                              completion: @escaping(Int64) -> Void) {
        let predicate = predicate(forTask: task,
                                  timer: timer,
                                  fromDate: nil,
                                  toDate: nil,
                                  includeArchivedTimer: true)
        performAggregateOperation(function: .sum,
                                  onAttribute: FocusSessionKey.duration,
                                  withPredicate: predicate) { result in
            let duration = result as? Int64 ?? 0
            completion(duration)
        }
    }
}

// MARK: - 更新绑定的计时器和任务快照信息
extension CDFocusSession {
    
    static func updateTimerFeature(_ feature: TimerFeature,
                                   completion: @escaping(Bool) -> Void) {
        fecthSessions(timerID: feature.identifier) { sessions in
            guard let sessions = sessions, sessions.count > 0 else {
                completion(false)
                return
            }

            for session in sessions {
                session.timerSnapshotColorHex = feature.snapshotColorHex
                session.timerSnapshotName = feature.snapshotName
            }
            
            completion(true)
        }
    }
    
    static func updateTaskFeature(_ feature: TaskFeature,
                                  completion: @escaping(Bool) -> Void) {
        fecthSessions(taskType: feature.type, taskID: feature.identifier) { sessions in
            guard let sessions = sessions, sessions.count > 0 else {
                completion(false)
                return
            }

            for session in sessions {
                session.taskSnapshotName = feature.snapshotName
            }
            
            completion(true)
        }
    }
    
    private static func fecthSessions(timerID: String,
                                      completion: @escaping([CDFocusSession]?) -> Void) {
        let condition: PredicateCondition = (FocusSessionKey.timerID, .equal(timerID))
        let predicate = NSPredicate.predicate(with: condition)
        findAll(with: predicate) { results in
            completion(results as? [CDFocusSession])
        }
    }
    
    private static func fecthSessions(taskType: TaskType,
                                      taskID: String,
                                      completion: @escaping([CDFocusSession]?) -> Void) {
        let conditions: [PredicateCondition] = [(FocusSessionKey.taskType, .equal(taskType.rawValue)),
                                                (FocusSessionKey.taskID, .equal(taskID))]
        let predicate = conditions.andPredicate()
        findAll(with: predicate) { results in
            completion(results as? [CDFocusSession])
        }
    }
}


// MARK: - 编辑
extension CDFocusSession {
    
    /// 创建新记录
    static func newSession(with record: FocusRecord, isManual: Bool) -> CDFocusSession {
        let session = CDFocusSession.createEntity(in: .defaultContext)
        session.identifier = UUID().uuidString
        session.isManual = isManual
        session.update(with: record)
        return session
    }

    /// 根据记录更新会话
    func update(with record: FocusRecord) {
        if let feature = record.timerFeature {
            self.timerID = feature.identifier
            self.timerSnapshotName = feature.snapshotName
            self.timerSnapshotColorHex = feature.snapshotColorHex
        }
        
        if let feature = record.taskFeature {
            self.taskType = Int64(feature.type.rawValue)
            self.taskID = feature.identifier
            self.taskSnapshotName = feature.snapshotName
        }
        
        let timeline = record.timeline
        self.startDate = timeline.startDate
        self.endDate = timeline.endDate
        self.duration = Int64(timeline.focusInterval)
        self.score = Int64(record.score)
        self.note = record.note
        
        // 设置暂停信息
        if let pauseFragments = timeline.pauseTimeFragments {
            let pauseInfo = FocusPauseInfo(pauseFragments: pauseFragments)
            self.pauseInfoJSON = pauseInfo.jsonString()
        } else {
            self.pauseInfoJSON = nil
        }
    }
}

extension Array where Element == CDFocusSession {
    
    var sessions: [FocusSession] {
        return self.map { FocusSession(content: $0) }
    }
}
