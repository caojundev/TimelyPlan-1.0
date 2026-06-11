//
//  SettingsViewController.swift
//  iTimeFlow
//
//  Created by caojun on 2023/7/21.
//

import Foundation
import UIKit

class AppSettingsViewController: BaseSettingViewController,
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
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [hapticFeedbackCellItem]
        return sectionController
    }()
    
    
    // 模块设置区块
    lazy var moduleSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        
        let menuTypes: [SideMenuType] = [.todo, .calendar, .focus, .habit]
        var cellItems = [TPImageInfoTableCellItem]()
        for menuType in menuTypes {
            let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
            cellItem.title = menuType.title
            cellItem.didSelectHandler = { [weak self] in
                self?.showSettings(for: menuType)
            }
            
            cellItems.append(cellItem)
        }
        
        sectionController.cellItems = cellItems
        return sectionController
    }()
    
    lazy var rateCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.title = resGetString("Rate Us")
        return cellItem
    }()
    
    lazy var shareCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.title = resGetString("Share with Friends")
        return cellItem
    }()
    
    lazy var supportUsSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = titleHeaderHeight
        sectionController.headerItem.padding = titleHeaderPadding
        sectionController.headerItem.title = resGetString("Support Us")
        sectionController.cellItems = [rateCellItem, shareCellItem]
        return sectionController
    }()
    
    // MARK: - 关于
    lazy var aboutCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.title = resGetString("About")
        return cellItem
    }()
    
    lazy var aboutSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [aboutCellItem]
        return sectionController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Settings")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        
        sectionControllers = [generalSectionController,
                              moduleSectionController,
                              supportUsSectionController,
                              aboutSectionController]
        reloadData()
    }

    private func showSettings(for menuType: SideMenuType) {
        var vc: BaseSettingViewController?
        switch menuType {
        case .todo:
            vc = TodoSettingViewController()
        case .calendar:
            vc = CalendarSettingViewController()
        case .focus:
            vc = FocusSettingViewController()
        case .habit:
            vc = HabitSettingViewController()
        default:
            break
        }

        if let vc = vc {
            vc.isPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
