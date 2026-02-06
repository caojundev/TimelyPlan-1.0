//
//  CalendarModeBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/30.
//

import Foundation

class CalendarModeBarButtonItem: UIBarButtonItem {
    
    /// 选中菜单类型
    var didSelectMode: ((CalendarMode) -> Void)?
    
    /// 模式
    var mode: CalendarMode = .week {
        didSet {
            if mode != oldValue {
                updateButton()
            }
        }
    }
    
    private lazy var button: TPMenuListButton = { [weak self] in
        let button = TPMenuListButton()
        button.padding = UIEdgeInsets(horizontal: 5.0)
        button.imageConfig.color = resGetColor(.title)
        button.didSelectMenuAction = { action in
            guard let mode: CalendarMode = action.actionType() else {
                return
            }
            
            self?.didSelectMode?(mode)
        }
        
        return button
    }()
    
    override init() {
        super.init()
        self.customView = button
        self.updateButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateButton() {
        let currentMode = mode
        let menuItem = TPMenuItem.item(with: CalendarMode.allCases) { mode, action in
            action.handleBeforeDismiss = true
            action.isChecked = mode == currentMode
        }
        
        button.menuItems = [menuItem]
        button.image = mode.iconImage
        button.sizeToFit()
    }
}
