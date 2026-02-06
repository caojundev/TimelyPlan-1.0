//
//  TodoTaskMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/7/1.
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
    
    /// 图标名称
    var iconName: String? {
        return "todo_task_action_" + self.rawValue + "_24"
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

class TodoTaskMenuController: TPBaseMenuController<TodoTaskActionType> {
    
    /// 菜单作用的任务
    let task: TodoTask

    init(task: TodoTask) {
        self.task = task
        super.init()
        self.preferredPosition = .topLeft
    }
}

