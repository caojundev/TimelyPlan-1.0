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
    case todo  /// 待办
    case quadrants /// 四象限
    case calendar  /// 日历
    case focus     /// 专注
    case settings  /// 设置
    static func titles() -> [String] {
        return ["My Day",
                "Todo",
                "Four Quadrants",
                "Calendar",
                "Focus",
                "Settings"]
    }
    
    var iconName: String? {
        let firstCharIndex = rawValue.startIndex
        let firstChar = String(rawValue[firstCharIndex]).capitalized
        let suffixName = firstChar + String(rawValue.dropFirst())
        let name = "SideMenu" + suffixName
        return name
    }
}
