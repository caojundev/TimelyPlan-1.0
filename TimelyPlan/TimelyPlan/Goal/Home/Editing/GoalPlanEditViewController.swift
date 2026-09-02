//
//  GoalPlanEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/31.
//

import Foundation
import UIKit

class GoalPlanEditViewController: TPTableSectionsViewController {

    struct Config {
        static let sectionHeaderPadding = UIEdgeInsets(top: 15.0,
                                                        left: 0.0,
                                                        bottom: 0.0,
                                                        right: 16.0)
        static let sectionTitleHeaderHeight = 50.0
        
        static let sectionNormalHeaderHeight = 20.0
    }
    
    /// 结束编辑
    var didEndEditing: ((GoalEditingPlan) -> Void)?
    
    /// 编辑类型
    var editType: EditType = .create
    
    /// 当前编辑计时器
    var editingPlan: GoalEditingPlan

    /// 名称单元格条目
    lazy var nameCellItem: TPTextFieldTableCellItem = { [weak self] in
        let cellItem = TPTextFieldTableCellItem()
        cellItem.clearButtonMode = .whileEditing
        cellItem.textAlignment = .left
        cellItem.font = BOLD_BODY_FONT
        cellItem.selectAllAtBeginning = true
        cellItem.placeholder = resGetString("Enter goal name")
        cellItem.updater = {
            self?.nameCellItem.text = self?.editingPlan.name
        }

        cellItem.editingChanged = { textField in
            self?.editingPlan.name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.updateDoneButtonEnabled()
        }

        return cellItem
    }()

    /// 颜色选择
    lazy var colorSelectCellItem: TPColorSelectTableCellItem = { [weak self] in
        let cellItem = TPColorSelectTableCellItem()
        cellItem.colors = GoalConfig.goalPlanColors
        cellItem.updater = {
            self?.colorSelectCellItem.selectedColor = self?.editingPlan.color
        }

        cellItem.didSelectColor = { color in
            self?.editingPlan.color = color
        }
        return cellItem
    }()
    
    /// 名称和颜色编辑区块
    lazy var nameColorSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [nameCellItem, colorSelectCellItem]
        return sectionController
    }()
    
    /// 开始日期
    lazy var dateRangeCellItem: TaskDateRangeEditTableCellItem = { [weak self] in
        let cellItem = TaskDateRangeEditTableCellItem()
        cellItem.canDeleteEnd = false
        cellItem.updater = {
            guard let self = self else { return}
            self.dateRangeCellItem.dateRange = self.editingPlan.dateRange
        }
        
        cellItem.didEndEditing = { dateRange in
            self?.editingPlan.dateRange = dateRange
        }
        
        return cellItem
    }()
    
    lazy var dateSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.sectionNormalHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [dateRangeCellItem]
        return sectionController
    }()
    
    /// 备注
    lazy var noteSectionController: TPNoteTableSectionController = { [weak self] in
        let sectionController = TPNoteTableSectionController()
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.noteCellItem.updater = {
            self?.noteSectionController.note = self?.editingPlan.note
        }

        sectionController.noteEditingChanged = { note in
            self?.editingPlan.note = note
        }

        return sectionController
    }()
    
    init(goalPlan: GoalEditingPlan? = nil) {
        if let goalPlan = goalPlan {
            self.editingPlan = goalPlan
            self.editType = .modify
        } else {
            self.editingPlan = GoalEditingPlan()
        }
        
        super.init(style: .insetGrouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = doneBarButtonItem
        self.wrapperView.isKeyboardAdjusterEnabled = true
        self.tableView.keyboardDismissMode = .onDrag
        self.updateDoneButtonEnabled()
        self.updateTitle()
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [nameColorSectionController,
                                   dateSectionController,
                                   noteSectionController]
        self.adapter.reloadData()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    func updateTitle() {
        if editType == .create {
            self.title = resGetString("Create Goal")
        } else {
            self.title = resGetString("Edit Goal")
        }
    }
    
    override func handleFirstAppearance() {
        /// 当前目标名称为空，开始编辑名称
        beginNameEditingIfNeeded()
        /// 将选中颜色滚动到可视位置
        scrollSelectedColorToVisible()
    }
    
    override func clickDone() {
        UIResponder.resignCurrentFirstResponder()
        self.didEndEditing?(self.editingPlan)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = self.editingPlan.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
            return false
        }
        
        return true
    }
    
    /// 更新完成按钮可用状态
    func updateDoneButtonEnabled() {
        doneBarButtonItem.isEnabled = isDoneButtonItemEnabled()
    }
    
    func isDoneButtonItemEnabled() -> Bool {
        guard !isEmptyName else {
            return false
        }
        
        return true
    }
    
    /// 当前名称为空时编辑名称
    func beginNameEditingIfNeeded() {
        if isEmptyName {
            beginNameEditing()
        }
    }
    
    /// 开始名称编辑
    func beginNameEditing() {
        if let cell = adapter.cellForItem(nameCellItem) as? TPTextFieldTableCell {
            cell.textField.becomeFirstResponder()
        }
    }

    func scrollSelectedColorToVisible() {
        if let cell = adapter.cellForItem(colorSelectCellItem) as? TPColorSelectTableCell {
            cell.scrollToSelectedColor(animated: true)
        }
    }
}
