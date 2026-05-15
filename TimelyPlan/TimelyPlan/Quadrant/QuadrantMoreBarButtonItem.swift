//
//  QuadrantMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/19.
//

import Foundation
import UIKit

/// 更多菜单
enum QuadrantMoreMenuType: Int, TPMenuRepresentable {
    case showCompleted /// 显示已完成
    case showDetail    /// 显示详情
    case viewLayout    /// 布局样式
    case customRule    /// 自定义规则
    
    var iconName: String? {
        switch self {
        case .showCompleted:
            return "quadrant_option_showCompleted_24"
        case .showDetail:
            return "quadrant_option_detail_24"
        case .viewLayout:
            return "quadrant_option_layout_24"
        case .customRule:
            return "quadrant_option_edit_24"
        }
    }
    
    var title: String {
        switch self {
        case .showCompleted:
            return resGetString("Show Completed")
        case .showDetail:
            return resGetString("Show Detail")
        case .viewLayout:
            return resGetString("View Layout")
        case .customRule:
            return resGetString("Custom Rule")
        }
    }
}

class QuadrantMoreBarButtonItem: TPBaseMoreMenuBarButtonItem<QuadrantMoreMenuType> {
    
    override func configButton(_ button: TPMenuListButton) {
        super.configButton(button)
        button.menuContentWidth = 240.0
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = QuadrantMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
    
    override func menuItems() -> [TPMenuItem] {
        let typeLists: [[QuadrantMoreMenuType]] = [[.showCompleted, .showDetail],
                                                   [.viewLayout],
                                                   [.customRule]]
        let menuItems = TPMenuItem.items(with: typeLists) {[weak self] type, action in
            self?.updateMenuAction(action, for: type)
        }
        
        return menuItems
    }
    
    private func updateMenuAction(_ action: TPMenuAction, for type: QuadrantMoreMenuType) {
        switch type {
        case .showCompleted:
            action.handleBeforeDismiss = true
            action.isChecked = QuadrantSetting.shared.showCompleted
        case .showDetail:
            action.handleBeforeDismiss = true
            action.isChecked = QuadrantSetting.shared.showDetail
        default:
            break
        }
    }
}
