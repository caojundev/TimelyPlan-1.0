//
//  TodoSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/13.
//

import Foundation
import UIKit

class TodoSettingViewController: TPTableSectionsViewController {
    
    /// 自动完成子步骤
    lazy var autoCompleteSubtasksCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem(autoResizable: true)
        cellItem.title = resGetString("Auto-complete subtasks")
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
        cellItem.title = resGetString("Auto-complete parent")
        cellItem.subtitle = resGetString("When all subtasks are done")
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
        self.sectionControllers = [stepSectionController]
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
