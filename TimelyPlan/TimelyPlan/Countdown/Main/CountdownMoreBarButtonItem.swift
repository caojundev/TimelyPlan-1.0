//
//  CountdownMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/15.
//

import Foundation
import UIKit

/// 更多菜单
enum CountdownMoreMenuType: Int, TPMenuRepresentable {
    case archived /// 已归档
    case settings /// 设置
    
    static func titles() -> [String] {
        return ["Archived", "Settings"]
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

class CountdownMoreBarButtonItem: TPBaseMoreMenuBarButtonItem<CountdownMoreMenuType> {
    
    override func menuItems() -> [TPMenuItem] {
        let archivedCount = CountdownRepository.numberOfArchivedEvents()
        let typeLists: [Array<CountdownMoreMenuType>] = [[.archived],
                                                         [.settings]]
        let items = TPMenuItem.items(with: typeLists) { [weak self] type, action in
            self?.updateMenuAction(action,
                                   for: type,
                                   archivedCount: archivedCount)
        }
        
        return items
    }
    
    /// 更新菜单动作
    private func updateMenuAction(_ action: TPMenuAction,
                                  for type: CountdownMoreMenuType,
                                  archivedCount: Int) {
        switch type {
        case .archived:
            action.valueText = "\(archivedCount)"
        case .settings:
            break
        }
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = CountdownMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
}
