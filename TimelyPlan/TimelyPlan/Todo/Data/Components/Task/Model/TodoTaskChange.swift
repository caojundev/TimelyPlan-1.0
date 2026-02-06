//
//  TodoTaskChange.swift
//  TimelyPlan
//
//  Created by caojun on 2024/8/9.
//

import Foundation
import UIKit

struct TodoTaskChangeInfo {
    
    /// 任务
    let task: TodoTask
    
    /// 任务改变
    let change: TodoTaskChange
}

enum TodoTaskChange: Hashable {
    
    /// 列表
    case list(oldValue: TodoList?, newValue: TodoList?)
    
    /// 名称
    case name(oldValue: String?, newValue: String?)
    
    /// 备注
    case note(oldValue: String?, newValue: String?)
    
    /// 优先级
    case priority(oldValue: TodoTaskPriority, newValue: TodoTaskPriority)
    
    /// 计划
    case schedule(oldValue: TaskSchedule?, newValue: TaskSchedule?)
    
    /// 完成状态
    case completed(oldValue: Bool, newValue: Bool)

    /// 添加到我的一天
    case myDay(oldValue: Bool, newValue: Bool)
    
    /// 标签
    case tag(oldValue: Set<TodoTag>?, newValue: Set<TodoTag>?)
    
    /// 进度
    case progress(oldValue: TodoEditProgress?, newValue: TodoEditProgress?)
}

extension TodoTaskChange {
    
    enum TaskChangeType {
        case new
        case deleted
        case modified
        
        /// 图标名称
        var iconName: String {
            switch self {
            case .new:
                return "todo_task_change_new"
            case .deleted:
                return "todo_task_change_deleted"
            case .modified:
                return "todo_task_change_modified"
            }
        }
        
        /// 图标图片
        var iconImage: UIImage? {
            return resGetImage(iconName, size: .size(4))
        }
    }
    
    var changeType: TaskChangeType {
        switch self {
        case .myDay(_, _), .completed(_, _), .priority(_, _):
            return .modified
        case .name(let oldValue, let newValue), .note(let oldValue, let newValue):
            return changeType(oldValue: oldValue, newValue: newValue)
        case .list(let oldValue, let newValue):
            return changeType(oldValue: oldValue, newValue: newValue)
        case .schedule(let oldValue, let newValue):
            return changeType(oldValue: oldValue, newValue: newValue)
        case .tag(let oldValue, let newValue):
            return changeType(oldValue: oldValue, newValue: newValue)
        case .progress(let oldValue, let newValue):
            return changeType(oldValue: oldValue, newValue: newValue)
        }
    }
    
    private func changeType(oldValue: Any?, newValue: Any?) -> TaskChangeType {
        if oldValue == nil && newValue != nil {
            return .new
        } else if oldValue != nil && newValue == nil {
            return .deleted
        } else  {
            return .modified
        }
    }
    
    /// 富文本描述
    var attributedDescription: ASAttributedString? {
        var attributedString: ASAttributedString?
        switch self {
        case .list(let oldValue, let newValue):
            attributedString = listDescription(oldValue: oldValue, newValue: newValue)
        case .priority(let oldValue, let newValue):
            attributedString = priorityDescription(oldValue: oldValue, newValue: newValue)
        case .schedule(let oldValue, let newValue):
            attributedString = scheduleDescription(oldValue: oldValue, newValue: newValue)
        case .myDay(let oldValue, let newValue):
            attributedString = myDayDescription(oldValue: oldValue, newValue: newValue)
        case .tag(let oldValue, let newValue):
            attributedString = tagDescription(oldValue: oldValue, newValue: newValue)
        case .progress(let oldValue, let newValue):
            attributedString = progressDescription(oldValue: oldValue, newValue: newValue)
        default:
            break
        }
        
        guard let attributedString = attributedString else {
            return nil
        }
        
        var compontents = [ASAttributedString]()
        if let image = self.changeType.iconImage {
            compontents.append(.string(image: image))
        }
        
        compontents.append(attributedString)
        return compontents.joined(separator: " ")
    }
    
    private func listDescription(oldValue: TodoList?, newValue: TodoList?) -> ASAttributedString? {
        guard oldValue != newValue else {
            return nil
        }
        
        var results: [String] = []
        if let oldValue = oldValue, let newValue = newValue {
            results.append(oldValue.displayTitle())
            results.append(newValue.displayTitle())
        } else if let newValue = newValue {
            results.append(TodoSmartList.inbox.title)
            results.append(newValue.displayTitle())
        } else if let oldValue = oldValue {
            results.append(oldValue.displayTitle())
            results.append(TodoSmartList.inbox.title)
        }
        
        return results.joined(separator: " → ").attributedString
    }
    
    private func myDayDescription(oldValue: Bool, newValue: Bool) -> ASAttributedString? {
        guard oldValue != newValue else {
            return nil
        }
        
        let oldTitle = oldValue ? TodoMyDayFilterValue.added.title : TodoMyDayFilterValue.notAdded.title
        let newTitle = newValue ? TodoMyDayFilterValue.added.title : TodoMyDayFilterValue.notAdded.title
        return "\(oldTitle) → \(newTitle)"
    }
    
    private func priorityDescription(oldValue: TodoTaskPriority, newValue: TodoTaskPriority) -> ASAttributedString? {
        guard oldValue != newValue else {
            return nil
        }
        
        return "\(oldValue.title) → \(newValue.title)"
    }
    
    private func tagDescription(oldValue: Set<TodoTag>?, newValue: Set<TodoTag>?) -> ASAttributedString? {
        var infos = [ASAttributedString]()
        if let oldInfo = oldValue?.attributedOrderedTagsInfo() {
            infos.append(oldInfo)
        }
        
        if let newInfo = newValue?.attributedOrderedTagsInfo() {
            infos.append(newInfo)
        }
        
        return infos.joined(separator: " → ")
    }
    
    private func progressDescription(oldValue: TodoEditProgress?, newValue: TodoEditProgress?) -> ASAttributedString? {
        var infos = [String]()
        if let oldDescription = oldValue?.detailDescription {
            infos.append(oldDescription)
        }
        
        if let newDescription = newValue?.detailDescription {
            infos.append(newDescription)
        }
        
        return infos.joined(separator: " → ").attributedString
    }
    
    private func scheduleDescription(oldValue: TaskSchedule?, newValue: TaskSchedule?) -> ASAttributedString? {
        var infos = [ASAttributedString]()
        if let oldInfo = oldValue?.attributedDateInfo() {
            infos.append(oldInfo)
        }
        
        if let newInfo = newValue?.attributedDateInfo() {
            infos.append(newInfo)
        }
        
        return infos.joined(separator: " → ")
    }
}

extension Array where Element == TodoTaskChange {
    
    /// 获取对应的过滤类型集合
    var filterTypes: Set<TodoFilterType> {
        var results = Set<TodoFilterType>()
        for change in self {
            if let filterType = change.filterType {
                results.insert(filterType)
            }
        }
        
        return results
    }
}

extension Array where Element == TodoTaskChangeInfo {
    
    /// 获取所有任务
    var tasks: [TodoTask] {
        return self.map{ return $0.task }
    }
}
