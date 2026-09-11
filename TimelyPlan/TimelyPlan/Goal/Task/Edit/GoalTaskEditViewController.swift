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
        guard isValidWeight(weight) else {
            return nil
        }
        
        return GoalTaskWeightOption(rawValue: Int(weight))
    }
    
    static func isValidWeight(_ weight: Int64) -> Bool {
        guard weight >= 1, weight <= 10 else {
            return false
        }
        
        return true
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
    
    // MARK: - 进度
    /// 进度区块
    lazy var progressSectionController: GoalTaskProgressEditSectionController = { [weak self] in
        let sectionController = GoalTaskProgressEditSectionController()
        sectionController.initialValue = editingTask.initialValue
        sectionController.targetValue = editingTask.targetValue
        sectionController.calculation = editingTask.calculation
        sectionController.recordType = editingTask.recordType
        sectionController.autoRecordValue = editingTask.autoRecordValue
        
        sectionController.onInitialValueChanged = { [weak self] value in
            self?.editingTask.initialValue = value
        }
        sectionController.onTargetValueChanged = { [weak self] value in
            self?.editingTask.targetValue = value
        }
        sectionController.onCalculationChanged = { [weak self] calculation in
            self?.editingTask.calculation = calculation
        }
        sectionController.onRecordTypeChanged = { [weak self] recordType in
            self?.editingTask.recordType = recordType
        }
        sectionController.onAutoRecordValueChanged = { [weak self] autoRecordValue in
            self?.editingTask.autoRecordValue = autoRecordValue
        }
        
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
    
    // MARK: - 所属目标计划
    struct PlanConfig {
        /// 信息视图间距
        static let infoViewEdgeMargins = UIEdgeInsets(horizontal: 16.0, vertical: 12.0)
        /// 信息视图高度
        static let infoViewHeight = 64.0
        /// 信息视图圆角
        static let infoViewCornerRadius = 12.0
    }
    
    /// 所属目标计划信息视图
    private lazy var planInfoView: GoalTaskPlanInfoView = {
        let view = GoalTaskPlanInfoView()
        view.backgroundColor = .secondarySystemGroupedBackground
        view.goalPlan = editingTask.goalPlan
        view.onClick = { [weak self] in
            self?.selectGoalPlan()
        }
        return view
    }()
    
    // MARK: - Initialization
    init(goalTask: GoalEditingTask? = nil, goalPlan: GoalPlanFeature? = nil) {
        if let goalTask = goalTask {
            self.editingTask = goalTask
            self.editType = .modify
        } else {
            var editingTask = GoalEditingTask()
            editingTask.goalPlan = goalPlan ?? .inboxFeature
            self.editingTask = editingTask
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
        /// 为底部浮层预留滚动间距
        tableView.contentInset.bottom = PlanConfig.infoViewHeight + PlanConfig.infoViewEdgeMargins.verticalLength
        /// 提前创建信息视图（此时不加入视图层级，避免首次布局闪烁）
        _ = planInfoView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutPlanInfoView(planInfoView)
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
        /// 底部弹出所属目标计划信息视图
        showPlanInfoView()
    }
    
    /// 底部弹出所属目标计划信息视图
    private func showPlanInfoView() {
        view.addSubview(planInfoView)
        layoutPlanInfoView(planInfoView, isHidden: true)
        UIView.animate(withDuration: 0.6,
                       delay: 0.0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0.5,
                       options: .curveEaseInOut,
                       animations: {
            self.layoutPlanInfoView(self.planInfoView)
        }, completion: nil)
    }
    
    /// 布局所属目标计划信息视图
    private func layoutPlanInfoView(_ infoView: UIView, isHidden: Bool = false) {
        let layoutFrame = view.safeLayoutFrame().inset(by: PlanConfig.infoViewEdgeMargins)
        infoView.width = min(640.0, layoutFrame.width)
        infoView.height = PlanConfig.infoViewHeight
        if isHidden {
            infoView.top = view.height
        } else {
            infoView.bottom = layoutFrame.maxY
        }
        
        infoView.centerX = layoutFrame.midX
        infoView.layer.cornerRadius = PlanConfig.infoViewCornerRadius
        infoView.layer.setLayerShadow(color: Color(0x000000, 0.1),
                                      offset: CGSize(width: 0.0, height: -2.0),
                                      radius: PlanConfig.infoViewCornerRadius)
        infoView.layoutIfNeeded()
    }
    
    /// 选择所属目标计划
    private func selectGoalPlan() {
        TPImpactFeedback.impactWithSoftStyle()
        
        let vc = GoalTaskMoveViewController(goalPlan: editingTask.goalPlan)
        vc.didSelectGoalPlan = { [weak self] goalPlan in
            self?.editingTask.goalPlan = goalPlan.feature
            self?.planInfoView.goalPlan = goalPlan.feature
        }
        
        let navController = UINavigationController(rootViewController: vc)
        navController.modalPresentationStyle = .formSheet
        navController.show()
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
    
    // MARK: - Event Response
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


// MARK: - 所属目标计划
/// 目标任务所属目标计划信息视图
class GoalTaskPlanInfoView: TPInfoView {
    
    /// 点击回调
    var onClick: (() -> Void)?
    
    /// 所属目标计划（未归属任何目标计划时为收件箱）
    var goalPlan: GoalPlanFeature? {
        didSet {
            updateGoalPlanInfo()
        }
    }
    
    /// 颜色圆点
    private let colorView = UIView()
    
    /// 箭头图标
    private lazy var chevronView: UIImageView = {
        let view = UIImageView()
        view.image = resGetImage("chevron_right_16")
        view.contentMode = .center
        return view
    }()
    
    override func setupSubviews() {
        super.setupSubviews()
        colorView.clipsToBounds = true
        leftAccessoryView = colorView
        leftAccessorySize = .size(3)
        leftAccessoryMargins = UIEdgeInsets(left: 14.0, right: 8.0)
        rightAccessoryView = chevronView
        rightAccessorySize = .mini
        rightAccessoryMargins = UIEdgeInsets(left: 8.0, right: 16.0)
        subtitleTopMargin = 3.0
        titleConfig.font = BOLD_SMALL_SYSTEM_FONT
        subtitleConfig.font = UIFont.systemFont(ofSize: 11.0)
        
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(clickSelf(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.layer.cornerRadius = colorView.halfWidth
        chevronView.updateImage(withColor: .secondaryLabel)
    }
    
    @objc private func clickSelf(_ gesture: UITapGestureRecognizer) {
        onClick?()
    }
    
    /// 更新目标计划信息
    private func updateGoalPlanInfo() {
        guard let goalPlan = goalPlan else {
            title = nil
            subtitle = nil
            return
        }
        
        title = goalPlan.displayName
        subtitle = resGetString("Goal Plan")
        colorView.backgroundColor = goalPlan.color ?? GoalConfig.goalPlanDefaultColor
        setNeedsLayout()
    }
}


