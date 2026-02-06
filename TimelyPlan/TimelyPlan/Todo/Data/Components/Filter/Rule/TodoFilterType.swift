//
//  TodoFilterType.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/19.
//

import Foundation

enum TodoFilterType: String, TPMenuRepresentable {
    case date
    case list
    case tag
    case priority
    case myDay
    case progress
    
    var title: String {
        switch self {
        case .list:
            return resGetString("List")
        case .date:
            return resGetString("Date")
        case .priority:
            return resGetString("Priority")
        case .tag:
            return resGetString("Tag")
        case .myDay:
            return resGetString("My Day")
        case .progress:
            return resGetString("Progress")
        }
    }
    
    var iconName: String? {
        return "todo_filter_" + rawValue + "_36"
    }
}

extension TodoTaskChange {
    
    /// 任务变化对应的过滤类型
    var filterType: TodoFilterType? {
        switch self {
        case .list(_, _):
            return .list
        case .priority(_, _):
            return .priority
        case .schedule(_, _):
            return .date
        case .myDay(_, _):
            return .myDay
        case .tag(_, _):
            return .tag
        case .progress(_, _):
            return .progress
        default:
            return nil
        }
    }
}
