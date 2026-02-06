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

class QuadrantMoreBarButtonItem: UIBarButtonItem {
    
    /// 选中菜单类型
    var didSelectType: ((QuadrantMoreMenuType) -> Void)?
    
    override init() {
        super.init()
        let button = QuadrantMoreButton()
        button.didSelectMenuAction = {[weak self] action in
            guard let type: QuadrantMoreMenuType = action.actionType() else {
                return
            }
            
            self?.didSelectType?(type)
        }
        
        self.customView = button
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private class QuadrantMoreButton: TPMenuListButton {
    
    override var menuItems: [TPMenuItem]? {
        get {
            let menuItem = TPMenuItem.item(with: QuadrantMoreMenuType.allCases) {[weak self] type, action in
                self?.updateMenuAction(action, for: type)
            }
            
            return [menuItem]
        }
        
        set {}
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.menuContentWidth = 240.0
        self.padding = UIEdgeInsets(horizontal: 5.0)
        self.image = resGetImage("ellipsis_24")
        self.imageConfig.color = resGetColor(.title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateMenuAction(_ action: TPMenuAction, for type: QuadrantMoreMenuType) {
        switch type {
        case .showCompleted:
            action.isChecked = QuadrantSettingAgent.shared.showCompleted
        case .showDetail:
            action.isChecked = QuadrantSettingAgent.shared.showDetail
        default:
            break
        }
    }
}
