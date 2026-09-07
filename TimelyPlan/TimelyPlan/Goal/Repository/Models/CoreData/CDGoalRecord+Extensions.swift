//
//  CDGoalRecord+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/7.
//

import Foundation
import CoreData

struct GoalRecordKey {
    static let amount = "amount"
    static let date = "date"
    static let note = "note"
    static let taskIdentifier = "task.identifier"
}

extension CDGoalRecord {
    
    /// 创建一条记录
    /// - Parameters:
    ///   - amount: 记录数目
    ///   - date: 记录日期
    ///   - note: 备注
    ///   - task: 所属目标任务（CoreData对象）
    static func newRecord(amount: Int64,
                          date: Date,
                          note: String? = nil,
                          task: CDGoalTask? = nil) -> CDGoalRecord {
        let record = CDGoalRecord.createEntity(in: .defaultContext)
        record.amount = amount
        record.date = date
        record.note = note
        
        if let task = task {
            task.addToRecords(record)
        }
        
        return record
    }
    
    /// 为目标任务添加一条记录
    @discardableResult
    static func addRecord(amount: Int64,
                          date: Date,
                          note: String? = nil,
                          for task: GoalTask) -> CDGoalRecord? {
        guard let cdTask = CDGoalTask.getGoalTask(withIdentifier: task.identifier) else {
            return nil
        }
        
        return newRecord(amount: amount, date: date, note: note, task: cdTask)
    }
    
    // MARK: - 更新
    /// 更新记录的数目与备注
    func update(amount newAmount: Int64? = nil, note newNote: String? = nil) {
        if let newAmount = newAmount {
            self.amount = newAmount
        }
        
        if let newNote = newNote {
            self.note = newNote
        }
    }
}

// MARK: - 获取记录
extension CDGoalRecord {
    
    /// 目标任务条件
    static func recordCondition(for task: GoalTask?) -> PredicateCondition? {
        guard let task = task else {
            return nil
        }
        
        return (GoalRecordKey.taskIdentifier, .equal(task.identifier))
    }
    
    /// 日期区间条件
    static func recordConditions(fromDate: Date? = nil, toDate: Date? = nil) -> [PredicateCondition] {
        var conditions = [PredicateCondition]()
        if let fromDate = fromDate {
            conditions.append((GoalRecordKey.date, .greaterThanOrEqual(fromDate)))
        }
        
        if let toDate = toDate {
            conditions.append((GoalRecordKey.date, .lessThanOrEqual(toDate)))
        }
        
        return conditions
    }
    
    /// 同步获取记录
    static func getRecords(for task: GoalTask? = nil,
                           fromDate: Date? = nil,
                           toDate: Date? = nil) -> [CDGoalRecord]? {
        var conditions = recordConditions(fromDate: fromDate, toDate: toDate)
        if let taskCondition = recordCondition(for: task) {
            conditions.append(taskCondition)
        }
        
        let predicate = conditions.andPredicate()
        let results: [CDGoalRecord]? = getAll(matching: predicate,
                                              sortBy: GoalRecordKey.date,
                                              ascending: false,
                                              in: .defaultContext)
        return results
    }
    
    /// 异步获取记录
    static func fetchRecords(for task: GoalTask? = nil,
                             fromDate: Date? = nil,
                             toDate: Date? = nil,
                             completion: @escaping ([CDGoalRecord]?) -> Void) {
        var conditions = recordConditions(fromDate: fromDate, toDate: toDate)
        if let taskCondition = recordCondition(for: task) {
            conditions.append(taskCondition)
        }
        
        let predicate = conditions.andPredicate()
        fetchAll(matching: predicate,
                 sortBy: GoalRecordKey.date,
                 ascending: false) { results in
            completion(results as? [CDGoalRecord])
        }
    }
}

// MARK: - 删除记录
extension CDGoalRecord {
    
    /// 删除指定记录
    @discardableResult
    static func deleteRecords(_ records: [CDGoalRecord]) -> Bool {
        guard records.count > 0 else {
            return false
        }
        
        NSManagedObjectContext.defaultContext.deleteObjects(records)
        return true
    }
    
    /// 删除目标任务在指定日期区间内的记录
    @discardableResult
    static func deleteRecords(for task: GoalTask? = nil,
                              fromDate: Date? = nil,
                              toDate: Date? = nil) -> Bool {
        guard let records = getRecords(for: task, fromDate: fromDate, toDate: toDate),
              records.count > 0 else {
            return false
        }
        
        return deleteRecords(records)
    }
}

extension Array where Element == CDGoalRecord {
    
    /// 转换成目标记录模型数组
    var toGoalRecords: [GoalRecord] {
        return self.map { GoalRecord(content: $0) }
    }
}
