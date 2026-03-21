//
//  Habit+RecordFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/20.
//

import Foundation

typealias HabitGroupedDailyItems = [Int32: [HabitDailyItem]]

extension Habit {
    
    static func fetchDailyItemsGroupedByDay(in dateRange: DateRange,
                                              completion: @escaping (HabitGroupedDailyItems?) -> Void) {
        Habit.fetchRecords(in: dateRange) { results in
            let items = groupedDailyItems(with: results)
            completion(items)
        }
    }
    
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
    
    private static func groupedDailyItems(with results: [CDHabitRecord]?) -> HabitGroupedDailyItems? {
        guard let results = results else {
            return nil
        }
        
        var groupedDailyItems = HabitGroupedDailyItems()
        for result in results {
            guard let taskContent = result.task else {
                continue
            }
            
            let record = HabitRecord(content: result)
            let task = HabitTask(content: taskContent)
            let item = HabitDailyItem(record: record, task: task)
            
            let key = result.day
            var dayItems = groupedDailyItems[key] ?? []
            dayItems.append(item)
            groupedDailyItems[key] = dayItems
        }
        
        return groupedDailyItems
    }
    
}
