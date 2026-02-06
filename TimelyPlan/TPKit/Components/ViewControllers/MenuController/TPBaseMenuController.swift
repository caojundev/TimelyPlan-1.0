//
//  TPBaseMenuController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/6/25.
//

import Foundation

class TPBaseMenuController<T: Hashable & TPMenuRepresentable> {

    /// 菜单内容宽度
    var menuContentWidth: CGFloat = 200.0
    
    /// 首选位置
    var preferredPosition: TPPopoverPosition = .bottomLeft
    
    /// 允许位置
    var permittedPositions: [TPPopoverPosition] = [.bottomLeft,
                                                 .bottomRight,
                                                 .topLeft,
                                                 .topRight]
    
    /// 当前选中菜单动作类型
    var selectedMenuActionType: T?
    
    /// 选中菜单动作类型
    var didSelectMenuActionType: ((T) -> Void)?
    
    /// 允许的菜单动作类型数组
    func allowMenuActionTypes() -> [T] {
        return T.allCases as! [T]
    }

    /// 获取按顺序排列的菜单条目
    private func menuItems(for actionTypes: [T]) -> [TPMenuItem] {
        var showLists = [Array<T>]()
        let typeLists = orderedMenuActionTypeLists()
        for actionTypelist in typeLists {
            var displayActionList = [T]()
            for actionType in actionTypelist {
                if actionTypes.contains(actionType) {
                    displayActionList.append(actionType)
                }
            }
            
            if displayActionList.count > 0 {
                showLists.append(displayActionList)
            }
        }
        
        let menuItems = TPMenuItem.items(with: showLists) { type, action in
            self.updateMenuAction(action, for: type)
        }
        
        return menuItems
    }
    
    func updateMenuAction(_ action: TPMenuAction, for type: T) {
        action.isChecked = self.selectedMenuActionType == type
    }

    // MARK: - 任务菜单
    func menuItems() -> [TPMenuItem] {
        let actionTypes = menuActionTypes()
        let allowedTypes = allowMenuActionTypes()
        let displayTypes = Set(actionTypes).intersection(allowedTypes)
        return menuItems(for: Array(displayTypes))
    }
    
    // MARK: - 子类重写
    /// 有序的菜单动作类型列表，菜单会按照该列表中的顺序进行展示
    func orderedMenuActionTypeLists() -> [Array<T>] {
        return [Array(T.allCases)]
    }
    
    /// 返回当前菜单的类型
    func menuActionTypes() -> [T] {
        return T.allCases as! [T]
    }
    
    // MARK: - 显示菜单
    func showMenu(from sourceView: UIView,
                  sourceRect: CGRect? = nil,
                  isCovered: Bool = true) {
        let menuItems = menuItems()
        if menuItems.count == 0 {
            return
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = menuContentWidth
        menuList.menuItems = menuItems
        menuList.didSelectMenuAction = { action in
            var actionType: T?
            if T.RawValue.self == Int.self {
                actionType = T(rawValue: action.tag as! T.RawValue)
            } else if T.RawValue.self == String.self {
                actionType = T(rawValue: action.identifier as! T.RawValue)
            }
        
            guard let actionType = actionType else {
                return
            }
            
            self.didSelectMenuActionType?(actionType)
        }
    
        menuList.popoverShow(from: sourceView,
                            sourceRect: sourceRect,
                            isSourceViewCovered: isCovered,
                            preferredPosition: .bottomLeft,
                            permittedPositions: permittedPositions,
                            animated: true,
                            completion: nil)
    }
}
