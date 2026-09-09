//
//  GoalRecord.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/7.
//

import Foundation

/// 目标记录变化
enum GoalRecordChange {
    
    /// 数目变化
    case amountChanged(oldValue: Int64, newValue: Int64)
    
    /// 备注变化
    case noteChanged(oldValue: String?, newValue: String?)
}

/// 目标记录
///
/// 与 `HabitSample` 类似，表示一次独立的记录（而非一天的记录），
/// `amount` 为本次记录的数值变化量，`date` 为记录发生的时间。
class GoalRecord {
    
    /// 记录唯一标识（稳定，可用于删除等操作）
    var identifier: String
    
    /// 记录数目（本次记录的数值变化量）
    var amount: Int64 = 0
    
    /// 记录日期
    var date: Date?
    
    /// 备注
    var note: String?
    
    /// 所属天（日期整型键）
    var day: DayIntegerKey? {
        return date?.dayIntegerKey
    }
    
    /// 是否包含备注
    var hasNote: Bool {
        if let note = note, note.count > 0 {
            return true
        }
        
        return false
    }
    
    init(amount: Int64, date: Date?, note: String? = nil, identifier: String = UUID().uuidString) {
        self.identifier = identifier
        self.amount = amount
        self.date = date
        self.note = note
    }
    
    init(content: CDGoalRecord) {
        self.identifier = content.identifier ?? UUID().uuidString
        self.amount = content.amount
        self.date = content.date
        self.note = content.note
    }
}
