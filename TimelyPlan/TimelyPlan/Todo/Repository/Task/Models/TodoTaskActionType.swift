//
//  TodoTaskActionType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/6.
//

import Foundation

enum TodoTaskActionType: String, TPMenuRepresentable {
    case done     /// 完成
    case undone   /// 未完成
    
    case move     /// 移动
    case date     /// 日期
    case priority /// 优先级
    case trash    /// 废纸篓
    
    case restore  /// 恢复
    case shred    /// 粉碎
    
    case addToMyDay /// 添加到我的一天
    case removeFromMyDay /// 从我的一天移除
    
    /// 图标名称
    var iconName: String? {
        return "todo_task_action_" + self.rawValue + "_24"
    }
    
    var title: String {
        switch self {
        case .addToMyDay:
            return resGetString("Add to My Day")
        case .removeFromMyDay:
            return resGetString("Remove from My Day")
        default:
            return defaultTitle
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        switch self {
        case .trash, .shred:
            return .destructive
        default:
            return .normal
        }
    }
    
    var handleBeforeDismiss: Bool {
        return false
    }
}
