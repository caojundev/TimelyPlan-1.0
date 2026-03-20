//
//  Habit+RecordFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/20.
//

import Foundation

typealias HabitGroupedByDayRecords = [Int32: [HabitRecord]]

extension Habit {
    
    // MARK: - 获取记录
    static func fetchRecords(for tasks: [HabitTask],
                              in period: HabitDatePeriod,
                              completion: @escaping([CDHabitRecord]?)->Void) {
        let conditions: [PredicateCondition]
        if period.mode == .day {
            conditions = CDHabitRecord.conditions(forTasks: tasks, onDate: period.date)
        } else {
            conditions = CDHabitRecord.conditions(forTasks: tasks, inPeriod: period)
        }
        
        let predicate = conditions.andPredicate()
        CDHabitRecord.findAll(with: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }
    

    static func fetchRecordsGroupedByDay(in dateRange: DateRange,
                                         completion: @escaping (HabitGroupedByDayRecords?) -> Void) {
        Habit.fetchRecords(in: dateRange) { results in
            let records = recordsGroupedByDay(with: results)
            completion(records)
        }
    }
    
    static func fetchRecords(in dateRange: DateRange,
                             completion: @escaping([CDHabitRecord]?)->Void) {
        let condition = CDHabitRecord.condition(in: dateRange)
        let predicate = NSPredicate.predicate(with: condition)
        CDHabitRecord.findAll(with: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }
    
    static func fetchRecords(in period: HabitDatePeriod,
                             completion: @escaping([CDHabitRecord]?)->Void) {
        let condition: PredicateCondition
        if period.mode == .day {
            condition = CDHabitRecord.condition(onDate: period.date)
        } else {
            condition = CDHabitRecord.condition(in: period.dateRange)
        }
        
        let predicate = NSPredicate.predicate(with: condition)
        CDHabitRecord.findAll(with: predicate) { results in
            completion(results as? [CDHabitRecord])
        }
    }
    
    private static func recordsGroupedByDay(with results: [CDHabitRecord]?) -> HabitGroupedByDayRecords? {
        guard let results = results else {
            return nil
        }
        
        var recordsGroupedByDay = HabitGroupedByDayRecords()
        for result in results {
            let key = result.day
            var records = recordsGroupedByDay[key] ?? []
            let record = HabitRecord(content: result)
            records.append(record)
            recordsGroupedByDay[key] = records
        }
        
        return recordsGroupedByDay
    }
    
}
