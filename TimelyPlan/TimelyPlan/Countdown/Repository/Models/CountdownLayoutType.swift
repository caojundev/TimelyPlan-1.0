//
//  CountdownLayoutType.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/19.
//

import Foundation

/// 倒数日事项布局类型
enum CountdownLayoutType: Int, CaseIterable {
    
    /// 列表
    case list = 0
    
    /// 网格
    case grid
    
    /// 切换后的布局类型
    var toggled: CountdownLayoutType {
        switch self {
        case .list:
            return .grid
        case .grid:
            return .list
        }
    }
    
    var iconName: String {
        switch self {
        case .list:
            return "countdown_layout_list_24"
        case .grid:
            return "countdown_layout_grid_24"
        }
    }
    
    /// 标题
    var title: String {
        switch self {
        case .list:
            return resGetString("List")
        case .grid:
            return resGetString("Grid")
        }
    }
}
