//
//  TodoListConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2025/2/20.
//

import Foundation

struct TodoListConfiguration: Equatable {
    
    /// 是否显示已完成
    var showCompleted: Bool = false
    
    /// 布局类型
    var layoutType: TodoListLayoutType = .list
    
    /// 分组类型
    var groupType: TodoGroupType = .priority
    
    /// 排列方式
    var sortType: TodoSortType = .manually
    
    /// 排列顺序
    var sortOrder: TodoSortOrder = .ascending
    
    /// 排序对象
    var sort: TodoSort {
        get {
            return TodoSort(type: sortType, order: sortOrder)
        }
        
        set {
            sortType = newValue.type
            sortOrder = newValue.order
        }
    }
    
    /// 加载列表配置
    static func load(for list: TodoListRepresentable) -> TodoListConfiguration {
        var configuratation = TodoListConfiguration()
        if let list = list as? TodoList {
            /// 用户列表布局信息根据列表设置
            configuratation.layoutType = list.layoutType
        }
        
        return configuratation
    }
}

protocol TodoListConfigurationUpdateDelegate: AnyObject {
    
    /// 通知待办列表配置已更新
    func didUpdateListConfiguration(_ configuration: TodoListConfiguration)
}
