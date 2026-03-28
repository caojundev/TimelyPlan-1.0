//
//  HabitTaskBaseListGroupProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/11.
//

import Foundation

class HabitTaskBaseListGroupProvider {
    
    /// 当前列表任务
    var periodItems: [HabitPeriodItem] = []
    
    let requestManager = TPRequestManager()
    
    /// 是否需要刷新任务
    private(set) var shouldRefresh = true
    
    func setNeedsRefresh(_ refresh: Bool = true) {
        self.shouldRefresh = refresh
    }
    
    func updateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date) {
        let periodItem = periodItem(for: task)
        periodItem?.updateRecord(record, on: date)
    }
    
    func deleteHabitRecord(for task: HabitTask, on date: Date) {
        let periodItem = periodItem(for: task)
        periodItem?.updateRecord(nil, on: date)
    }
    
    func deleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        let periodItem = periodItem(for: task)
        periodItem?.deleteRecords(in: period)
    }
    
    // MARK: - Helpers
    func periodItem(for habitTask: HabitTask) -> HabitPeriodItem? {
        for periodItem in periodItems {
            if periodItem.habitTask.identifier == habitTask.identifier {
                return periodItem
            }
        }
        
        return nil
    }
    
}
