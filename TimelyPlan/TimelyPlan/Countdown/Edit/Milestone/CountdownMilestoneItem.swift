//
//  CountdownMilestoneItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/21.
//

import Foundation

// MARK: - 里程碑集合条目
/// 集合视图条目，`CountdownMilestone` 为值类型，此处包装为 `NSObject` 以适配 `ListDiffable`
class CountdownMilestoneItem: NSObject {
    
    /// 里程碑
    let milestone: CountdownMilestone
    
    var date: CountdownDate?
    
    init(_ milestone: CountdownMilestone, date: CountdownDate?) {
        self.milestone = milestone
        self.date = date
        super.init()
    }
    
    /// 唯一标识（单位 + 间隔）
    var identifier: String {
        return "\(milestone.unit?.rawValue ?? -1)-\(milestone.interval ?? 0)"
    }
    
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(milestone)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? CountdownMilestoneItem else {
            return false
        }
        
        return milestone == other.milestone
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let other = object as? CountdownMilestoneItem else {
            return false
        }
        
        return milestone == other.milestone
    }
}
