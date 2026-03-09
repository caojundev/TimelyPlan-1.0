//
//  HabitRecordProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/21.
//

import Foundation

class HabitRecordProvider {
    
    // MARK: - 异步获取数据
    
    func fetchRecords(for tasks: [HabitTask],
                      onDate date: Date,
                      completion: @escaping([CDHabitRecord]?) -> Void) {
        let tasks = tasks.map { $0.content }
        let conditions = CDHabitRecord.conditions(forTasks: tasks, onDate: date)
        let predicate = conditions.andPredicate()
        CDHabitRecord.fetchAll(matching: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }

    /// 获取指定日期范围内所有记录
    func fetchRecords(for task: HabitTask,
                      in range: DateRange,
                      completion: @escaping([CDHabitRecord]?) -> Void) {
        guard let fromDate = range.startDate, let toDate = range.endDate else {
            completion(nil)
            return
        }
        
        fetchRecords(for: task,
                     fromDate: fromDate,
                     toDate: toDate,
                     completion: completion)
    }
    
    func fetchRecords(for task: HabitTask,
                      fromDate: Date,
                      toDate: Date,
                      completion: @escaping([CDHabitRecord]?) -> Void) {
        let task = task.content
        let conditions = CDHabitRecord.conditions(forTask: task,
                                                  fromDate: fromDate,
                                                  toDate: toDate)
        let predicate = conditions.andPredicate()
        CDHabitRecord.fetchAll(matching: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }
    
    // MARK: - 同步获取记录
    /// 获取指定日期的记录
    func getRecord(for task: HabitTask, on date: Date) -> CDHabitRecord? {
        return getRecord(for: task, on: date, createIfNil: false)
    }
    
    func getRecord(for task: HabitTask, on date: Date, createIfNil: Bool) -> CDHabitRecord? {
        let task = task.content
        let conditions = CDHabitRecord.conditions(forTask: task, onDate: date)
        let predicate = conditions.andPredicate()
        if let record = CDHabitRecord.findFirst(withPredicate: predicate, in: .defaultContext) {
            return record
        }
        
        if createIfNil {
            return CDHabitRecord.newRecord(forTask: task, onDate: date)
        }
        
        return nil
    }
    
    func getRecords(for task: HabitTask, fromDate: Date, toDate: Date) -> [CDHabitRecord]? {
        let task = task.content
        let conditions = CDHabitRecord.conditions(forTask: task, fromDate: fromDate, toDate: toDate)
        let predicate = conditions.andPredicate()
        return CDHabitRecord.findAll(with: predicate, in: .defaultContext)
    }
}
