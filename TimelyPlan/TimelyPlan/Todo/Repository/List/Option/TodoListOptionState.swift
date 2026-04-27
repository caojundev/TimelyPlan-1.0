//
//  TodoListOptionState.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/15.
//

import Foundation

struct TodoListOptionState: Codable {
    
    /// 显示已完成
    var showCompleted: Bool = true
    
    /// 显示详情
    var showDetail: Bool = true
    
    /// 分组类型
    var groupType: TodoGroupType?
    
    /// 排序
    var sort: TodoSort?
    
    /// 布局方式
    var layoutType: TodoListLayoutType?
    
    func validatedGroupType(for configuration: TodoListConfiguration) -> TodoGroupType {
        return configuration.validatedGroupType(self.groupType)
    }
    
    func validatedSort(for configuration: TodoListConfiguration) -> TodoSort {
        return configuration.validatedSort(self.sort ?? TodoSort())
    }
}
