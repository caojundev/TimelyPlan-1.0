//
//  ReasonTag.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/19.
//

import Foundation

class ReasonTag: NSObject, Codable {
    
    /// 表情符号
    var emoji: String?
    
    /// 原因
    var reason: String?
    
    /// 表情 + 原因字符串
    var combinedString: String {
       return (emoji ?? "") + (reason ?? "")
    }
    
    convenience init(emoji: String?, reason: String?) {
        self.init()
        self.emoji = emoji
        self.reason = reason
    }
    
    // MARK: - 等同性判断
    override var hash: Int {
        var hasher = Hasher()
        hasher.combine(emoji)
        hasher.combine(reason)
        return hasher.finalize()
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? ReasonTag else { return false }
        if self === other { return true }
        return emoji == other.emoji && reason == other.reason
    }
}
