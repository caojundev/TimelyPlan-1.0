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
    var completion: ((TodoEditingTag) -> Bool)?
    
    /// 编辑类型
    let editType: EditType
    
    /// 当前编辑标签
    private var editingTag: TodoEditingTag

    /// 名称和颜色编辑区块
    lazy var nameColorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        sectionController.footerItem.height = 0.0
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
            self?.nameCellItem.text = self?.editingTag.name
            self?.nameCellItem.imageColor = self?.editingTag.color
        }
        
        cellItem.editingChanged = { textField in
            self?.nameEditingChanged(textField.text)
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
            self?.colorCellItem.selectedColor = self?.editingTag.color
        }
        
        cellItem.didSelectColor = { color in
            self?.didSelectColor(color)
        }
        
        return cellItem
    }()
    
    private let titleViewHeight = 40.0
    
    private var titleView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig.textAlignment = .center
        return view
    }()
    
    init(tag: TodoEditingTag? = nil) {
        self.editType = tag == nil ? .create : .modify
        self.editingTag = tag ?? TodoEditingTag()
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.padding = UIEdgeInsets(horizontal: 8.0)
        if self.editType == .create {
            self.titleView.title = resGetString("New Tag")
        } else {
            self.titleView.title = resGetString("Edit Tag")
        }
        
        self.view.addSubview(self.titleView)
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.isScrollEnabled = false
        self.setupActionsBar(actions: [cancelAction, doneAction])
        self.actionsBar?.backgroundColor = .clear
        self.adapter.cellStyle.backgroundColor = .clear
        self.sectionControllers = [nameColorSectionController]
        self.adapter.reloadData()
        self.updateDoneButtonEnabled()
    }
    
    override func handleFirstAppearance() {
        beginNameEditing()
        scrollSelectedColorToVisible()
    }
    
    override var popoverContentSize: CGSize {
        let width = CGSize.Popover.contentWidth
        var height = self.view.padding.verticalLength
        height += titleViewHeight
        height += nameColorSectionController.headerItem.height
        height += nameColorSectionController.footerItem.height
        height += nameCellItem.height + colorCellItem.height
        height += actionsBarHeight
        return CGSize(width: width, height: height)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.layoutFrame()
        titleView.width = layoutFrame.width
        titleView.height = titleViewHeight
        titleView.origin = layoutFrame.origin
        
        wrapperView.width = layoutFrame.width
        if let actionsBar = actionsBar {
            wrapperView.height = actionsBar.top - titleView.bottom
        } else {
            wrapperView.height = layoutFrame.maxY - titleView.bottom
        }
        
        wrapperView.left = layoutFrame.minX
        wrapperView.top = titleView.bottom
        updatePopoverContentSize()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override func clickDone() {
        guard let completion = completion else {
            return
        }

        let success = completion(editingTag)
        if success {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - 名称
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = editingTag.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
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
        self.editingTag.name = name?.whitespacesAndNewlinesTrimmedString
        self.updateDoneButtonEnabled()
    }
    
    func didSelectColor(_ color: UIColor) {
        self.editingTag.color = color
        self.nameCellItem.updater?()
        if let cell = adapter.cellForItem(nameCellItem) as? TPImageTextFieldTableCell {
            cell.updateImageColor()
        }
    }
    
    // MARK: - 颜色
    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
}

