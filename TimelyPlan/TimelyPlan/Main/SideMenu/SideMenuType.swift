//
//  SideMenuType.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/11.
//

import Foundation

/// 侧边栏菜单类型
enum SideMenuType: String, Codable, TPMenuRepresentable {
    
    case myDay /// 我的一天
    case calendar  /// 日历
    case todo  /// 待办
    case timeline  /// 时间线
    case quadrants /// 四象限
    case goal      /// 目标
    case focus     /// 专注
    case habit     /// 习惯
    case settings  /// 设置
    static func titles() -> [String] {
        return ["My Day",
                "Calendar",
                "Todo",
                "Timeline",
                "Quadrants",
                "Goal",
                "Focus",
                "Habit",
                "Settings"]
    }
    
    var iconName: String? {
        return "sideMenu_\(rawValue)_40"
    }
}
