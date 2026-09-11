//
//  GoalPlanFeature.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/10.
//

import Foundation

/// 列表特征信息
class GoalPlanFeature: NSObject,
                       TPHexColorConvertible,
                        IdentifiableItem {

    /// 收件箱标识
    static let inboxIdentifier = "inbox"
    
    /// 收件箱特征信息（未归属任何目标计划的目标任务）
    static var inboxFeature: GoalPlanFeature {
        return GoalPlanFeature(identifier: inboxIdentifier,
                               name: resGetString("Inbox"),
                               colorHex: Color(0x237DFF).hexString)
    }
    
    /// 标识
    var identifier: String
  
    /// 快照名称
    var name: String?
    
    /// 十六进制颜色字符串
    var colorHex: String?
    
    /// 显示名称
    var displayName: String {
        return name ?? resGetString("Untitled Goal")
    }
    
    /// 是否收件箱
    var isInbox: Bool {
        return identifier == GoalPlanFeature.inboxIdentifier
    }
    
    init(identifier: String,
         name: String?,
         colorHex: String?) {
        self.identifier = identifier
        self.name = name
        self.colorHex = colorHex
        super.init()
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(identifier)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? GoalPlanFeature else { return false }
        if self === other { return true }
        return identifier == other.identifier
    }
}
