//
//  FocusTimerGroup.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/23.
//

import Foundation

class FocusTimerGroup: NSObject, GroupRepresentable {

    enum GroupType: String {
        case user
        case system
    }

    /// 分组唯一标识
    let identifier: String
    
    /// 分组类型
    var type: GroupType = .user
    
    /// 图标名称
    var iconName: String?
    
    /// 分组标题
    var name: String?
    
    /// 分组内任务
    var timers: [ListDiffable]?
    
    convenience override init() {
        self.init(identifier: UUID().uuidString)
    }
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    // MARK: - GroupRepresentable
    
    var items: [ListDiffable]? {
        return self.timers
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? FocusTimerGroup else { return false }
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
