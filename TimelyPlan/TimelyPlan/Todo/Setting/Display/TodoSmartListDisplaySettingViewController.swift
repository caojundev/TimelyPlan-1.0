//
//  TodoSmartListDisplaySettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/25.
//

import Foundation
import UIKit

class TodoSmartListDisplaySettingViewController: TPTableSectionsViewController {
    
    private let smartListSectionController = TodoSmartListSettingSectionController()
    
    lazy var autoHideEmptyCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.imageContent = .withName("eye_slash_24")
        cellItem.title = resGetString("Auto-Hide Empty Smart List")
        cellItem.updater = {
            let isOn = self?.autoHideEmpty ?? false
            self?.autoHideEmptyCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            self?.autoHideEmpty = isOn
        }
        
        return cellItem
    }()
    
     lazy var autoHideSectionController: TPTableItemSectionController = {
         let sectionController = TPTableItemSectionController()
         sectionController.headerItem.height = 15.0
         sectionController.cellItems = [autoHideEmptyCellItem]
         return sectionController
     }()
    
    var autoHideEmpty: Bool = false
    
    var display: TodoSmartListDisplay?
    
    override init(style: UITableView.Style) {
        super.init(style: style)
        self.display = TodoSetting.shared.smartListDisplay
        self.autoHideEmpty = self.display?.autoHideEmpty ?? false
        if let hiddenListTypes = self.display?.hiddenListTypes {
            self.smartListSectionController.hiddenListTypes = hiddenListTypes
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Smart List Display")
        self.setupActionsBar(actions: [saveAction])
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.adapter.cellStyle.selectedBackgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [smartListSectionController,
                                   autoHideSectionController]
        self.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickSave() {
        let autoHideEmpty: Bool? = self.autoHideEmpty ? true : nil
        let hiddenListTypes = smartListSectionController.hiddenListTypes
        let display = TodoSmartListDisplay(autoHideEmpty: autoHideEmpty,
                                           hiddenListTypes: hiddenListTypes)
        if display != self.display {
            TodoSetting.shared.smartListDisplay = display
        }
        
        self.navigationController?.popViewController(animated: true)
    }
}

class TodoSmartListSettingSectionController: TPTableItemSectionController {
    
    var hiddenListTypes: Set<TodoSmartListType> = []
    
    let types: [TodoSmartListType] = [.completed, .overdue, .today, .tomorrow, .upcoming]
    
    override init() {
        super.init()
        self.headerItem.height = 10.0
        var cellItems: [TPSwitchTableCellItem] = []
        for type in types {
            let cellItem = TPSwitchTableCellItem()
            cellItem.identifier = type.identifier
            cellItem.imageContent = .withName(type.iconName)
            cellItem.title = type.title
            cellItem.updater = {[weak self] in
                self?.updateCellItem(for: type)
            }

            cellItem.valueChanged = {[weak self]  isOn in
                self?.switchValueChanged(for: type, isOn: isOn)
            }

            cellItems.append(cellItem)
        }
        
        self.cellItems = cellItems
    }
    
    private func cellItem(for type: TodoSmartListType) -> TPSwitchTableCellItem? {
        guard let cellItems = self.cellItems else {
            return nil
        }
        
        for cellItem in cellItems {
            if cellItem.identifier == type.identifier {
                return cellItem as? TPSwitchTableCellItem
            }
        }
        
        return nil
    }
    
    private func updateCellItem(for type: TodoSmartListType) {
        guard let cellItem = cellItem(for: type) else {
            return
        }
        
        cellItem.isOn = !hiddenListTypes.contains(type)
    }
    
    private func switchValueChanged(for type: TodoSmartListType, isOn: Bool) {
        if isOn {
            hiddenListTypes.remove(type)
        } else {
            hiddenListTypes.insert(type)
        }
    }
}
