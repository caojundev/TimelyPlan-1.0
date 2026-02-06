//
//  TPMenuItem+MenuRepresentable.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/25.
//

import Foundation

extension TPMenuRepresentable {

    /// 菜单动作
    var menuAction: TPMenuAction {
        let action = TPMenuAction()
        action.identifier = self.identifier
        action.tag = self.tag
        action.title = self.title
        action.image = self.iconImage
        action.style = self.actionStyle
        action.titleColor = self.titleColor
        action.iconColor = self.iconColor
        action.handleBeforeDismiss = self.handleBeforeDismiss
        return action
    }
}

extension TPMenuItem {
    
    /// 菜单条目
    class func item<T: TPMenuRepresentable>(with types: [T],
                                          updater: ((T, TPMenuAction) -> Void)? = nil) -> TPMenuItem {
        var actions = [TPMenuAction]()
        for type in types {
            let action = type.menuAction
            updater?(type, action)
            actions.append(action)
        }
        
        let menuItem = TPMenuItem()
        menuItem.actions = actions
        return menuItem
    }
    
    /// 多区块菜单条目数组
    class func items<T: TPMenuRepresentable>(with typeLists: [Array<T>],
                                           updater: ((T, TPMenuAction) -> Void)? = nil) -> [TPMenuItem] {
        var menuItems = [TPMenuItem]()
        for list in typeLists {
            let menuItem = TPMenuItem.item(with: list, updater: updater)
            if let actions = menuItem.actions, actions.count > 0 {
                menuItems.append(menuItem)
            }
        }

        return menuItems
    }
}
