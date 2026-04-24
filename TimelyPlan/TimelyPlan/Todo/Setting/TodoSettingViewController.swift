//
//  TodoSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/13.
//

import Foundation
import UIKit

class TodoSettingViewController: TPTableSectionsViewController {
    
    let defaultCellHeight = 55.0
    
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
        cellItem.title = resGetString("Smart Lists")
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
        let cellItem = TPSwitchTableCellItem(autoResizable: true)
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
        let cellItem = TPSwitchTableCellItem(autoResizable: true)
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
     
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Settings")
        self.navigationItem.leftBarButtonItems = [chevronDownCancelButtonItem]
        self.sectionControllers = [displaySectionController,
                                   insertLocationSectionController,
                                   quickAddSectionController,
                                   stepSectionController]
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func showHomeDisplaySettings() {
        let vc = TodoHomeDisplaySettingViewController(style: .insetGrouped)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showSmartListDisplaySettings() {
        
    }
}
