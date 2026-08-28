//
//  GanttTimeScaleBarButtonItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/24.
//

import Foundation
import UIKit

class GanttTimeScaleBarButtonItem: UIBarButtonItem {
    
    /// 选中菜单
    var didSelectScale: ((GanttTimeScale.Scale) -> Void)?
    
    /// 模式
    var scale: GanttTimeScale.Scale = GanttTimelineState.shared.scale {
        didSet {
            if scale != oldValue {
                updateButton()
            }
        }
    }
    
    private lazy var button: TPMenuListButton = { [weak self] in
        let button = TPMenuListButton()
        button.padding = UIEdgeInsets(horizontal: 5.0)
        button.imageConfig.color = resGetColor(.title)
        button.didSelectMenuAction = { action in
            guard let self = self else { return }
            guard let scale: GanttTimeScale.Scale = action.actionType() else {
                return
            }
            
            if self.scale != scale {
                self.didSelectScale?(scale)
            }
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
        let currentScale = scale
        let menuItem = TPMenuItem.item(with: GanttTimeScale.Scale.allCases) { scale, action in
            action.handleBeforeDismiss = true
            action.isChecked = scale == currentScale
        }
        
        button.menuItems = [menuItem]
        button.image = scale.iconImage
        button.sizeToFit()
    }
}

