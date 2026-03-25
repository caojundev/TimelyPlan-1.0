//
//  FocusStatsOverallMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/25.
//

import Foundation

/// 更多菜单
enum FocusStatsOverallMoreMenuType: Int, TPMenuRepresentable {
    
    case showArchived   /// 显示已归档
    
    var iconName: String? {
        switch self {
        case .showArchived:
            return "archived_show_24"
        }
    }
    
    var title: String {
        switch self {
        case .showArchived:
            return resGetString("Show Archived")
        }
    }
}

class FocusStatsOverallMoreBarButtonItem: TPBaseMoreBarButtonItem<FocusStatsOverallMoreMenuType> {
    
    override func configButton(_ button: TPMenuListButton) {
        super.configButton(button)
        button.menuContentWidth = 240.0
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = FocusStatsOverallMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
    
    override func menuItems() -> [TPMenuItem] {
        let menuItem = TPMenuItem.item(with: FocusStatsOverallMoreMenuType.allCases) {[weak self] type, action in
            self?.updateMenuAction(action, for: type)
        }
        
        return [menuItem]
    }
    
    private func updateMenuAction(_ action: TPMenuAction, for type: FocusStatsOverallMoreMenuType) {
        switch type {
        case .showArchived:
            action.isChecked = FocusSetting.shared.isOverallStatsShowArchived
        }
    }
}
