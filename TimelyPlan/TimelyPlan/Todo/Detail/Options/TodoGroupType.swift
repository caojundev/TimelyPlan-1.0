//
//  TodoGroupType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

/// 分组类型
enum TodoGroupType: String, Codable, TPMenuRepresentable {
    case `default`     /// 完成状态
    case list       /// 列表
    case startDate  /// 开始日期
    case dueDate    /// 截止日期
    case priority   /// 优先级
    
    case none       /// 无分组
    
    static func titles() -> [String] {
        return ["Default",
                "List",
                "Start Date",
                "Due Date",
                "Priority",
                "None Group"]
    }
    
    var iconName: String? {
        return "TodoGroupType" + defaultIconName()
    }
    
    var handleBeforeDismiss: Bool {
        return true
    }
}
