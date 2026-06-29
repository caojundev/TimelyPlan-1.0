//
//  TodoSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/13.
//

import Foundation
import UIKit

class TodoSettingViewController: BaseSettingViewController {
    
    // MARK: - 显示设置
    lazy var homeDisplayCellItem: TPDefaultInfoTableCellItem = {
        let cellItem = TPDefaultInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.title = resGetString("Home")
        cellItem.didSelectHandler = { [weak self] in
            self?.showHomeDisplaySettings()
        }
        
        return cellItem
    }()

    lazy var smartListDisplayCellItem: TPDefaultInfoTableCellItem = {
        let cellItem = TPDefaultInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.title = resGetString("Smart List")
        cellItem.didSelectHandler = { [weak self] in
            self?.showSmartListDisplaySettings()
        }
        
        return cellItem
    }()

    lazy var displaySectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.title = resGetString("Display")
         sectionController.headerItem.height = 50.0
         sectionController.cellItems = [homeDisplayCellItem,
                                        smartListDisplayCellItem]
         return sectionController
     }()
    
    // MARK: - 添加位置
    /// 添加列表到顶部
    lazy var addListOnTopCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Add New List On Top")
        cellItem.updater = {
            guard let self = self else { return }
            let isOn = TodoSetting.shared.addListOnTop
            self.addListOnTopCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            TodoSetting.shared.addListOnTop = isOn
        }
        
        return cellItem
    }()
    
    /// 添加任务到顶部
    lazy var addTaskOnTopCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Add New Task On Top")
        cellItem.updater = {
            guard let self = self else { return }
            let isOn = TodoSetting.shared.addTaskOnTop
            self.addTaskOnTopCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            TodoSetting.shared.addTaskOnTop = isOn
        }
        
        return cellItem
    }()
    
    /// 添加标签到顶部
    lazy var addTagOnTopCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Add New Tag On Top")
        cellItem.updater = {
            guard let self = self else { return }
            let isOn = TodoSetting.shared.addTagOnTop
            self.addTagOnTopCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            TodoSetting.shared.addTagOnTop = isOn
        }
        
        return cellItem
    }()
    
    /// 添加过滤器到顶部
    lazy var addFilterOnTopCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Add New Filter On Top")
        cellItem.updater = {
            guard let self = self else { return }
            let isOn = TodoSetting.shared.addFilterOnTop
            self.addFilterOnTopCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            TodoSetting.shared.addFilterOnTop = isOn
        }
        
        return cellItem
    }()

    lazy var insertLocationSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.title = resGetString("New Item Location")
        sectionController.headerItem.height = 50.0
        sectionController.cellItems = [addListOnTopCellItem,
                                       addTaskOnTopCellItem,
                                       addTagOnTopCellItem,
                                       addFilterOnTopCellItem]
        return sectionController
    }()
    
    // MARK: - 快速添加
    
    lazy var quickAddKeepContentCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.title = resGetString("Keep Input Content When Hidden")
        cellItem.updater = {
            let isOn = TodoSetting.shared.quickAddKeepContentWhenHidden
            self?.quickAddKeepContentCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            TodoSetting.shared.quickAddKeepContentWhenHidden = isOn
        }
        
        return cellItem
    }()

    lazy var quickAddContinuouslyCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.title = resGetString("Add Continuously")
        cellItem.updater = {
            let isOn = TodoSetting.shared.quickAddContinuously
            self?.quickAddContinuouslyCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            TodoSetting.shared.quickAddContinuously = isOn
        }
        
        return cellItem
    }()
    
     lazy var quickAddSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.title = resGetString("Quick Add")
         sectionController.headerItem.height = 50.0
         sectionController.cellItems = [quickAddKeepContentCellItem,
                                        quickAddContinuouslyCellItem]
         return sectionController
     }()
    
    /// 自动完成子步骤
    lazy var autoCompleteSubtasksCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.autoResizable = true
        cellItem.title = resGetString("Auto-complete Substeps")
        cellItem.subtitle = resGetString("When parent is done")
        cellItem.updater = {
            let isOn = TodoSetting.shared.autoCompleteSubtasks
            self?.autoCompleteSubtasksCellItem.isOn = isOn
        }
        
        cellItem.valueChanged = { isOn in
            TodoSetting.shared.autoCompleteSubtasks = isOn
        }
        
        return cellItem
    }()
    
    /// 自动完成父步骤
    lazy var autoCompleteParentTaskCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.autoResizable = true
        cellItem.title = resGetString("Auto-complete Parent")
        cellItem.subtitle = resGetString("When all substeps are done")
        cellItem.updater = {
            let isOn = TodoSetting.shared.autoCompleteParentTask
            self?.autoCompleteParentTaskCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            TodoSetting.shared.autoCompleteParentTask = isOn
        }
        
        return cellItem
    }()
    
     lazy var stepSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.title = resGetString("Step")
         sectionController.headerItem.height = 50.0
         sectionController.cellItems = [autoCompleteSubtasksCellItem,
                                        autoCompleteParentTaskCellItem]
         return sectionController
     }()

    lazy var startSoundCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Start Sound")
        cellItem.updater = {
            let name = NotificationSound.displayName(of: TodoSetting.shared.startSound)
            self?.startSoundCellItem.valueConfig = .valueText(name)
        }
        
        cellItem.didSelectHandler = {
            self?.editStartSound()
        }

        return cellItem
    }()
    
    lazy var dueSoundCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = defaultCellHeight
        cellItem.title = resGetString("Due Sound")
        cellItem.updater = {
            let name = NotificationSound.displayName(of: TodoSetting.shared.dueSound)
            self?.dueSoundCellItem.valueConfig = .valueText(name)
        }
        
        cellItem.didSelectHandler = {
            self?.editDueSound()
        }

        return cellItem
    }()
     
     lazy var notificationSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.title = resGetString("Notification")
         sectionController.headerItem.height = titleHeaderHeight
         sectionController.headerItem.padding = titleHeaderPadding
         sectionController.cellItems = [startSoundCellItem, dueSoundCellItem]
         return sectionController
     }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Todo Settings")
        sectionControllers = [displaySectionController,
                              notificationSectionController,
                              insertLocationSectionController,
                              quickAddSectionController,
                              stepSectionController]
        reloadData()
    }
    
    private func showHomeDisplaySettings() {
        let vc = TodoHomeDisplaySettingViewController(style: .insetGrouped)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showSmartListDisplaySettings() {
        let vc = TodoSmartListDisplaySettingViewController(style: .insetGrouped)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editStartSound() {
        let vc = NotificationSoundSelectViewController(sound: TodoSetting.shared.startSound)
        vc.completion = { sound in
            if TodoSetting.shared.startSound != sound {
                TodoSetting.shared.startSound = sound
                self.adapter.reloadCell(forItem: self.startSoundCellItem, with: .none)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func editDueSound() {
        let vc = NotificationSoundSelectViewController(sound: TodoSetting.shared.dueSound)
        vc.completion = { sound in
            if TodoSetting.shared.dueSound != sound {
                TodoSetting.shared.dueSound = sound
                self.adapter.reloadCell(forItem: self.dueSoundCellItem, with: .none)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
