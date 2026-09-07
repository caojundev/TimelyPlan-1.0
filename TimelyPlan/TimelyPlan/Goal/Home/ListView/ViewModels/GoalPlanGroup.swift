//
//  GoalPlanGroup.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation

class GoalPlanGroup: NSObject, GroupRepresentable {
    
    enum GroupType: String {
        case user
        case system
    }
    
    /// 分组唯一标识
    let identifier: String
    
    /// 分组类型
    var type: GroupType = .user
    
    /// 分组标题
    var name: String?
    
    /// 分组内目标计划
    var goalPlans: [ListDiffable]?
    
    convenience override init() {
        self.init(identifier: UUID().uuidString)
    }
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - GroupRepresentable
    var items: [ListDiffable]? {
        return self.goalPlans
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GoalPlanGroup else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
    
    // MARK: - ListDiffable
    override func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    override func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        return isEqual(object)
    }
}
