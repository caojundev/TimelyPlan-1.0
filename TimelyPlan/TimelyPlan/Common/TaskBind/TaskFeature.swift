//
//  TaskFeature.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/1.
//

import Foundation
import UIKit

/// 任务类型
enum TaskType: Int, Codable, TPMenuRepresentable {
    case none = 0
    case todo /// 待办
    case habit /// 习惯
    
    static var allTypes: [TaskType] {
        return [.habit]
    }
    
    var identifier: String {
        switch self {
        case .none:
            return "None"
        case .todo:
            return "Todo"
        case .habit:
            return "Habit"
        }
    }
    
    var title: String {
        switch self {
        case .none:
            return resGetString("None")
        case .todo:
            return resGetString("Todo")
        case .habit:
            return resGetString("Habit")
        }
    }
    
    var iconName: String? {
        switch self {
        case .todo:
            return "task_type_todo"
        case .habit:
            return "task_type_habit"
        default:
            return nil
        }
    }
    
    
}

/// 任务信息
struct TaskFeature: Codable, Hashable, Equatable {
    
    /// 类型
    var type: TaskType
    
    /// 标识
    var identifier: String
  
    /// 快照名称
    var snapshotName: String?
    
    var typeImage: UIImage? {
        let image = type.iconImage(with: .mini) ?? resGetImage("bind", size: .mini)
        return image
    }
    
    /// 提供自定义的哈希值计算
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(identifier)
        hasher.combine(snapshotName)
    }
    
    static var none: TaskFeature {
        let snapshotName = resGetString("Unlinked Task")
        return TaskFeature(type: .none,
                           identifier: TaskType.none.identifier,
                           snapshotName: snapshotName)
    }
}
