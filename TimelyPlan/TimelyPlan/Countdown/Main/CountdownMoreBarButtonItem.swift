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
    case layout   /// 切换布局
    case archived /// 已归档
    
    static func titles() -> [String] {
        return ["Layout", "Archived"]
    }
    
    var iconName: String? {
        switch self {
        case .archived:
            return "archivedList_24"
        case .layout:
            return nil
        }
    }
}

class CountdownMoreBarButtonItem: TPBaseMoreMenuBarButtonItem<CountdownMoreMenuType> {
    
    /// 当前布局类型
    var layoutType: CountdownLayoutType = .list
    
    override func menuItems() -> [TPMenuItem] {
        let archivedCount = CountdownRepository.numberOfArchivedEvents()
        let typeLists: [Array<CountdownMoreMenuType>] = [[.layout],
                                                         [.archived]]
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
        case .layout:
            /// 展示当前布局，点击切换
            action.handleBeforeDismiss = true
            action.subtitle = layoutType.title
            action.image = resGetImage(layoutType.iconName)
        }
    }
    
    override func selectMenuAction(_ action: TPMenuAction) {
        if let type = CountdownMoreMenuType(rawValue: action.tag) {
            didSelectType?(type)
        }
    }
}
