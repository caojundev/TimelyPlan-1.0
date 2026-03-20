//
//  HabitDailyItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/20.
//

import Foundation

class HabitDailyItem {
    
    var record: HabitRecord
    
    var task: HabitTask
    
    init(record: HabitRecord, task: HabitTask) {
        self.record = record
        self.task = task
    }
}
