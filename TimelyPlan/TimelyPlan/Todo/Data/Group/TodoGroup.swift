//
//  TodoGroup.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/19.
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

/// 待办分组
class TodoGroup: ListDiffable {
    
    /// 标识
    var identifier: String
    
    /// 头部视图是否隐藏
    var isHeaderHidden: Bool = false
    
    /// 标题
    var title: String?
    
    /// 任务
    var tasks: [TodoTask]?
    
    /// 是否展开
    var isExpanded: Bool = true
    
    /// 分组内是否包含任务
    var hasTasks: Bool {
        if let tasks = tasks, tasks.count > 0 {
            return true
        }
        
        return false
    }
    
    /// 是否是逾期分组
    var isOverdue: Bool {
        return self.identifier == TodoTaskDueDateType.overdue.identifier
    }
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    /// 获取索引处的任务
    func task(at index: Int) -> TodoTask? {
        guard let tasks = tasks, tasks.count > 0, index < tasks.count else {
            return nil
        }

        return tasks[index]
    }
    
    // MARK: - ListDiffable
    func diffIdentifier() -> NSObjectProtocol {
        return identifier as NSString
    }
    
    func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
        guard let object = object as? TodoGroup else {
            return false
        }
        
        return identifier == object.identifier
    }
}

class TodoListGroup: TodoGroup {
    
    var list: TodoList
    
    override var title: String? {
        get {
            return list.name
        }
        
        set {}
    }
    
    init(list: TodoList) {
        self.list = list
        super.init(identifier: list.identifier ?? UUID().uuidString)
    }
}
