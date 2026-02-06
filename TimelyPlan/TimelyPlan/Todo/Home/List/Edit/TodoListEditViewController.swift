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
    var didEndEditing: ((TodoEditList, TodoFolder?) -> Void)?
    
    /// 编辑类型
    let editType: EditType
    
    /// 清单对象
    private(set) var list: TodoList?

    /// 当前编辑数据信息
    private(set) var editList: TodoEditList
    
    /// 目录
    private(set) var folder: TodoFolder?
    
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
            self?.editList.name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.updateDoneButtonEnabled()
        }
        
        cellItem.emojiDidChange = { emoji in
            self?.editList.emoji = emoji?.stringValue
        }
        
        return cellItem
    }()
    
    /// 颜色单元格条目
    lazy var colorCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.height = 64.0
        cellItem.circleSize = CGSize(width: 36.0, height: 36.0)
        cellItem.updater = {
            self?.colorCellItem.selectedColor = self?.editList.color
        }
        
        cellItem.didSelectColor = { color in
            self?.didSelectColor(color)
        }
        
        return cellItem
    }()
    
    lazy var folderSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [folderCellItem]
        return sectionController
    }()
    
    lazy var folderCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageName = "todo_folder_24"
        cellItem.title = resGetString("Folder")
        cellItem.updater = {
            self?.updateFolderCellItem()
        }
        
        cellItem.didSelectHandler = {
            self?.selectFolder()
        }
        
        return cellItem
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
            let layoutType = self?.editList.layoutType ?? .list
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
    
    init(list: TodoList? = nil, folder: TodoFolder? = nil) {
        self.list = list
        self.editList = list?.editList ?? TodoEditList()
        self.folder = folder
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
                                   folderSectionController,
                                   layoutSectionController]
        self.adapter.reloadData()
        self.updateDoneButtonEnabled()
    }
    
    override func handleFirstAppearance() {
        beginNameEditingIfNeeded()
        scrollSelectedColorToVisible()
    }
    
    override func clickDone() {
        didEndEditing?(editList, folder)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Update CellItem
    func updateNameCellItem() {
        updateNameCellItemColor()
        nameCellItem.text = editList.name
        nameCellItem.emoji = editList.emoji
        nameCellItem.placeholderImage = resGetImage(editList.layoutType.miniIconName)
    }
    
    func updateNameCellItemColor() {
        nameCellItem.foreColor = editList.color
    }
    
    func updateFolderCellItem() {
        let valueText: String
        if let folder = folder {
            valueText = folder.name ?? resGetString("Untitled Folder")
        } else {
            valueText = resGetString("None")
        }
        
        folderCellItem.valueConfig = .valueText(valueText)
    }
    
    // MARK: - 名称
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = editList.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
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
        editList.name = name
        updateDoneButtonEnabled()
    }
    
    /// 颜色
    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
    
    func didSelectColor(_ color: UIColor) {
        editList.color = color
        
        /// 更新名称编辑单元格颜色
        updateNameCellItemColor()
        if let cell = adapter.cellForItem(nameCellItem) as? TodoListNameEmojiEditCell {
            cell.updateColor(nameCellItem.foreColor)
        }
    }
    
    ///  选择目录
    func selectFolder() {
        let vc = TodoFolderSelectViewController(folder: folder)
        vc.didSelectFolder = { folder in
            self.folder = folder
            self.adapter.reloadCell(forItem: self.folderCellItem)
        }

        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 选择布局类型
    func selectLayoutType(_ type: TodoListLayoutType) {
        editList.layoutType = type
        adapter.reloadCell(forItem: nameCellItem, with: .none)
    }
    
}

