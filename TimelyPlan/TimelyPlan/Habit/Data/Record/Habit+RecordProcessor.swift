//
//  Habit+RecordProcessor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/9.
//

import Foundation

extension Habit {
    
    /// 完成所有
    func completeAll(for task: HabitTask, on date: Date) {
        self.recordProcessor.completeAll(for: task, on: date)
    }
    
    func updateRecord(amount: Int64, inputType: HabitRecordInputType, for task: HabitTask, on date: Date) {
        self.recordProcessor.updateRecord(amount: amount,
                                          inputType: inputType,
                                          for: task,
                                          on: date)
    }
        
    /// 添加或更改备注
    func addLog(_ logInfo: HabitRecordLogInfo?, for task: HabitTask, on date: Date) {
        self.recordProcessor.addLog(logInfo, for: task, on: date)
    }
    
    /// 跳过今天
    func skip(with tag: ReasonTag, for task: HabitTask, on date: Date) {
        self.recordProcessor.skip(with: tag, for: task, on: date)
    }
    
    /// 取消跳过
    func cancelSkip(for task: HabitTask, on date: Date) {
        self.recordProcessor.cancelSkip(for: task, on: date)
    }
    
    /// 标记为失败
    func markAsFail(with tag: ReasonTag, for task: HabitTask, on date: Date) {
        self.recordProcessor.markAsFail(with: tag, for: task, on: date)
    }
    
    /// 取消失败
    func cancelFail(for task: HabitTask, on date: Date) {
        self.recordProcessor.cancelFail(for: task, on: date)
    }
    
    /// 重置今日
    func resetToday(of date: Date, for task: HabitTask) {
        self.recordProcessor.resetToday(of: date, for: task)
    }
    
    func deleteRecords(in dateRange: DateRange) {
        self.recordProcessor.deleteRecords(in: dateRange)
    }
    
    
}
