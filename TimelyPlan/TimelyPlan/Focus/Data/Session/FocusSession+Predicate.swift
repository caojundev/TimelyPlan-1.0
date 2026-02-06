//
//  FocusSession+Predicate.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/1.
//

import Foundation

struct FocusSessionKey {
    static let timerType = "timerType"
    static let timerID = "timerID"
    static let taskType = "taskType"
    static let taskID = "taskID"
    static let startDate = "startDate"
    static let endDate = "endDate"
    static let duration = "duration"
}

extension FocusSession {
    
    // MARK: - Conditions
    /// 获取任务对应的条件数组
    static func taskConditions(for task: TaskRepresentable) -> [PredicateCondition] {
        let taskType = task.info.type.rawValue
        let taskID = task.info.identifier
        let conditions: [PredicateCondition] = [
            (FocusSessionKey.taskType, .equal(taskType)),
            (FocusSessionKey.taskID, .equal(taskID))
        ]
        
        return conditions
    }
    
    static func timerCondition(for timer: FocusTimer) -> PredicateCondition? {
        guard let timerID = timer.identifier else {
            return nil
        }
        
        return (FocusSessionKey.timerID, .equal(timerID))
    }
    
    /// 获取开始日期在特定范围内的条件
    static func startDateCondition(fromDate: Date, toDate: Date) -> PredicateCondition {
        return (FocusSessionKey.startDate, .between(fromDate, toDate))
    }
    
    // MARK: - Predicate
    /// 特定任务在日期范围内所有会话
    static func predicate(forTask task: TaskRepresentable? = nil,
                          timer: FocusTimer? = nil,
                          fromDate: Date,
                          toDate: Date) -> NSPredicate {
        var conditions = [PredicateCondition]()
        if let task = task {
            conditions.append(contentsOf: Self.taskConditions(for: task))
        }
        
        if let timer = timer, let condition = timerCondition(for: timer) {
            conditions.append(condition)
        }
        
        let startDateCondition = Self.startDateCondition(fromDate: fromDate, toDate: toDate)
        conditions.append(startDateCondition)
        
        let predicate = conditions.andPredicate()
        return predicate
    }
}

