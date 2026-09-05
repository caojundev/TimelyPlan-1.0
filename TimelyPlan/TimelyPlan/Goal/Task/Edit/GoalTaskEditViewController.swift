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
        static let sectionHeaderPadding = UIEdgeInsets(top: 12.0,
                                                       left: 12.0,
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
    
    /// 进入编辑页时的初始任务（用于判断是否发生了修改）
    private let initialEditingTask: GoalEditingTask
    
    /// 是否存在未保存的修改
    var hasUnsavedChanges: Bool {
        return editingTask != initialEditingTask
    }
    
    // MARK: - 名称
    /// 名称单元格条目
    lazy var nameCellItem: GoalTaskColorNameEditCellItem = { [weak self] in
        let cellItem = GoalTaskColorNameEditCellItem()
        cellItem.clearButtonMode = .whileEditing
        cellItem.textAlignment = .left
        cellItem.font = BOLD_BODY_FONT
        cellItem.selectAllAtBeginning = true
        cellItem.placeholder = resGetString("Enter task name")
        cellItem.updater = {
            self?.nameCellItem.text = self?.editingTask.name
            self?.nameCellItem.color = self?.editingTask.color
        }

        cellItem.onSelectColor = { color in
            self?.editingTask.color = color
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
    
    // MARK: - 步骤
    lazy var stepSectionController: GoalStepEditSectionController = {
        let steps = editingTask.steps ?? []
        let sectionController = GoalStepEditSectionController(steps: steps)
        sectionController.headerItem.height = Config.sectionNormalHeaderHeight
        sectionController.footerItem.height = 0.0
        sectionController.onStepsChanged = { [weak self] steps in
            self?.editingTask.steps = steps
        }
        
        return sectionController
    }()
    
    // MARK: - 目标
    /// 开始数值
    lazy var initialValueCellItem: TPNumberFieldTableCellItem = { [weak self] in
        let cellItem = TPNumberFieldTableCellItem()
        cellItem.title = resGetString("Initial Value")
        cellItem.fieldCornerRadius = .greatestFiniteMagnitude
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
        cellItem.fieldCornerRadius = .greatestFiniteMagnitude
        cellItem.updater = {
            guard let self = self else { return }
            self.targetValueCellItem.number = NSNumber(value: self.editingTask.targetValue)
        }
        
        cellItem.didEndEditing = { [weak self] number in
            self?.editingTask.targetValue = number.int64Value
        }
        
        return cellItem
    }()
    
    /// 计算方式
    lazy var calculationCellItem: TPSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPSegmentedMenuTableCellItem()
        cellItem.title = resGetString("Calculation")
        cellItem.cornerRadius = .greatestFiniteMagnitude
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
    
    /// 记录方式
    lazy var recordTypeCellItem: TPSegmentedMenuTableCellItem = { [weak self] in
        let cellItem = TPSegmentedMenuTableCellItem()
        cellItem.title = resGetString("Record Type")
        cellItem.cornerRadius = .greatestFiniteMagnitude
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
        cellItem.fieldCornerRadius = .greatestFiniteMagnitude
        cellItem.updater = {
            self?.updateAutoRecordValueCellItem()
        }
        
        cellItem.didEndEditing = { [weak self] number in
            self?.editingTask.autoRecordValue = number.int64Value == 0 ? nil : Int(number.int64Value)
        }
        
        return cellItem
    }()
    
    /// 进度区块
    lazy var progressSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.sectionNormalHeaderHeight
        sectionController.cellItems = [initialValueCellItem,
                                        targetValueCellItem,
                                        calculationCellItem]
        return sectionController
    }()
    
    // MARK: - 计划
    /// 计划区块
    lazy var scheduleSectionController: GoalTaskScheduleEditSectionController = { [weak self] in
        let sectionController = GoalTaskScheduleEditSectionController()
        sectionController.dateRange = editingTask.dateRange
        sectionController.startTime = editingTask.startTime
        sectionController.duration = editingTask.duration
        sectionController.headerItem.height = Config.sectionNormalHeaderHeight
        sectionController.dateRangeDidChange = { dateRange in
            self?.editingTask.dateRange = dateRange
        }
        
        sectionController.onStartTimeChanged = { startTime in
            self?.editingTask.startTime = startTime
        }
        
        sectionController.onDurationChanged = { duration in
            self?.editingTask.duration = duration
        }
        
        return sectionController
    }()
    
    /// 提醒
    lazy var reminderSectionController: ScheduledReminderEditSectionController = {
        let sectionController = ScheduledReminderEditSectionController()
        sectionController.headerItem.title = nil
        sectionController.headerItem.height = Config.sectionNormalHeaderHeight
        sectionController.headerItem.padding = Config.sectionHeaderPadding
        sectionController.shouldRemind = editingTask.shouldRemind
        if let reminder = editingTask.reminder {
            sectionController.reminder = reminder
        }

        sectionController.shouldRemindDidChange = { [weak self] shouldRemind in
            self?.editingTask.shouldRemind = shouldRemind
        }
        
        sectionController.reminderDidChange = { [weak self] reminder in
            self?.editingTask.reminder = reminder
        }
        
        return sectionController
    }()
    
    /// 我的一天
    lazy var myDaySectionController: MyDayEditSectionController = { [weak self] in
        let sectionController = MyDayEditSectionController()
        sectionController.headerItem.height = 15.0
        sectionController.myDayCellItem.imageName = nil
        sectionController.isAddedToMyDay = editingTask.isAddedToMyDay
        sectionController.onAddToMyDayValueChanged = { isAddedToMyDay in
            self?.editingTask.isAddedToMyDay = isAddedToMyDay
        }
        
        return sectionController
    }()
    
    // MARK: - 权重
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
    
    /// 权重区块
    lazy var weightSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = Config.sectionNormalHeaderHeight
        sectionController.cellItems = [weightCellItem]
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
        self.initialEditingTask = self.editingTask
        
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
        /// 尽早尝试绑定 presentation controller；若此时尚未就绪，首次 viewDidAppear 时会再次绑定
        configureDismissInterception()
        self.updateTitle()
        self.updateProgressSectionController()
        self.adapter.cellStyle.backgroundColor = .secondarySystemGroupedBackground
        self.sectionControllers = [nameSectionController,
                                   stepSectionController,
                                   weightSectionController,
                                   progressSectionController,
                                   scheduleSectionController,
                                   reminderSectionController,
                                   myDaySectionController,
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
            self.title = resGetString("New Goal Task")
        } else {
            self.title = resGetString("Edit Goal Task")
        }
    }
    
    override func clickDone() {
        UIResponder.resignCurrentFirstResponder()
        self.didEndEditing?(self.editingTask)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 点击导航栏左侧取消按钮（放弃并退出）
    override func didClickCancel() {
        TPImpactFeedback.impactWithSoftStyle()
        UIResponder.resignCurrentFirstResponder()
        requestDiscardIfNeeded()
    }
    
    /// 判断是否需要弹窗提示，并放弃未保存的修改
    private func requestDiscardIfNeeded() {
        guard hasUnsavedChanges else {
            dismiss(animated: true, completion: nil)
            return
        }
        
        let cancelAction = TPAlertAction(type: .cancel,
                                         title: resGetString("Cancel"))
        let discardAction = TPAlertAction(type: .destructive,
                                          title: resGetString("Discard"),
                                          handleBeforeDismiss: false) { [weak self] _ in
            self?.discardChanges()
        }
        
        let alertController = TPAlertController(title: resGetString("Discard Changes"),
                                                message: resGetString("Changes you made will not be saved."),
                                                actions: [cancelAction, discardAction])
        alertController.show()
    }
    
    /// 放弃未保存的修改并退出编辑
    private func discardChanges() {
        UIResponder.resignCurrentFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    override func handleFirstAppearance() {
        /// 首次呈现完成后，presentation controller 已就绪，此时设置委托以拦截下拉 dismiss
        configureDismissInterception()
        /// 当前目标名称为空，开始编辑名称
        beginNameEditingIfNeeded()
    }
    
    /// 配置下拉交互式 dismiss 拦截。
    /// 真正被 present 的是包含本页的 UINavigationController，因此：
    /// 1. 将其 `isModalInPresentation` 设为 true，强制拦截所有交互式下拉 dismiss；
    /// 2. 把 presentation controller 的委托绑定到自己，以便收到下拉尝试的回调。
    /// 必须在本页被 present 之后调用（首次 viewDidAppear），否则 presentation controller 尚未建立。
    private func configureDismissInterception() {
        guard let navigationController = self.navigationController else {
            return
        }
        navigationController.isModalInPresentation = true
        if let presentationController = navigationController.presentationController {
            presentationController.delegate = self
        } else {
            self.presentationController?.delegate = self
        }
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
    private func updateProgressSectionController() {
        var cellItems = [initialValueCellItem,
                         targetValueCellItem,
                         calculationCellItem]
        guard editingTask.calculation != .update else {
            progressSectionController.cellItems = cellItems
            return
        }
        
        cellItems.append(recordTypeCellItem)
        
        if editingTask.recordType == .auto {
            cellItems.append(autoRecordValueCellItem)
        }
        
        progressSectionController.cellItems = cellItems
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
        
        updateProgressSectionController()
        adapter.performSectionUpdate(forSectionObject: progressSectionController, rowAnimation: .top)
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
        
        updateProgressSectionController()
        adapter.performSectionUpdate(forSectionObject: progressSectionController, rowAnimation: .top)
    }
    
    /// 编辑权重
    private func editWeight() {
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
        
        menuVC.popoverShow()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
/// 拦截下拉手势 dismiss。配合 `isModalInPresentation = true`，
/// 所有交互式下拉都会走到这里，由本方法决定是直接关闭还是弹窗确认。
extension GoalTaskEditViewController: UIAdaptivePresentationControllerDelegate {
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        TPImpactFeedback.impactWithSoftStyle()
        UIResponder.resignCurrentFirstResponder()
        // 无修改直接关闭；有修改弹窗确认是否放弃
        requestDiscardIfNeeded()
    }
}
