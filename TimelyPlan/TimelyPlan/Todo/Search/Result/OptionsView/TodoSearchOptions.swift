//
//  TodoSearchOptions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/25.
//

import Foundation

struct TodoSearchOptions {
    
    /// 显示已完成
    var showCompleted: Bool = false
    
    /// 搜索步骤
    var searchStep: Bool = true
    
    /// 搜索备注
    var searchNote: Bool = true
    
    /// 过滤规则
    var filterRule: TodoFilterRule?
}
