//
//  WorkspaceMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/18.
//

import Foundation
import UIKit

/// 工作台更多菜单
enum WorkspaceMoreMenuType: Int, TPMenuRepresentable {
    case editDashboard /// 编辑面板
    
    static func titles() -> [String] {
        return ["Edit Dashboard"]
    }
}

class WorkspaceMoreBarButtonItem: TPBaseMoreMenuBarButtonItem<WorkspaceMoreMenuType> {
    
    override func menuItems() -> [TPMenuItem] {
        let menuItem = TPMenuItem.item(with: WorkspaceMoreMenuType.allCases) { type, action in
            if type == .editDashboard {
                action.handleBeforeDismiss = true
            }
        }
        
        return [menuItem]
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = WorkspaceMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
}
