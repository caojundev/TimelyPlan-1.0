//
//  HabitMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation
import UIKit

/// 更多菜单
enum HabitMoreMenuType: Int, TPMenuRepresentable {
    case manageHabits /// 管理习惯
    case archived     /// 已归档
    case settings     /// 设置
    
    static func titles() -> [String] {
        return ["Manage Habits",
                "Archived",
                "Settings"]
    }
    
    var iconName: String? {
        switch self {
        case .manageHabits:
            return "habit_manage_24"
        case .archived:
            return "archivedList_24"
        case .settings:
            return "gear_24"
        }
    }
}

class HabitMoreBarButtonItem: TPBaseMoreMenuBarButtonItem<HabitMoreMenuType> {
    
    override func menuItems() -> [TPMenuItem] {
        let typeLists: [Array<HabitMoreMenuType>]
        let archivedTasksCount = habit.archivedTasksCount()
        if archivedTasksCount > 0 {
            typeLists = [[.manageHabits, .archived], [.settings]]
        } else {
            typeLists = [[.manageHabits], [.settings]]
        }

        let items = TPMenuItem.items(with: typeLists) { type, action in
            if type == .archived {
                action.valueText = "\(archivedTasksCount)"
            }
        }
        
        return items
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = HabitMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
}
