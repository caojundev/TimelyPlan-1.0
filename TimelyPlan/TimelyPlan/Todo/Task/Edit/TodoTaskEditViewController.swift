//
//  TodoTaskDetailEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/4.
//

import Foundation
import UIKit

class TodoTaskEditViewController: TPTableSectionsViewController,
                                  TodoTaskEditInfoViewDelegate,
                                  TodoTaskEditFooterViewDelegate,
                                  TodoStepEditControllerDelegate {
    
    /// 优先级按钮
    lazy var priorityBarButtonItem: TodoTaskPriorityBarButtonItem = {
        let buttonItem = TodoTaskPriorityBarButtonItem()
        buttonItem.priority = self.interactor.task.priority
        buttonItem.didSelectPriority = { [weak self] priority in
            self?.selectPriority(priority)
        }
        
        return buttonItem
    }()
    
    /// 步骤区块
    lazy var stepAddSectionController: TodoTaskAddStepSectionController = { [weak self] in
        let sectionController = TodoTaskAddStepSectionController()
        sectionController.didClickAdd = {
            self?.clickAddStep()
        }
        
        sectionController.didSelectActionType = { actionType in
            self?.stepEditSectionController.performTaskStepBulkMenuAction(with: actionType)
        }

        return sectionController
    }()
    
    lazy var stepEditSectionController: TodoTaskEditStepSectionController = {
        let sectionController = TodoTaskEditStepSectionController(interactor: self.interactor)
        return sectionController
    }()

    /// 进度
    lazy var progressSectionController: TodoTaskEditProgressSectionController = {
        let sectionController = TodoTaskEditProgressSectionController(interactor: self.interactor)
        return sectionController
    }()
    
    /// 计划
    lazy var scheduleSectionController: TodoTaskEditScheduleSectionController = {
        let sectionController = TodoTaskEditScheduleSectionController(interactor: self.interactor)
        return sectionController
    }()

    /// 标签
    lazy var tagSectionController: TodoTaskEditTagSectionController = {
        let sectionController = TodoTaskEditTagSectionController(interactor: self.interactor)
        return sectionController
    }()
    
    /// 添加到我的一天
    lazy var myDaySectionController: TodoTaskEditMyDaySectionController = {
        let sectionController = TodoTaskEditMyDaySectionController(interactor: self.interactor)
        return sectionController
    }()
    
    /// 备注
    lazy var noteSectionController: TodoTaskEditNoteSectionController = {
        let sectionController = TodoTaskEditNoteSectionController(interactor: self.interactor)
        return sectionController
    }()
    
    /// 编辑信息视图
    lazy var infoView: TodoTaskEditInfoView = {
        let view = TodoTaskEditInfoView()
        view.delegate = self
        return view
    }()

    /// 菜单视图
    let menuViewHeight = 60.0
    lazy var menuView: TodoTaskEditMenuView = {
        let view = TodoTaskEditMenuView(frame: .zero)
        view.didSelectEditType = {[weak self] editType in
            self?.selectEditType(editType)
        }
        
        return view
    }()
    
    /// 底部视图
    let footerViewHeight = 60.0
    lazy var footerView: TodoTaskEditFooterView = {
        let view = TodoTaskEditFooterView()
        view.delegate = self
        return view
    }()
    
    /// 步骤编辑控制器
    private lazy var stepEditController: TodoStepEditController = {
        var viewController: UIViewController = self
        if let navigationController = self.navigationController {
            viewController = navigationController
        }
        
        let stepEditController = TodoStepEditController(containerViewController : viewController)
        stepEditController.maskBackgroundColor = .clear
        stepEditController.delegate = self
        return stepEditController
    }()
    
    private lazy var sectionTitleView: TodoTaskEditSectionTitleView = {
        let titleView = TodoTaskEditSectionTitleView()
        titleView.didClickSection = { [weak self] in
            self?.clickSection()
        }
        
        return titleView
    }()
    
    /// 排序管理器
    private var reorder: TPTableDragInsertReorder?
    
    private let detailOptions: TodoTaskDetailOption = [.step, .progress, .tag]

    private let interactor: TodoTaskEditInteractor
    
    var task: TodoTask {
        return interactor.task
    }
    
    init(task: TodoTask) {
        self.interactor = TodoTaskEditInteractor(task: task)
        super.init(style: .grouped)
        self.interactor.onTaskChange = { [weak self] change in
            self?.taskDidChange(change)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.backButtonItem
        self.navigationItem.rightBarButtonItem = self.priorityBarButtonItem
        self.navigationItem.titleView = sectionTitleView
        self.view.addSubview(self.infoView)
        self.view.addSubview(self.menuView)
        self.view.addSubview(self.footerView)
        self.setupReorder()
        self.tableView.keyboardDismissMode = .onDrag
        self.wrapperView.isKeyboardAdjusterEnabled = true
        self.adapter.cellStyle.backgroundColor = .systemBackground
        self.sectionControllers = [stepEditSectionController,
                                   stepAddSectionController,
                                   myDaySectionController,
                                   scheduleSectionController,
                                   progressSectionController,
                                   tagSectionController,
                                   noteSectionController]
        self.reloadData()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        sectionTitleView.sizeToFit()
        
        let layoutFrame = view.safeAreaFrame()
        infoView.width = layoutFrame.width
        infoView.height = infoView.contentHeight
        infoView.origin = layoutFrame.origin
        
        footerView.width = layoutFrame.width
        footerView.height = footerViewHeight
        footerView.bottom = layoutFrame.maxY

        menuView.width = layoutFrame.width
        menuView.height = menuViewHeight
        menuView.bottom = footerView.top
        
        wrapperView.width = layoutFrame.width
        wrapperView.height = layoutFrame.height - infoView.bottom - footerViewHeight
        wrapperView.top = infoView.bottom
        wrapperView.left = layoutFrame.minX
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    /// 初始化排序管理器
    private func setupReorder() {
        let reorder = TPTableDragInsertReorder(tableView: adapter.tableView)
        reorder.indicatorBackColor = Color(0xFFFFFF, 0.1)
        reorder.isEnabled = true
        reorder.delegate = self.stepEditSectionController
        self.reorder = reorder
    }
    
    override func reloadData() {
        updateSteps()
        updateInfo()
        updateMenuEditTypes()
        updateFooterView()
        adapter.reloadData()
    }
    
    private func performUpdate() {
        updateSteps()
        updateInfo(animated: true)
        updateMenuEditTypes()
        updateFooterView()
        adapter.performUpdate(with: .fade, completion: nil)
    }
    
    private func taskDidChange(_ change: TodoTaskChange?) {
        guard let change = change else {
            reloadData()
            return
        }
        
        switch change {
        case .section(_, _):
            updateSectionTitle()
        case .name(_, _):
            updateName()
        case .priority(_, _):
            updatePriority()
        case .completed(_, _):
            updateCompleted(animated: true)
            updateProgress(animated: true)
            updateFooterView()
        case .progress(_, _):
            updateCheckType()
            updateProgress(animated: true)
            if detailOptions.contains(.progress) {
                updateDetail()
            }
        case .tag(_, _):
            if detailOptions.contains(.tag) {
                updateDetail()
            }
        case .step(_, _):
            if detailOptions.contains(.step) {
                updateDetail()
            }
        default:
            break
        }
        
        updateMenuEditTypes(animated: true)
    }
    
    private func updateMenuEditTypes(animated: Bool = false) {
        var editTypes: [TodoTaskEditType] = []
        
        if !task.isAddedToMyDay {
            editTypes.append(.myDay)
        }
        
        if let schedule = task.schedule, let dateInfo = schedule.dateInfo {
            // 提醒条件：无提醒 或 有提醒但未设置闹钟
            let hasAlarm = schedule.reminder?.hasAlarm ?? false
            if !hasAlarm {
                editTypes.append(.reminder)
            }
            
            // 重复规则条件：非跨天且无重复规则
            if dateInfo.style != .multiDay && schedule.repeatRule == nil {
                editTypes.append(.repeatRule)
            }
        } else {
            editTypes.append(.date)
        }
        
        let tagsCount = task.tags?.count ?? 0
        if tagsCount == 0 {
            editTypes.append(.tag)
        }
        
        let hasProgress = task.progress?.isValid ?? false
        if !hasProgress {
            editTypes.append(.progress)
        }

        menuView.setEditTypes(editTypes, animated: animated)
        let isHidden = editTypes.count == 0
        menuView.isHidden = isHidden
    }
    
    // MARK: - 更新信息
    func updateSteps() {
        stepEditSectionController.updateSteps()
    }
    
    /// 重新加载信息视图数据
    private func updateInfo(animated: Bool = false) {
        updateSectionTitle()
        updateName()
        updatePriority()
        updateCheckType()
        updateProgress(animated: animated)
        updateCompleted(animated: animated)
        updateDetail()
    }
    
    private func updateSectionTitle() {
        sectionTitleView.section = task.section
        sectionTitleView.sizeToFit()
    }
    
    private func updateCompleted(animated: Bool) {
        let isCompleted = task.isCompleted
        infoView.setCompleted(isCompleted, animated: animated)
    }
    
    private func updateProgress(animated: Bool = false) {
        infoView.setProgress(task.completionFraction, animated: animated)
        infoView.isProgressHidden = !task.isProgressSet
        view.setNeedsLayout()
    }
    
    private func updateName() {
        infoView.name = task.name
        view.setNeedsLayout()
    }
    
    /// 更新检查类型
    private func updateCheckType() {
        infoView.checkType = task.checkType
    }
    
    /// 更新优先级
    private func updatePriority() {
        let priority = task.priority
        priorityBarButtonItem.priority = priority
        infoView.priority = priority
    }
    
    /// 更新详情信息
    private func updateDetail() {
        let detailProvider = TodoTaskDetailProvider(task: task, option: detailOptions)
        infoView.attributedDetailInfo = detailProvider.attributedInfo()
        view.setNeedsLayout()
    }
    
    /// 更新底部视图
    private func updateFooterView() {
        footerView.task = task
        footerView.updateDateInfo()
    }

    
    // MARK: - Event Response
    private func selectEditType(_ editType: TodoTaskEditType) {
        switch editType {
        case .myDay:
            myDaySectionController.editMyDay()
        case .date:
            scheduleSectionController.editDate()
        case .reminder:
            scheduleSectionController.editReminder()
        case .repeatRule:
            scheduleSectionController.editRepeat()
        case .progress:
            progressSectionController.editProgress()
        case .tag:
            tagSectionController.editTag()
        }
    }
    
    private func clickSection() {
        let taskController = TodoTaskController()
        taskController.moveTask(task, completion: nil)
    }
    
    func selectPriority(_ priority: TodoTaskPriority) {
        interactor.setPriority(priority)
    }
    
    func clickAddStep() {
        stepEditController.beginEditing()
    }
    
    // MARK: - 设置完成状态和进度
    private func setCompleted(_ isCompleted: Bool, completion: (@escaping() -> Void)) {
        infoView.setCompleted(isCompleted, animated: true) {
            completion()
        }
    }
    
    private func setProgress(_ progress: TodoEditProgress, completion: (@escaping() -> Void)) {
        let fromProgress = self.task.progress
        infoView.didChangeProgress(from: fromProgress, to: progress)
        let value = progress.completionFraction
        infoView.setProgress(value, animated: true) {
            completion()
        }
    }
    
    // MARK: - TodoTaskEditInfoViewDelegate
    func todoTaskEditInfoView(_ infoView: TodoTaskEditInfoView, didClickCheckbox checkbox: TodoTaskCheckbox) {
        let taskController = TodoTaskController()
        taskController.clickCheckbox(for: self.task) {isCompleted, execution in
            self.setCompleted(isCompleted) {
                execution?()
            }
        } progressHandler: { progress, execution in
            self.setProgress(progress) {
                execution?()
            }
        }
    }
    
    func todoTaskEditInfoView(_ infoView: TodoTaskEditInfoView, didEndEditingName name: String?) {
        interactor.setName(name)
        view.setNeedsLayout()
    }
    
    func todoTaskEditInfoViewContentHeightDidChange(_ infoView: TodoTaskEditInfoView) {
        /// 重新布局
        view.setNeedsLayout()
    }
    
    // MARK: - TodoStepEditControllerDelegate
    func stepEditControllerDidEnterReturn(_ controller: TodoStepEditController) {
        guard let name = controller.text?.whitespacesAndNewlinesTrimmedString, name.count > 0 else {
            controller.clearText()
            controller.endEditing()
            return
        }
        
        controller.clearText()
        
        let onTop = controller.position == .top
        let isCompleted = controller.isCompleted
        let step = TodoStep(content: name, isCompleted: isCompleted)
        stepEditSectionController.addStep(step, onTop: onTop)
    }
    
    func keyboardAwareControllerWillShowInputView(controller: TPKeyboardAwareController) {
        stepAddSectionController.setEditing(true)
    }
    
    func keyboardAwareControllerWillHideInputView(controller: TPKeyboardAwareController) {
        stepAddSectionController.setEditing(false)
    }
    
    func keyboardAwareController(controller: TPKeyboardAwareController, inputViewFrameDidChange fromFrame: CGRect) {
        guard let inputView = controller.inputView else {
            tableView.contentInset = .zero
            return
        }
        
        var insetBottom = self.view.bounds.height - inputView.top
        if insetBottom < 0.0 {
            insetBottom = 0.0
        }
        
        tableView.contentInset = UIEdgeInsets(bottom: insetBottom)
    }

    // MARK: - TodoTaskEditFooterViewDelegate
    func todoTaskEditFooterViewDidClickFocus(_ view: TodoTaskEditFooterView) {
        UIResponder.resignCurrentFirstResponder()
        FocusPresenter.quickStartFocus(for: self.task)
    }
    
    func todoTaskEditFooterViewDidClickMore(_ view: TodoTaskEditFooterView) {
        UIResponder.resignCurrentFirstResponder()
        let moreButton = view.moreButton
        
        let stepActionTypes: [TodoTaskStepBulkMenuActionType] = [.importSteps]
        let stepMenuItem = TPMenuItem.item(with: stepActionTypes) { actionType, action in
            action.handler = { _ in
                self.stepEditSectionController.performTaskStepBulkMenuAction(with: actionType)
            }
        }
        
        let trashTypes: [TodoTaskActionType] = [.trash]
        let trashMenuItem = TPMenuItem.item(with: trashTypes) { actionType, action in
            action.handler = { _ in
                self.performMenuActionType(actionType)
            }
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = 180.0
        menuList.menuItems = [stepMenuItem, trashMenuItem]
        menuList.popoverShow(from: moreButton,
                             sourceRect: moreButton.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .topLeft)
    }
    
    private func performMenuActionType(_ type: TodoTaskActionType) {
        if type == .trash {
            self.interactor.moveToTrash()
            self.dismiss(animated: true, completion: nil)
        }
    }

}
