//
//  GoalTaskEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/2.
//

import Foundation
import UIKit

/// 目标任务权重选项（1～10）
enum GoalTaskWeightOption: Int, Codable, TPMenuRepresentable {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    
    var title: String {
        return "\(rawValue)"
    }
    
    /// 根据权重数值获取选项
    static func option(for weight: Int64) -> GoalTaskWeightOption? {
        guard weight >= 1, weight <= 10 else {
            return nil
        }
        
        return GoalTaskWeightOption(rawValue: Int(weight))
    }
}

class GoalTaskEditViewController: TPTableSectionsViewController {
    
    struct Config {
        static let sectionHeaderPadding = UIEdgeInsets(top: 15.0,
                                                       left: 0.0,
                                                       bottom: 0.0,
                                                       right: 16.0)
        static let sectionTitleHeaderHeight = 50.0
        static let sectionNormalHeaderHeight = 20.0
        static let defaultCellHeight = 50.0
    }
    
    /// 结束编辑
    var didEndEditing: ((GoalEditingTask) -> Void)?
    
    /// 编辑类型
    var editType: EditType = .create
    
    /// 当前编辑的任务
    var editingTask: GoalEditingTask
    
    
    // MARK: - 名称
    /// 名称单元格条目
    lazy var nameCellItem: TPTextFieldTableCellItem = { [weak self] in
        let cellItem = TPTextFieldTableCellItem()
        cellItem.clearButtonMode = .whileEditing
        cellItem.textAlignment = .left
        cellItem.font = BOLD_BODY_FONT
        cellItem.selectAllAtBeginning = true
        cellItem.placeholder = resGetString("Enter task name")
        cellItem.updater = {
            self?.nameCellItem.text = self?.editingTask.name
        }

        cellItem.editingChanged = { textField in
            self?.editingTask.name = textField.text?.whitespacesAndNewlinesTrimmedString
            self?.updateDoneButtonEnabled()
        }

        return cellItem
    }()
    
    /// 名称和颜色编辑区块
    lazy var nameSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 5.0
        sectionController.footerItem.height = 0.0
        sectionController.cellItems = [nameCellItem]
        return sectionController
    }()
    
    // MARK: - 数值
    /// 开始数值
    lazy var initialValueCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.title = resGetString("Initial Value")
        cellItem.fieldCornerRadius = 12.0
        cellItem.updater = {
            guard let self = self else { return }
            self.initialValueCellItem.number = NSNumber(value: self.editingTask.initialValue)
        }
        
        cellItem.didEndEditing = { [weak self] number in
            self?.editingTask.initialValue = number.int64Value
        }
        
        return cellItem
    }()
    
    /// 目标数值
    lazy var targetValueCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.title = resGetString("Target Value")
        cellItem.fieldCornerRadius = 12.0
        cellItem.updater = {
            guard let self = self else { return }
            self.targetValueCellItem.number = NSNumber(value: self.editingTask.targetValue)
        }
        
        cellItem.didEndEditing = { [weak self] number in
            self?.editingTask.targetValue = number.int64Value
        }
        
        return cellItem
    }()
    
    /// 数值区块
    lazy var valueSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.sectionTitleHeaderHeight
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.headerItem.title = resGetString("Value")
        sectionController.setupSeparatorFooterItem(backgroundColor: .systemBackground)
        sectionController.cellItems = [initialValueCellItem, targetValueCellItem]
        return sectionController
    }()
    
    // MARK: - 计算方式
    /// 计算方式
    lazy var calculationCellItem: TPSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPSegmentedMenuTableCellItem()
        cellItem.title = resGetString("Calculation")
        cellItem.cornerRadius = 12.0
        cellItem.menuPadding = UIEdgeInsets(value: 2.0)
        cellItem.menuItems = GoalProgressCalculation.segmentedMenuItems(style: .title)
        cellItem.updater = {
            guard let self = self else { return }
            self.calculationCellItem.selectedMenuTag = self.editingTask.calculation.tag
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            guard let calculation = GoalProgressCalculation(rawValue: menuItem.tag) else {
                return
            }
            
            self?.setCalculation(calculation)
        }
        
        return cellItem
    }()
    
    /// 计算区块
    lazy var calculationSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.sectionTitleHeaderHeight
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.headerItem.title = resGetString("Progress")
        sectionController.cellItems = [calculationCellItem]
        sectionController.setupSeparatorFooterItem(backgroundColor: .systemBackground)
        return sectionController
    }()
    
    // MARK: - 记录方式
    /// 记录方式
    lazy var recordTypeCellItem: TPSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPSegmentedMenuTableCellItem()
        cellItem.title = resGetString("Record Type")
        cellItem.cornerRadius = 12.0
        cellItem.menuPadding = UIEdgeInsets(value: 2.0)
        cellItem.menuItems = GoalProgressRecordType.segmentedMenuItems(style: .title)
        cellItem.updater = {
            self?.updateRecordTypeCellItem()
        }
        
        cellItem.didSelectMenuItem = { [weak self] menuItem in
            guard let recordType = GoalProgressRecordType(rawValue: menuItem.tag) else {
                return
            }
            
            self?.setRecordType(recordType)
        }
        
        return cellItem
    }()
    
    /// 自动记录数值
    lazy var autoRecordValueCellItem: TPNumberFieldLeftSymbolTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldLeftSymbolTableCellItem()
        cellItem.title = resGetString("Auto Record Value")
        cellItem.fieldPadding = UIEdgeInsets(left: 15.0, right: 10.0)
        cellItem.fieldCornerRadius = 12.0
        cellItem.updater = {
            self?.updateAutoRecordValueCellItem()
        }
        
        cellItem.didEndEditing = { [weak self] number in
            self?.editingTask.autoRecordValue = number.int64Value == 0 ? nil : Int(number.int64Value)
        }
        
        return cellItem
    }()
    
    /// 记录区块
    lazy var recordSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = 0.0
        return sectionController
    }()
    
    // MARK: - 时间
    /// 日期区间
    lazy var dateRangeCellItem: TaskDateRangeEditTableCellItem = { [weak self] in
        let cellItem = TaskDateRangeEditTableCellItem()
        cellItem.canDeleteEnd = false
        cellItem.updater = {
            guard let self = self else { return }
            self.dateRangeCellItem.dateRange = self.editingTask.dateRange
        }
        
        cellItem.didEndEditing = { [weak self] dateRange in
            self?.editingTask.dateRange = dateRange
        }
        
        return cellItem
    }()
    
    /// 时间区块
    lazy var dateSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.sectionTitleHeaderHeight
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.headerItem.title = resGetString("Date Range")
        sectionController.cellItems = [dateRangeCellItem]
        return sectionController
    }()
    
    // MARK: - 选项
    /// 是否添加到我的一天
    lazy var isAddedToMyDayCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.height = Config.defaultCellHeight
        cellItem.title = resGetString("Add to My Day")
        cellItem.updater = {
            guard let self = self else { return }
            self.isAddedToMyDayCellItem.isOn = self.editingTask.isAddedToMyDay
        }
        
        cellItem.valueChanged = { [weak self] isOn in
            self?.editingTask.isAddedToMyDay = isOn
        }
        
        return cellItem
    }()
    
    /// 权重
    lazy var weightCellItem: TPImageInfoTextValueTableCellItem = { [weak self] in
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.autoResizable = false
        cellItem.height = Config.defaultCellHeight
        cellItem.title = resGetString("Weight")
        cellItem.updater = {
            guard let self = self else { return }
            self.weightCellItem.valueConfig = .valueText("\(self.editingTask.weight)")
        }
        
        cellItem.didSelectHandler = { [weak self] in
            self?.editWeight()
        }
        
        return cellItem
    }()
    
    /// 选项区块
    lazy var optionSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.sectionTitleHeaderHeight
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.headerItem.title = resGetString("Options")
        sectionController.setupSeparatorFooterItem(backgroundColor: .systemBackground)
        sectionController.cellItems = [isAddedToMyDayCellItem, weightCellItem]
        return sectionController
    }()
    
    // MARK: - 备注
    lazy var noteSectionController: TPNoteTableSectionController = { [weak self] in
        let sectionController = TPNoteTableSectionController()
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.noteCellItem.updater = {
            self?.noteSectionController.note = self?.editingTask.note
        }
        
        sectionController.noteEditingChanged = { [weak self] note in
            self?.editingTask.note = note
        }
        
        return sectionController
    }()
    
    // MARK: - Initialization
    init(goalTask: GoalEditingTask? = nil) {
        if let goalTask = goalTask {
            self.editingTask = goalTask
            self.editType = .modify
        } else {
            self.editingTask = GoalEditingTask()
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
        self.updateTitle()
        self.updateRecordSectionController()
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [nameSectionController,
                                   
                                   valueSectionController,
                                   calculationSectionController,
                                   recordSectionController,
                                   dateSectionController,
                                   optionSectionController,
                                   noteSectionController]
        self.adapter.reloadData()
        updateDoneButtonEnabled()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    func updateTitle() {
        if editType == .create {
            self.title = resGetString("Create Goal Task")
        } else {
            self.title = resGetString("Edit Goal Task")
        }
    }
    
    override func clickDone() {
        UIResponder.resignCurrentFirstResponder()
        self.didEndEditing?(self.editingTask)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func handleFirstAppearance() {
        /// 当前目标名称为空，开始编辑名称
        beginNameEditingIfNeeded()
    }
    
    /// 任务名称是否为空
    var isEmptyName: Bool {
        if let name = self.editingTask.name?.whitespacesAndNewlinesTrimmedString, name.count > 0 {
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
    
    // MARK: - Update
    /// 更新记录区块
    private func updateRecordSectionController() {
        guard editingTask.calculation != .update else {
            recordSectionController.cellItems = nil
            return
        }
        
        let recordType = editingTask.recordType
        var recordCellItems: [TPBaseTableCellItem] = [recordTypeCellItem]
        if recordType == .auto {
            recordCellItems.append(autoRecordValueCellItem)
        }
        
        recordSectionController.cellItems = recordCellItems
    }
    
    /// 更新记录类型单元格
    func updateRecordTypeCellItem() {
        recordTypeCellItem.selectedMenuTag = editingTask.recordType.tag
        recordTypeCellItem.isDisabled = editingTask.calculation == .update
    }
    
    /// 更新自动记录数值单元格
    private func updateAutoRecordValueCellItem() {
        autoRecordValueCellItem.leftSymbol = editingTask.targetValue >= editingTask.initialValue ? "+" : "-"
        
        var autoRecordValue = editingTask.autoRecordValue ?? 1
        if autoRecordValue <= 0 {
            autoRecordValue = 1
        }
        
        autoRecordValueCellItem.number = NSNumber(value: autoRecordValue)
    }
    
    // MARK: - Event Response
    /// 设置计算方式
    func setCalculation(_ calculation: GoalProgressCalculation) {
        guard editingTask.calculation != calculation else {
            return
        }
        
        editingTask.calculation = calculation
        if calculation == .update {
            editingTask.recordType = .manual
        }
        
        updateRecordSectionController()
        adapter.performSectionUpdate(forSectionObject: recordSectionController, rowAnimation: .top)
    }
    
    /// 设置记录方式
    func setRecordType(_ recordType: GoalProgressRecordType) {
        guard editingTask.recordType != recordType else {
            return
        }
        
        editingTask.recordType = recordType
        if recordType == .manual {
            editingTask.autoRecordValue = nil
        }
        
        updateRecordSectionController()
        adapter.performSectionUpdate(forSectionObject: recordSectionController, rowAnimation: .top)
    }
    
    /// 编辑权重
    private func editWeight() {
        guard let cell = adapter.cellForItem(weightCellItem) else {
            return
        }
        
        let currentOption = GoalTaskWeightOption.option(for: editingTask.weight)
        let menuVC = TPMenuPickerViewController<GoalTaskWeightOption>(menuItems: GoalTaskWeightOption.allCases,
                                                                      selectedItem: currentOption)
        menuVC.didPickItem = { [weak self] option in
            guard let self = self else {
                return
            }
            
            if self.editingTask.weight != Int64(option.rawValue) {
                self.editingTask.weight = Int64(option.rawValue)
                self.adapter.reloadCell(forItem: self.weightCellItem, with: .none)
            }
        }
        
        menuVC.popoverShow(from: cell,
                           sourceRect: cell.bounds,
                           isSourceViewCovered: false,
                           preferredPosition: .bottomLeft,
                           animated: true,
                           completion: nil)
    }
}
