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
    
    lazy var imageConfig: TPImageAccessoryConfig = {
        var config = TPImageAccessoryConfig()
        config.shouldRenderImageWithColor = false
        config.size = .size(8)
        return config
    }()
    
    /// 震动反馈
    lazy var hapticFeedbackCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_hapticFeedback_32"
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
            cellItem.imageConfig = imageConfig
            cellItem.imageName = menuType.iconName
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
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_rate_32"
        cellItem.title = resGetString("Rate Us")
        cellItem.didSelectHandler = { [weak self] in
            self?.writeReview()
        }
        
        return cellItem
    }()
    
    lazy var shareCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_share_32"
        cellItem.title = resGetString("Share with Friends")
        cellItem.didSelectHandler = { [weak self] in
            self?.shareApp()
        }
        
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
    lazy var aboutCellItem: TPImageInfoTextValueTableCellItem = {
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_abount_32"
        cellItem.title = resGetString("About")
        
        var valueConfig: TPTextAccessoryConfig = .valueText("V\(Bundle.main.releaseVersion)")
        valueConfig.valueMargins = UIEdgeInsets(right: 16.0)
        cellItem.valueConfig = valueConfig
        cellItem.didSelectHandler = { [weak self] in
            self?.clickAbount()
        }
        
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
    
    private func writeReview() {
        if let reviewURL = URL(string: AppConfig.reviewLink) {
            UIApplication.shared.open(reviewURL,
                                      options: [:],
                                      completionHandler: nil)
        }
    }
    
    private func shareApp() {
        guard let shareURL = URL(string: AppConfig.detailLink) else { return }
        let shareText = resGetString("Timely Plan: To-do · Matrix · Focus Timer — one app does it all 🚀")
        let activityItems: [Any] = [shareText, shareURL]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            .saveToCameraRoll,
            .print,
            .addToReadingList
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let sourceView = adapter.cellForItem(shareCellItem)
            activityVC.popoverPresentationController?.sourceView = sourceView
            activityVC.popoverPresentationController?.sourceRect = sourceView?.bounds ?? .zero
        }
        
        present(activityVC, animated: true)
    }

    private func clickAbount() {
    #if DEBUG
        let previewVC = LocalNotificationPreviewViewController()
        navigationController?.pushViewController(previewVC, animated: true)
    #endif
    }
}
