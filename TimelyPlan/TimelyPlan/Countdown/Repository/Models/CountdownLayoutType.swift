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
    
    /// 图标（SF Symbol 名称）
    var iconName: String {
        switch self {
        case .list:
            return "list.bullet"
        case .grid:
            return "square.grid.2x2"
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
