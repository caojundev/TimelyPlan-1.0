//
//  SideMenuType.swift
//  TimelyPlan
//
//  Created by caojun on 2023/6/11.
//

import Foundation
import UIKit

/// 侧边栏菜单类型
enum SideMenuType: String, Codable, TPMenuRepresentable {
    
    case myDay     /// 我的一天
    case calendar  /// 日历
    case todo      /// 待办
    case timeline  /// 时间线
    case quadrants /// 四象限
    case goal      /// 目标
    case focus     /// 专注
    case habit     /// 习惯
    case countdown /// 倒数日
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
                "Countdown",
                "Settings"]
    }
    
    var iconName: String? {
        return "sideMenu_\(rawValue)_40"
    }
}

extension SideMenuType {
    
    /// 侧边栏菜单默认顺序
    static var defaultSideMenuOrder: [SideMenuType] {
        return [.myDay,
                .calendar,
                .todo,
                .quadrants,
                .timeline,
                .goal,
                .focus,
                .habit,
                .countdown,
                .settings]
    }
    
    /// 是否内置固定显示（不可关闭）
    var isFixedOnSideMenu: Bool {
        switch self {
        case .myDay, .todo, .settings:
            return true
        default:
            return false
        }
    }
    
    /// 是否固定显示在侧边栏底部（不可关闭且顺序不可调整）
    var isFixedAtBottomOnSideMenu: Bool {
        switch self {
        case .settings:
            return true
        default:
            return false
        }
    }
    
    /// 侧边栏显示设置中可调整的菜单类型（顺序可调整）
    static var customizableSideMenuTypes: [SideMenuType] {
        return defaultSideMenuOrder.filter { !$0.isFixedAtBottomOnSideMenu }
    }
    
    /// 侧边栏区块分组标识（相同标识的菜单显示在同一个区块）
    var sideMenuGroupKey: String {
        switch self {
        case .todo, .quadrants:
            return "task"
        default:
            return rawValue
        }
    }
    
    /// 根据菜单类型创建侧边栏区块菜单
    static func sideMenuItems(with types: [SideMenuType]) -> [TPMenuItem] {
        var menuItems = [TPMenuItem]()
        var currentGroupKey: String?
        var currentTypes = [SideMenuType]()
        
        func appendCurrentGroup() {
            guard !currentTypes.isEmpty else {
                return
            }
            
            menuItems.append(TPMenuItem.item(with: currentTypes))
            currentTypes = []
        }
        
        for type in types {
            if let groupKey = currentGroupKey, groupKey != type.sideMenuGroupKey {
                appendCurrentGroup()
            }
            
            currentGroupKey = type.sideMenuGroupKey
            currentTypes.append(type)
        }
        appendCurrentGroup()
        
        return menuItems
    }
}
