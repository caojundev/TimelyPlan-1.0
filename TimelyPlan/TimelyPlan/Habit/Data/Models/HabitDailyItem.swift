//
//  HabitDailyItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/20.
//

import Foundation

class HabitDailyItem: NSObject {
    
    let identifier: String
    
    let record: HabitRecord
    
    let task: HabitTask
    
    /// 当前进度
    var progress: CGFloat {
        return task.progress(with: record)
    }
    
    var status: HabitTaskStatus {
        return task.status(with: record)
    }
    
    init(record: HabitRecord, task: HabitTask) {
        self.record = record
        self.task = task
        self.identifier = task.identifier + "-\(record.day)"
    }

    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(self.identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? HabitDailyItem else { return false }
        if self === other { return true }
        return self.identifier == other.identifier
    }
    
    // MARK: - IGListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return self.identifier as NSString
    }
}
