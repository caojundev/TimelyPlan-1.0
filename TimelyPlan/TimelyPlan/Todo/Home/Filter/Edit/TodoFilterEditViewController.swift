//
//  TodoFilterEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/16.
//

import Foundation
import UIKit

class TodoFilterEditViewController: TodoFilterRuleEditViewController {
    
    /// 结束编辑回调
    var completion: ((TodoEditFilter) -> Void)?
    
    /// 名称和颜色编辑区块
    lazy var nameColorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [nameCellItem, colorCellItem]
        return sectionController
    }()
    
    /// 名称和颜色编辑区块
    lazy var nameCellItem: TPImageTextFieldTableCellItem = { [weak self] in
        let cellItem = TPImageTextFieldTableCellItem()
        cellItem.height = 50.0
        cellItem.imageName = "todo_home_filter_24"
        cellItem.imageColor = resGetColor(.title)
        cellItem.clearButtonMode = .whileEditing
        cellItem.textAlignment = .left
        cellItem.font = BOLD_SYSTEM_FONT
        cellItem.selectAllAtBeginning = false
        cellItem.placeholder = resGetString("Enter filter name")
        cellItem.updater = {
            self?.updateNameCellItem()
        }
        
        cellItem.editingChanged = { textField in
            self?.editFilter.name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.updateDoneButtonEnabled()
        }

        return cellItem
    }()
    
    /// 颜色单元格条目
    lazy var colorCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.colors = TodoFilter.colors
        cellItem.height = 64.0
        cellItem.circleSize = .size(8)
        cellItem.updater = {
            self?.colorCellItem.selectedColor = self?.editFilter.color
        }
        
        cellItem.didSelectColor = { color in
            self?.selectColor(color)
        }
        
        return cellItem
    }()
    

    /// 当前编辑标签
    private var editFilter: TodoEditFilter
    
    /// 编辑类型
    private let editType: EditType
    
    init(filter: TodoEditFilter? = nil) {
        self.editType = filter == nil ? .create : .modify
        self.editFilter = filter ?? TodoEditFilter()
        super.init(rule: self.editFilter.rule)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if editType == .create {
            title = resGetString("New Filter")
        } else {
            title = resGetString("Edit Filter")
        }
        
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        setupActionsBar(actions: [doneAction])
        adapter.reloadData()
        updateDoneButtonEnabled()
    }
    
    override func setupSectionControllers() {
        super.setupSectionControllers()
        sectionControllers?.insert(nameColorSectionController, at: 0)
    }
    
    override func handleFirstAppearance() {
        beginNameEditingIfNeeded()
        scrollSelectedColorToVisible()
    }
    
    override func clickDone() {
        completion?(editFilter)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Update CellItem
    func updateNameCellItem() {
        updateNameCellItemColor()
        nameCellItem.text = editFilter.name
    }
    
    func updateNameCellItemColor() {
        nameCellItem.imageColor = editFilter.color
    }
    
    // MARK: - 名称
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = editFilter.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
            return false
        }
        
        return true
    }
    
    /// 更新完成按钮可用状态
    func updateDoneButtonEnabled() {
        doneBarButtonItem.isEnabled = !isEmptyName
    }
    
    /// 当前名称为空时编辑名称
    func beginNameEditingIfNeeded() {
        if isEmptyName {
            beginNameEditing()
        }
    }
    
    /// 开始名称编辑
    func beginNameEditing() {
        if let cell = adapter.cellForItem(nameCellItem) as? TodoListNameEmojiEditCell {
            cell.textField.becomeFirstResponder()
        }
    }

    /// 名称编辑改变
    func nameEditingChanged(_ name: String?) {
        editFilter.name = name
        updateDoneButtonEnabled()
    }
    
    /// 颜色
    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
    
    func selectColor(_ color: UIColor) {
        editFilter.color = color
        /// 更新名称编辑单元格颜色
        updateNameCellItemColor()
        if let cell = adapter.cellForItem(nameCellItem) as? TPImageTextFieldTableCell {
            cell.imageColor = nameCellItem.imageColor
        }
    }
    
    override func sectionController(_ sectionController: TodoFilterRuleEditBaseSectionController, didChangeFilterRule rule: TodoFilterRule, with filterType: TodoFilterType) {
        self.editFilter.rule = rule
    }
}
