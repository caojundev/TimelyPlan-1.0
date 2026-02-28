//
//  TPBaseMoreBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/28.
//

import Foundation

/// 通用的更多按钮基类
class TPBaseMoreBarButtonItem<MenuType: TPMenuRepresentable>: UIBarButtonItem {
    
    /// 选中菜单类型的回调
    var didSelectType: ((MenuType) -> Void)?
    
    private lazy var button: TPMenuListButton = {
        let button = TPMenuListButton()
        button.padding = UIEdgeInsets(horizontal: 8.0)
        button.imageConfig.color = resGetColor(.title)
        button.didSelectMenuAction = { [weak self] action in
            self?.selectMenuAction(action)
        }
        
        button.menuItemsProvider = { [weak self] in
            return self?.menuItems()
        }
        
        return button
    }()
    
    override init() {
        super.init()
        self.customView = button
        configButton(button)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configButton(_ button: TPMenuListButton) {
        button.image = resGetImage("ellipsis_24")
    }
    
    /// 设置菜单项
    func menuItems() -> [TPMenuItem] {
        let menuItem = TPMenuItem.item(with: Array(MenuType.allCases),
                                       updater: nil)
        return [menuItem]
    }
    
    func selectMenuAction(_ action: TPMenuAction) {
        fatalError("子类重写，确定具体选中类型")
    }
}
