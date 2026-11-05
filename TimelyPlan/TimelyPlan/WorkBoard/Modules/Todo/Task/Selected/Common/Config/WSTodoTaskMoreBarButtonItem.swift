//
//  WSTodoTaskMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 更多菜单

/// 自选任务的更多菜单
enum WSTodoTaskMoreMenuType: Int, TPMenuRepresentable {

    case showCompleted /// 显示已完成

    var iconName: String? {
        switch self {
        case .showCompleted:
            return "todo_list_option_showCompleted_24"
        }
    }

    var title: String {
        switch self {
        case .showCompleted:
            return resGetString("Show Completed")
        }
    }
}

/// 自选任务的更多按钮。
///
/// 菜单状态不持久化，每次打开配置界面默认不显示已完成任务。
class WSTodoTaskMoreBarButtonItem: TPBaseMoreMenuBarButtonItem<WSTodoTaskMoreMenuType> {

    /// 当前是否显示已完成任务
    var showCompleted: Bool = false

    override func configButton(_ button: TPMenuListButton) {
        super.configButton(button)
        button.menuContentWidth = 240.0
    }

    override func selectMenuAction(_ action: TPMenuAction) {
        guard let type = WSTodoTaskMoreMenuType(rawValue: action.tag) else {
            return
        }

        didSelectType?(type)
    }

    override func menuItems() -> [TPMenuItem] {
        let typeLists: [[WSTodoTaskMoreMenuType]] = [[.showCompleted]]
        return TPMenuItem.items(with: typeLists) { [weak self] _, action in
            action.handleBeforeDismiss = true
            action.isChecked = self?.showCompleted ?? false
        }
    }
}
