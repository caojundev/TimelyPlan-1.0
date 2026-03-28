//
//  HabitEntry.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

class HabitPeriodItem: NSObject {
    
    /// 习惯任务对象
    let habitTask: HabitTask
    
    /// 记录对应的时间段
    let period: HabitDatePeriod
    
    /// 记录字典
    var records: [DayIntegerKey: HabitRecord]?
    
    private lazy var scheduler: HabitTimePlanScheduler = {
        return HabitTimePlanScheduler()
    }()
    
    // MARK: - Initialization

    init(habitTask: HabitTask, period: HabitDatePeriod) {
        self.habitTask = habitTask
        self.period = period
        super.init()
    }
    
    func updateRecord(_ record: HabitRecord?, on date: Date) {
        if records == nil {
            records = [:]
        }
        
        records?[date.dayIntegerKey] = record
    }
    
    /// 删除时间范围内的记录
    func deleteRecords(in period: HabitDatePeriod) {
        guard let keys = self.records?.keys else {
            return
        }
        
        let startDayKey = period.dateRange.startDate?.dayIntegerKey ?? 0
        let endDayKey = period.dateRange.endDate?.dayIntegerKey ?? Int32.max
        for key in keys {
            if key >= startDayKey && key <= endDayKey {
                self.records?[key] = nil
            }
        }
    }
    
    /// 特定日期对应的进度
    func progress(on date: Date) -> CGFloat {
        var progress: CGFloat = 0.0
        if let record = records?[date.dayIntegerKey] {
            progress = habitTask.progress(with: record)
        }
        
        return progress
    }
      
    func record(on date: Date) -> HabitRecord? {
        return records?[date.dayIntegerKey]
    }

    /// 获取特定记录对应的任务状态
    func status(on date: Date) -> HabitTaskStatus {
        let record = record(on: date)
        return habitTask.status(with: record)
    }

    func status(with record: HabitRecord?) -> HabitTaskStatus {
        return habitTask.status(with: record)
    }

    func isScheduledDate(_ date: Date) -> Bool {
        return scheduler.isScheduledDate(date,
                                         timePlan: habitTask.timePlan,
                                         dateRange: habitTask.dateRange)
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return self.habitTask.identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? HabitTask {
            return self.habitTask.isEqual(toDiffableObject: other)
        }
        
        if let other = object as? HabitPeriodItem {
            return self.habitTask.isEqual(toDiffableObject: other.habitTask)
        }
        
        return false
    }
    
}
