//
//  SettingsViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2023/7/21.
//

import Foundation
import UIKit

class AppSettingsViewController: TPTableSectionsViewController,
                                 TPSidebarContent {
    
    /// 侧边栏管理器
    var sidebarController: SidebarController?
    
    /// 震动反馈
    lazy var hapticFeedbackCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.title = resGetString("Haptic Feedback")
        cellItem.updater = {
            let isOn = AppSetting.shared.isHapiticFeedbackOn
            self?.hapticFeedbackCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            AppSetting.shared.isHapiticFeedbackOn = isOn
            TPImpactFeedback.feedback.enabled = isOn
        }
        
        return cellItem
    }()
    
     lazy var generalSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = 10.0
         sectionController.cellItems = [hapticFeedbackCellItem]
         return sectionController
     }()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Settings")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        
        self.sectionControllers = [generalSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
}
