//
//  HabitEntry.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/7.
//

import Foundation

class HabitPeriodTask: NSObject {
    
    /// 习惯任务对象
    let habitTask: HabitTask
    
    /// 记录对应的时间段
    let period: HabitDatePeriod
    
    /// 记录字典
    var records: [Int32: HabitRecord]?
    
    // MARK: - Initialization

    init(habitTask: HabitTask, period: HabitDatePeriod) {
        self.habitTask = habitTask
        self.period = period
        super.init()
    }
    
    /// 特定日期对应的进度
    func progress(on date: Date) -> CGFloat {
        var progress: CGFloat = 0.0
        if let record = records?[date.dayIntegerKey] {
            progress = habitTask.progress(with: record)
        }
        
        return progress
    }
      
    
    // MARK: - 等同性判断
    /*
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(habitTask.identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let other = object as? HabitTask {
            return self.habitTask.identifier == other.identifier
        }
        
        guard let other = object as? HabitPeriodTask else { return false }
        if self === other { return true }
        return self.habitTask.identifier == other.habitTask.identifier
    }
    */
    
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return self.habitTask.identifier as NSString
    }

    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        if let other = object as? HabitTask {
            return self.habitTask.isEqual(toDiffableObject: other)
        }
        
        if let other = object as? HabitPeriodTask {
            return self.habitTask.isEqual(toDiffableObject: other.habitTask)
        }
        
        return false
    }
    
    // MARK: - Public Methods
    
    /// 获取特定记录对应的任务状态
    func taskStatus(with record: HabitRecord?) -> HabitTaskStatus {
        guard let record = record else {
            return .notStarted
        }

        var status: HabitTaskStatus = .notStarted
        let amount = record.amount
        
        // 检查是否已完成目标
        if amount >= habitTask.goal.targetAmount {
            status = .completed /// 已完成
        } else {
            // 检查是否有进度
            if amount > 0 {
                status = .inProgress /// 进行中
            }
            
            // 检查是否有特殊状态（跳过或失败）
            if record.status == .skipped {
                status = .skipped(record.reason) /// 跳过
            } else if record.status == .failed {
                status = .failed(record.reason) /// 失败
            }
        }
        
        return status
    }
}
