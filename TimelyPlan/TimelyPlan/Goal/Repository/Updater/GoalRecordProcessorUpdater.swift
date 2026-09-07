//
//  GoalRecordProcessorUpdater.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/7.
//

import Foundation

/// 目标记录处理器代理
protocol GoalRecordProcessorDelegate: AnyObject {
    
    /// 远程目标记录改变
    func didChangeRemoteGoalRecord(with results: EntityChangeResults<GoalRecord>?)
    
    /// 创建目标记录
    func didCreateGoalRecord(_ record: GoalRecord, for task: GoalTask)
    
    /// 更新目标记录
    func didUpdateGoalRecord(_ record: GoalRecord, for task: GoalTask, with change: GoalRecordChange)
    
    /// 删除目标记录（dateRange 为 nil 表示不限制日期）
    func didDeleteGoalRecords(for task: GoalTask?, in dateRange: DateRange?)
}

extension GoalRecordProcessorDelegate {
    
    func didChangeRemoteGoalRecord(with results: EntityChangeResults<GoalRecord>?) {}
    
    func didCreateGoalRecord(_ record: GoalRecord, for task: GoalTask) {}
    
    func didUpdateGoalRecord(_ record: GoalRecord, for task: GoalTask, with change: GoalRecordChange) {}
    
    func didDeleteGoalRecords(for task: GoalTask?, in dateRange: DateRange?) {}
}

class GoalRecordProcessorUpdater: NSObject,
                                  GoalRecordProcessorDelegate {
    
    func didChangeRemoteGoalRecord(with results: EntityChangeResults<GoalRecord>?) {
        notifyDelegates { (delegate: GoalRecordProcessorDelegate) in
            delegate.didChangeRemoteGoalRecord(with: results)
        }
    }
    
    func didCreateGoalRecord(_ record: GoalRecord, for task: GoalTask) {
        notifyDelegates { (delegate: GoalRecordProcessorDelegate) in
            delegate.didCreateGoalRecord(record, for: task)
        }
    }
    
    func didUpdateGoalRecord(_ record: GoalRecord, for task: GoalTask, with change: GoalRecordChange) {
        notifyDelegates { (delegate: GoalRecordProcessorDelegate) in
            delegate.didUpdateGoalRecord(record, for: task, with: change)
        }
    }
    
    func didDeleteGoalRecords(for task: GoalTask?, in dateRange: DateRange?) {
        notifyDelegates { (delegate: GoalRecordProcessorDelegate) in
            delegate.didDeleteGoalRecords(for: task, in: dateRange)
        }
    }
}
