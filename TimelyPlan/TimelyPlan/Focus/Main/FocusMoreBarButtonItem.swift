//
//  FocusMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2024/9/22.
//

import Foundation
import UIKit

/// 更多菜单
enum FocusMoreMenuType: Int, TPMenuRepresentable {
    case allRecords /// 所有记录
    case addRecord  /// 添加记录
    case archived /// 已归档
    case settings /// 设置
    
    static func titles() -> [String] {
        return ["All Records",
                "Add Record",
                "Archived",
                "Settings"]
    }
    
    var iconName: String? {
        switch self {
        case .allRecords:
            return "focus_record_24"
        case .addRecord:
            return "focus_record_add_24"
        case .archived:
            return "archivedList_24"
        case .settings:
            return "gear_24"
        }
    }
}

class FocusMoreBarButtonItem: TPBaseMoreBarButtonItem<FocusMoreMenuType> {
    
    override func configButton(_ button: TPMenuListButton) {
        button.image = resGetImage("ellipsis_circle_24")
    }
    
    override func menuItems() -> [TPMenuItem] {
        let typeLists: [Array<FocusMoreMenuType>] = [
            [.allRecords,
             .addRecord],
            [.archived,
             .settings]
        ]
        
        let items = TPMenuItem.items(with: typeLists) { type, action in
            if type == .archived {
                /// 归档计时器数目
                let archivedTimersCount = Focus.numberOfArchivedTimers()
                if archivedTimersCount > 0 {
                    action.valueText = "\(archivedTimersCount)"
                }
            }
        }
        
        return items
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        let type: FocusMoreMenuType? = action.actionType()
        if let type = type {
            didSelectType?(type)
        }
    }
}
