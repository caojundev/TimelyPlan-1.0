//
//  TodoListEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/3/2.
//

import Foundation
import UIKit

class TodoListEditViewController: TPTableSectionsViewController {

    /// 结束编辑回调
    var didEndEditing: ((TodoEditingList, TodoList?) -> Void)?
    
    /// 编辑类型
    let editType: EditType
    
    /// 清单对象
    private(set) var list: TodoList?

    /// 父清单
    private(set) var parentList: TodoList?
    
    /// 当前编辑数据信息
    private(set) var editingList: TodoEditingList
    
    /// 名称和颜色编辑区块
    lazy var nameColorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [nameCellItem, colorCellItem]
        return sectionController
    }()
    
    /// 名称单元格条目
    lazy var nameCellItem: TodoListEmojiNameEditCellItem = { [weak self] in
        let cellItem = TodoListEmojiNameEditCellItem()
        cellItem.clearButtonMode = .whileEditing
        cellItem.textAlignment = .left
        cellItem.font = BOLD_SYSTEM_FONT
        cellItem.selectAllAtBeginning = false
        cellItem.placeholder = resGetString("Enter list name")
        cellItem.updater = {
            self?.updateNameCellItem()
        }
        
        cellItem.editingChanged = { textField in
            self?.editingList.name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.updateDoneButtonEnabled()
        }
        
        cellItem.emojiDidChange = { emoji in
            self?.editingList.emoji = emoji?.stringValue
        }
        
        return cellItem
    }()
    
    /// 颜色单元格条目
    lazy var colorCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.height = 64.0
        cellItem.circleSize = CGSize(width: 36.0, height: 36.0)
        cellItem.updater = {
            self?.colorCellItem.selectedColor = self?.editingList.color
        }
        
        cellItem.didSelectColor = { color in
            self?.didSelectColor(color)
        }
        
        return cellItem
    }()
    

    /// 父清单
    lazy var parentCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageName = "todo_list_parent_24"
        cellItem.title = resGetString("Parent List")
        cellItem.updater = {
            let valueText: String
            if let parentList = self?.parentList {
                valueText = parentList.name ?? resGetString("Untitled List")
            } else {
                valueText = resGetString("None")
            }
            
            self?.parentCellItem.valueConfig = .valueText(valueText)
        }
        
        cellItem.didSelectHandler = {
            self?.selectParentList()
        }
        
        return cellItem
    }()
    
    lazy var parentSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 20.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [parentCellItem]
        return sectionController
    }()
    
    /// 布局
    lazy var layoutCellItem: TPFullSizeSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPFullSizeSegmentedMenuTableCellItem()
        cellItem.minimumButtonWidth = 120.0
        cellItem.height = 140.0
        cellItem.backgroundColor = .clear
        cellItem.selectedBackgroundColor = .clear
        cellItem.imagePosition = .top
        cellItem.segmentedImageConfig.size = .size(24)
        cellItem.segmentedImageConfig.color = resGetColor(.title)
        cellItem.segmentedImageConfig.selectedColor = .primary
        cellItem.segmentedTitleConfig.textColor = resGetColor(.title)
        cellItem.segmentedTitleConfig.selectedTextColor = .primary
        cellItem.menuItems = TodoListLayoutType.segmentedMenuItems()
        cellItem.updater = {
            let layoutType = self?.editingList.layoutType ?? .list
            self?.layoutCellItem.selectedMenuTag = layoutType.tag
        }
        
        cellItem.didSelectMenuItem = { menuItem in
            let layoutType: TodoListLayoutType? = menuItem.actionType()
            if let layoutType = layoutType {
                self?.selectLayoutType(layoutType)
            }
        }
        
        return cellItem
    }()
    
    lazy var layoutSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.title = resGetString("Layout")
        sectionController.headerItem.height = 50.0
        sectionController.headerItem.padding = UIEdgeInsets(horizontal: 16.0, top: 10.0)
        sectionController.cellItems = [layoutCellItem]
        return sectionController
    }()
    
    init(list: TodoList? = nil, parent: TodoList? = nil) {
        self.list = list
        self.parentList = parent
        self.editingList = list?.editingList ?? TodoEditingList()
        self.editType = list == nil ? .create : .modify
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        navigationItem.rightBarButtonItem = doneBarButtonItem
        if editType == .create {
            title = resGetString("New List")
        } else {
            title = resGetString("Edit List")
        }
        
        self.doneAction.style.cornerRadius = 12.0
        self.sectionControllers = [nameColorSectionController,
                                   parentSectionController,
                                   layoutSectionController]
        self.adapter.reloadData()
        self.updateDoneButtonEnabled()
    }
    
    override func handleFirstAppearance() {
        beginNameEditingIfNeeded()
        scrollSelectedColorToVisible()
    }
    
    override func clickDone() {
        didEndEditing?(editingList, parentList)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Update CellItem
    func updateNameCellItem() {
        updateNameCellItemColor()
        nameCellItem.text = editingList.name
        nameCellItem.emoji = editingList.emoji
        nameCellItem.placeholderImage = resGetImage(editingList.layoutType.miniIconName)
    }
    
    func updateNameCellItemColor() {
        nameCellItem.foreColor = editingList.color
    }
    
    // MARK: - 名称
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = editingList.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
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
        editingList.name = name
        updateDoneButtonEnabled()
    }
    
    /// 颜色
    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
    
    func didSelectColor(_ color: UIColor) {
        editingList.color = color
        
        /// 更新名称编辑单元格颜色
        updateNameCellItemColor()
        if let cell = adapter.cellForItem(nameCellItem) as? TodoListNameEmojiEditCell {
            cell.updateColor(nameCellItem.foreColor)
        }
    }
    
    ///  选择列表
    func selectParentList() {
//        let allowMaxDepth = TodoList.parentMaxDepth(for: self.list)
//        let vc = TodoListMoveViewController(mode: .parent,
//                                            list: parentList,
//                                            allowMaxDepth: allowMaxDepth)
//        if let list = list {
//            vc.disabledLists = [list]
//        }
//
//        vc.didSelectList = { selectedList in
//            self.parentList = selectedList as? TodoList
//            self.adapter.reloadCell(forItem: self.parentCellItem)
//        }
//
//        let navController = UINavigationController(rootViewController: vc)
//        navController.modalPresentationStyle = .formSheet
//        navController.show()
    }
    
    
    /// 选择布局类型
    func selectLayoutType(_ type: TodoListLayoutType) {
        editingList.layoutType = type
        adapter.reloadCell(forItem: nameCellItem, with: .none)
    }
    
}

