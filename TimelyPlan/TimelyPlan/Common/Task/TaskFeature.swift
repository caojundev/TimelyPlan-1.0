//
//  TaskFeature.swift
//  TimelyPlan
//
//  Created by caojun on 2023/11/1.
//

import Foundation

/// 任务类型
enum TaskType: Int, Codable, TPMenuRepresentable {
    case none = 0
    case todo /// 待办
    case habit /// 习惯
    
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
    
    static var allTypes: [TaskType] {
        return [.todo, .habit]
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
