//
//  Habit+Record.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/12.
//

import Foundation
import CoreData

/// 习惯记录处理通知协议
protocol HabitRecordProcessorDelegate: AnyObject{
    
    /// 通知习惯记录已更新
    func didUpdateHabitRecord(_ record: HabitRecord,
                              for task: HabitTask,
                              on date: Date,
                              with change: HabitRecordChange)
    
    /// 通知习惯记录删除
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod)
}

extension HabitRecordProcessorDelegate {
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {}
}

class HabitRecordProcessorUpdater: NSObject, HabitRecordProcessorDelegate {

    func didUpdateHabitRecord(_ record: HabitRecord,
                              for task: HabitTask,
                              on date: Date,
                              with change: HabitRecordChange) {
        notifyDelegates { (delegate: HabitRecordProcessorDelegate) in
            delegate.didUpdateHabitRecord(record, for: task, on: date, with: change)
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        notifyDelegates { (delegate: HabitRecordProcessorDelegate) in
            delegate.didDeleteHabitRecords(for: task, in: period)
        }
    }
}

class HabitRecordProcessor {
    
    /// 记录处理更新器
    let updater = HabitRecordProcessorUpdater()
    
    /// 完成所有
    func completeAll(for task: HabitTask, on date: Date) {
        let totalAmount = task.goal.validatedTargetAmount
        updateRecord(totalAmount: totalAmount, for: task, on: date)
    }
    
    func updateRecord(amount: Int64, inputType: HabitRecordInputType, for task: HabitTask, on date: Date) {
        if inputType == .byTotal {
            updateRecord(totalAmount: amount, for: task, on: date)
        } else {
            updateRecord(incrementAmount: amount, for: task, on: date)
        }
    }
    
    func updateRecord(incrementAmount: Int64, for task: HabitTask, on date: Date) {
        guard let record = CDHabitRecord.getRecord(for: task, on: date, createIfNil: true) else {
            return
        }
        
        let oldAmount = record.amount
        let newAmount = oldAmount + Int64(incrementAmount)
        record.amount = newAmount
        
        /// 已完成设置评分
        if record.amount >= task.goal.targetAmount {
            record.score = Int16(HabitSetting.shared.defaultCompletedScore)
        }
        
        /// 添加sample
        CDHabitSample.addNewSample(amount: incrementAmount, date: .now, toRecord: record)
        HandyRecord.save()
        
        let change: HabitRecordChange = .amountChanged(oldValue: oldAmount,
                                                       newValue: newAmount)
        didUpdateCoreDataRecord(record, for: task, on: date, with: change)
    }
    
    func updateRecord(totalAmount amount: Int64, for task: HabitTask, on date: Date) {
        guard let record = CDHabitRecord.getRecord(for: task, on: date, createIfNil: true) else {
            return
        }
        
        let oldAmount = record.amount
        let newAmount = Int64(amount)
        if newAmount == oldAmount {
            return
        }
        
        let increment = newAmount - oldAmount
        record.amount = newAmount
        
        /// 已完成设置评分
        if record.amount >= task.goal.targetAmount {
            record.score = Int16(HabitSetting.shared.defaultCompletedScore)
        }
        
        /// 添加sample
        CDHabitSample.addNewSample(amount: increment,
                                   date: .now,
                                   toRecord: record)
        HandyRecord.save()
        
        /// 记录变化通知
        let change: HabitRecordChange = .amountChanged(oldValue: oldAmount,
                                                       newValue: newAmount)
        didUpdateCoreDataRecord(record, for: task, on: date, with: change)
    }
    
    /// 添加或更改备注
    func addLog(_ logInfo: HabitRecordLogInfo?, for task: HabitTask, on date: Date) {
        guard let record = CDHabitRecord.getRecord(for: task, on: date, createIfNil: true) else {
            return
        }
        
        let oldLogInfo = HabitRecordLogInfo(log: record.log, score: Int(record.score))
        record.log = logInfo?.log
        record.score = Int16(logInfo?.score ?? 0)
        HandyRecord.save()
        
        let change: HabitRecordChange = .logEdited(oldValue: oldLogInfo,
                                                   newValue: logInfo)
        didUpdateCoreDataRecord(record, for: task, on: date, with: change)
    }
    
    /// 跳过今天
    func skip(with tag: ReasonTag, for task: HabitTask, on date: Date) {
        guard let record = CDHabitRecord.getRecord(for: task, on: date, createIfNil: true) else {
            return
        }
        
        record.status = Int16(HabitRecord.Status.skipped.rawValue)
        record.reason = tag.combinedString
        record.score = Int16(HabitSetting.shared.defaultSkippedScore)
        HandyRecord.save()
        
        let change = HabitRecordChange.skipChanged(oldValue: false,
                                                      newValue: true)
        didUpdateCoreDataRecord(record, for: task, on: date, with: change)
    }
    
    /// 取消跳过
    func cancelSkip(for task: HabitTask, on date: Date) {
        guard let record = CDHabitRecord.getRecord(for: task, on: date, createIfNil: false) else {
            return
        }
        
        record.status = Int16(HabitRecord.Status.normal.rawValue)
        record.reason = nil
        record.score = 0
        HandyRecord.save()
        
        let change = HabitRecordChange.skipChanged(oldValue: true, newValue: false)
        didUpdateCoreDataRecord(record, for: task, on: date, with: change)
    }
    
    /// 标记为失败
    func markAsFail(with tag: ReasonTag, for task: HabitTask, on date: Date) {
        guard let record = CDHabitRecord.getRecord(for: task, on: date, createIfNil: true) else {
            return
        }
        
        record.status = Int16(HabitRecord.Status.failed.rawValue)
        record.reason = tag.combinedString
        record.score = Int16(HabitSetting.shared.defaultFailedScore)
        HandyRecord.save()
        
        let change: HabitRecordChange = .failChanged(oldValue: false,
                                                     newValue: true)
        didUpdateCoreDataRecord(record, for: task, on: date, with: change)
    }
    
    /// 取消失败
    func cancelFail(for task: HabitTask, on date: Date) {
        guard let record = CDHabitRecord.getRecord(for: task, on: date, createIfNil: false) else {
            return
        }
        
        record.status = Int16(HabitRecord.Status.normal.rawValue)
        record.reason = nil
        record.score = 0
        HandyRecord.save()
        
        let change = HabitRecordChange.failChanged(oldValue: true, newValue: false)
        didUpdateCoreDataRecord(record, for: task, on: date, with: change)
    }
    
    // MARK: - 重置数据
    /// 重置今日
    func resetToday(of date: Date, for task: HabitTask) {
        let period = HabitDatePeriod(date: date, mode: .day)
        guard deleteRecords(for: task, within: period) else {
            return
        }
        
        HandyRecord.save()
        updater.didDeleteHabitRecords(for: task, in: period)
    }
    
    /// 重置本周
    func resetThisWeek(contain date: Date, for task: HabitTask) {
        let firstWeekday = HabitSetting.shared.firstWeekday
        let period = HabitDatePeriod.weekPeriod(date: date, firstWeekday: firstWeekday)
        guard deleteRecords(for: task, within: period) else {
            return
        }
        
        HandyRecord.save()
        updater.didDeleteHabitRecords(for: task, in: period)
    }
    
    func resetThisMonth(contain date: Date, for task: HabitTask) {
        let period = HabitDatePeriod(date: date, mode: .month)
        guard deleteRecords(for: task, within: period) else {
            return
        }
        
        HandyRecord.save()
        updater.didDeleteHabitRecords(for: task, in: period)
    }
    
    /// 删除对应任务在周期内所有记录
    private func deleteRecords(for task: HabitTask, within period: HabitDatePeriod) -> Bool {
        let dateRange = period.dateRange
        guard let fromDate = dateRange.startDate, let toDate = dateRange.endDate else {
            return false
        }

        return deleteRecords(for: task, fromDate: fromDate, toDate: toDate)
    }
    
    /// 删除对应任务从fromDate到toDate之间所有记录
    private func deleteRecords(for task: HabitTask, fromDate: Date, toDate: Date)  -> Bool {
        guard let records = CDHabitRecord.getRecords(for: task, fromDate: fromDate, toDate: toDate), records.count > 0 else {
            return false
        }
        
        NSManagedObjectContext.defaultContext.deleteObjects(records)
        return true
    }
    
    // MARK: - 通知更新
    private func didUpdateCoreDataRecord(_ record: CDHabitRecord,
                                         for task: HabitTask,
                                         on date: Date,
                                         with change: HabitRecordChange) {
        let record = HabitRecord(content: record)
        updater.didUpdateHabitRecord(record,
                                     for: task,
                                     on: date,
                                     with: change)
    }
}

