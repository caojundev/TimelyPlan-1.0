//
//  HabitReportMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation

/// 更多菜单
enum HabitReportMoreMenuType: Int, TPMenuRepresentable {
    
    case showArchived   /// 显示已归档
    
    var iconName: String? {
        switch self {
        case .showArchived:
            return "archive_24"
        }
    }
    
    var title: String {
        switch self {
        case .showArchived:
            return resGetString("Show Archived")
        }
    }
}

class HabitReportMoreBarButtonItem: TPBaseMoreBarButtonItem<HabitReportMoreMenuType> {
    
    override func configButton(_ button: TPMenuListButton) {
        super.configButton(button)
        button.menuContentWidth = 240.0
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = HabitReportMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
    
    override func menuItems() -> [TPMenuItem] {
        let menuItem = TPMenuItem.item(with: HabitReportMoreMenuType.allCases) {[weak self] type, action in
            self?.updateMenuAction(action, for: type)
        }
        
        return [menuItem]
    }
    
    private func updateMenuAction(_ action: TPMenuAction, for type: HabitReportMoreMenuType) {
        switch type {
        case .showArchived:
            action.isChecked = HabitSetting.shared.isReportShowArchived
        }
    }
}
