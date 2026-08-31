//
//  GoalMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

/// 更多菜单
enum GoalMoreMenuType: Int, TPMenuRepresentable {
    case archived /// 已归档
    case settings /// 设置
    
    static func titles() -> [String] {
        return ["Archived",
                "Settings"]
    }
    
    var iconName: String? {
        switch self {
        case .archived:
            return "archivedList_24"
        case .settings:
            return "gear_24"
        }
    }
}

class GoalMoreBarButtonItem: TPBaseMoreMenuBarButtonItem<GoalMoreMenuType> {
    
    override func menuItems() -> [TPMenuItem] {
        let typeLists: [Array<GoalMoreMenuType>] = [[.archived], [.settings]]
        let items = TPMenuItem.items(with: typeLists)
        return items
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = GoalMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
}
