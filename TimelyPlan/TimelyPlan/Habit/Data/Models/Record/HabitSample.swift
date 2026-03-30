//
//  HabitSample.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/30.
//

import Foundation

class HabitSample {

    /// 完成数量
    var amount: Int64 = 0
    
    var date: Date?

    init(content: CDHabitSample) {
        self.amount = content.amount
        self.date = content.date
    }
}
