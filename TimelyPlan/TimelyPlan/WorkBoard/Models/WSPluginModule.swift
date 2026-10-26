//
//  WSPluginModule.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/16.
//

import Foundation

// MARK: - 插件模块
public enum WSPluginModule: String, Codable, TPMenuRepresentable {
    case myDay     /// 我的一天
    case calendar  /// 日历
    case todo      /// 待办
    case timeline  /// 时间线
    case quadrants /// 四象限
    case goal      /// 目标
    case focus     /// 专注
    case habit     /// 习惯
    case countdown /// 倒数日
    
    static func titles() -> [String] {
        return ["My Day",
                "Calendar",
                "Todo",
                "Timeline",
                "Quadrants",
                "Goal",
                "Focus",
                "Habit",
                "Countdown"]
    }
    
    var iconName: String? {
        return "sideMenu_\(rawValue)_40"
    }
    
    /// 模块展示名称
    var displayName: String {
        return title
    }

    /// 该模块下的全部组件类型，按 `WSPluginType` 中的声明顺序排列。
    var types: [WSPluginType] {
        return WSPluginType.allCases.filter { $0.module == self }
    }
}
