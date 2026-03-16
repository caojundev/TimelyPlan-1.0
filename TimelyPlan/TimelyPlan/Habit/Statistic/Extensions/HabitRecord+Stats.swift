//
//  HabitRecord+Stats.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/16.
//

import Foundation

extension Array where Element == HabitRecord {
    
    /// 特定任务对应的完成天数
    func finishedDays(for task: HabitTask) -> Int {
        let targetAmount = task.goal.validatedTargetAmount
        var count = 0
        for record in self {
            if record.amount >= targetAmount {
                count += 1
            }
        }
        
        return count
    }
    
    /// 总记录量
    var recordAmount: Int64 {
        let amount = self.reduce(0) { (result, record) in
            return result + record.amount
        }
        
        return amount
    }
    
    /// 平均分
    var averageScore: Int {
        let sum = self.reduce(0) { (result, record) in
            return result + Int(record.score)
        }
        
        if count > 0 {
            return sum / count
        }
        
        return 0
    }
}
