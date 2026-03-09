//
//  CDHabitSample+Extensions.swift
//  iTimeFlow
//
//  Created by caojun on 2023/10/20.
//

import Foundation

extension CDHabitSample {
    
    /// 创建新记录sample
    static func newSample(amount: Int64, date: Date, record: CDHabitRecord? = nil) -> CDHabitSample {
        let sample = CDHabitSample.createEntity(in: .defaultContext)
        sample.amount = Int64(amount)
        sample.date = date
        
        if let record = record {
            record.addToSamples(sample)
        }
        
        return sample
    }
    
    static func addNewSample(amount: Int64,
                             date: Date,
                             toRecord record: CDHabitRecord) {
        let _ = newSample(amount: amount, date: date, record: record)
    }
}
