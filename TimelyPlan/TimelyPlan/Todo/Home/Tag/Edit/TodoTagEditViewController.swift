//
//  TodoTagEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/27.
//

import Foundation
import UIKit

class TodoTagEditViewController: TPTableSectionsViewController {

    /// 结束编辑回调
    var completion: ((TodoEditTag) -> Bool)?
    
    /// 编辑类型
    let editType: EditType
    
    /// 当前编辑标签
    private var editTag: TodoEditTag

    /// 名称和颜色编辑区块
    lazy var nameColorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        sectionController.footerItem.height = 10.0
        sectionController.cellItems = [nameCellItem, colorCellItem]
        return sectionController
    }()
    
    /// 名称单元格条目
    lazy var nameCellItem: TPImageTextFieldTableCellItem = { [weak self] in
        let cellItem = TPImageTextFieldTableCellItem()
        cellItem.height = 50.0
        cellItem.imageName = "todo_home_tag_24"
        cellItem.imageColor = resGetColor(.title)
        cellItem.clearButtonMode = .whileEditing
        cellItem.textAlignment = .left
        cellItem.font = BOLD_SYSTEM_FONT
        cellItem.selectAllAtBeginning = false
        cellItem.placeholder = resGetString("Enter tag name")
        cellItem.updater = {
            self?.nameCellItem.text = self?.editTag.name
        }
        
        cellItem.editingChanged = { textField in
            self?.editTag.name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.updateDoneButtonEnabled()
        }

        return cellItem
    }()
    
    /// 颜色单元格条目
    lazy var colorCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.height = 50.0
        cellItem.circleSize = .default
        cellItem.colors = TodoTag.colors
        cellItem.updater = {
            self?.colorCellItem.selectedColor = self?.editTag.color
        }
        
        cellItem.didSelectColor = { color in
            self?.editTag.color = color
        }
        
        return cellItem
    }()

    init(tag: TodoEditTag? = nil) {
        self.editType = tag == nil ? .create : .modify
        self.editTag = tag ?? TodoEditTag()
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if editType == .create {
            title = resGetString("New Tag")
        } else {
            title = resGetString("Edit Tag")
        }
        
        setupActionsBar(actions: [cancelAction, doneAction])
        sectionControllers = [nameColorSectionController]
        adapter.cellStyle.backgroundColor = .systemBackground
        adapter.reloadData()
        updateDoneButtonEnabled()
    }
    
    override func handleFirstAppearance() {
        beginNameEditing()
        scrollSelectedColorToVisible()
    }
    
    override var popoverContentSize: CGSize {
        let width = CGSize.Popover.contentWidth
        var height = nameColorSectionController.headerItem.height + nameColorSectionController.footerItem.height
        height += nameCellItem.height + colorCellItem.height
        height += actionsBarHeight
        return CGSize(width: width, height: height)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updatePopoverContentSize()
    }
    
    override func themeDidChange() {
        super.themeDidChange()
        actionsBar?.backgroundColor = .systemBackground
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func clickDone() {
        guard let completion = completion else {
            return
        }

        let success = completion(editTag)
        if success {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - 名称
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = editTag.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
            return false
        }
        
        return true
    }
    
    /// 更新完成按钮可用状态
    func updateDoneButtonEnabled() {
        doneAction.isEnabled = !isEmptyName
    }

    /// 开始名称编辑
    func beginNameEditing() {
        if let cell = adapter.cellForItem(nameCellItem) as? TPTextFieldTableCell {
            cell.textField.becomeFirstResponder()
        }
    }

    /// 名称编辑改变
    func nameEditingChanged(_ name: String?) {
        editTag.name = name
        updateDoneButtonEnabled()
    }
    
    // MARK: - 颜色
    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
}

