//
//  TodoTaskDetailEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/1/4.
//

import Foundation
import UIKit

class TodoTaskEditViewController: TPTableSectionsViewController,
                                  TodoTaskProcessorDelegate,
                                  TodoTaskEditInfoViewDelegate,
                                  TodoTaskEditFooterViewDelegate,
                                  TodoStepEditControllerDelegate {

    /// 优先级按钮
    lazy var priorityBarButtonItem: TodoTaskPriorityBarButtonItem = {
        let buttonItem = TodoTaskPriorityBarButtonItem()
        buttonItem.priority = self.task.priority
        buttonItem.didSelectPriority = { [weak self] priority in
            self?.selectPriority(priority)
        }
        
        return buttonItem
    }()
    
    /// 步骤编辑控制器
    lazy var stepEditController: TodoStepEditController = {
        var viewController: UIViewController = self
        if let navigationController = self.navigationController {
            viewController = navigationController
        }
        
        let stepEditController = TodoStepEditController(containerViewController : viewController)
        stepEditController.delegate = self
        return stepEditController
    }()
    
    /// 步骤区块
    lazy var stepSectionController: TodoTaskEditStepSectionController = {
        let sectionController = TodoTaskEditStepSectionController(task: self.task)
        sectionController.stepEditControler = stepEditController
        sectionController.stepsInfoDidChange = { [weak self] in
            self?.updateDetail()
        }
    
        return sectionController
    }()
    
    /// 进度
    lazy var progressSectionController: TodoTaskEditProgressSectionController = {
        let sectionController = TodoTaskEditProgressSectionController(task: self.task)
        return sectionController
    }()
    
    /// 计划
    lazy var scheduleSectionController: TodoTaskEditScheduleSectionController = {
        let sectionController = TodoTaskEditScheduleSectionController(task: self.task)
        return sectionController
    }()

    /// 标签
    lazy var tagSectionController: TodoTaskEditTagSectionController = {
        let sectionController = TodoTaskEditTagSectionController(task: self.task)
        return sectionController
    }()
    
    /// 添加到我的一天
    lazy var addToMyDaySectionController: TodoTaskEditAddToMyDaySectionController = {
        let sectionController = TodoTaskEditAddToMyDaySectionController(task: self.task)
        return sectionController
    }()
    
    /// 备注
    lazy var noteSectionController: TodoTaskEditNoteSectionController = {
        let sectionController = TodoTaskEditNoteSectionController(task: self.task)
        return sectionController
    }()
    
    /// 编辑信息视图
    lazy var infoView: TodoTaskEditInfoView = {
        let view = TodoTaskEditInfoView()
        view.delegate = self
        return view
    }()

    /// 底部视图
    let footerViewHeight = 60.0
    lazy var footerView: TodoTaskEditFooterView = {
        let view = TodoTaskEditFooterView()
        view.delegate = self
        return view
    }()

    /// 排序管理器
    private var reorder: TPTableDragInsertReorder?
    
    /// 待办任务
    private let task: TodoTask

    private let detailProvider: TodoTaskDetailProvider

    init(task: TodoTask) {
        self.task = task
        let option: TodoTaskDetailOption = [.step, .progress, .tag]
        self.detailProvider = TodoTaskDetailProvider(task: task, option: option)
        super.init(style: .grouped)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.rightBarButtonItem = priorityBarButtonItem
        view.addSubview(infoView)
        view.addSubview(footerView)
        setupReorder()
        tableView.keyboardDismissMode = .onDrag
        wrapperView.isKeyboardAdjusterEnabled = true
        adapter.cellStyle.backgroundColor = .systemBackground
        sectionControllers = [stepSectionController,
                              addToMyDaySectionController,
                              scheduleSectionController,
                              progressSectionController,
                              tagSectionController,
                              noteSectionController]
        reloadData()
        todo.addUpdater(self, for: .task)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeAreaFrame()
        infoView.width = layoutFrame.width
        infoView.height = infoView.contentHeight
        infoView.origin = layoutFrame.origin
        
        footerView.width = layoutFrame.width
        footerView.height = footerViewHeight
        footerView.bottom = layoutFrame.maxY
        
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
        reorder.delegate = self.stepSectionController
        self.reorder = reorder
    }
    
  
    // MARK: - Update
    
    /// 重新加载信息视图数据
    private func updateInfo() {
        updateName()
        updatePriority()
        updateCheckType()
        updateProgress(animated: false)
        updateCompleted(animated: false)
        updateDetail()
    }
    
    /// 更新底部视图
    private func updateFooterView() {
        footerView.task = task
        footerView.updateDateInfo()
    }

    private func updateCompleted(animated: Bool) {
        infoView.setCompleted(task.isCompleted, animated: animated)
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
        infoView.attributedDetailInfo = detailProvider.attributedInfo()
        view.setNeedsLayout()
    }
    
    private func updateProgress(animated: Bool = false) {
        infoView.setProgress(task.completionRate, animated: animated)
        infoView.isProgressHidden = !task.isProgressSet
        view.setNeedsLayout()
    }
    
    private func didChangeProgress(from: TodoEditProgress?, to: TodoEditProgress?) {
        if detailProvider.option.contains(.progress) {
            updateDetail()
        }
        
        updateProgress(animated: true)
        guard let from = from, let to = to, to.currentValue != from.currentValue else {
            return
        }

        let difference = to.currentValue - from.currentValue
        let message = (difference >= 0 ? "+" : "") + "\(difference)"
        TPTextPopUp.showText(message,
                             color: task.priority.titleColor,
                             font: BOLD_SMALL_SYSTEM_FONT,
                             fromView: infoView.checkbox)
    }
    
    override func reloadData() {
        super.reloadData()
        updateInfo()
        updateFooterView()
    }
    
    // MARK: - TodoTaskProcessorDelegate
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask]) {
        if tasks.contains(self.task) {
            reloadData()
        }
    }
    
    func didUpdateTodoTask(with infos: [TodoTaskChangeInfo]) {
        for info in infos {
            guard info.task === self.task else {
                continue
            }
            
            switch info.change {
            case .name(_, _):
                updateName()
            case .priority(_, _):
                updatePriority()
            case .completed(_, _):
                updateCompleted(animated: true)
                updateProgress(animated: true)
                updateFooterView()
            case .progress(let oldProgress, let newProgress):
                updateCheckType()
                didChangeProgress(from: oldProgress, to: newProgress)
            case .tag(_, _):
                if detailProvider.option.contains(.tag) {
                    updateDetail()
                }
            case .schedule(_, _):
                if detailProvider.option.contains(.schedule) {
                    updateDetail()
                }
            case .note(_, _):
                if detailProvider.option.contains(.note) {
                    updateDetail()
                }
            case .myDay(_, _):
                if detailProvider.option.contains(.myDay) {
                    updateDetail()
                }
            case .list(_, _):
                if detailProvider.option.contains(.list) {
                    updateDetail()
                }
            }
        }
    }

    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask]) {
        
    }
    
    func didCreateTodoTask(_ task: TodoTask, in list: TodoList?) {
        
    }
    
    func didMoveTodoTasks(with infos: [TodoTaskChangeInfo]) {
        
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int) {
        
    }
    
    
    // MARK: - TodoTaskEditInfoViewDelegate
    func todoTaskEditInfoView(_ infoView: TodoTaskEditInfoView, didClickCheckbox checkbox: TodoTaskCheckbox) {
        let taskController = TodoTaskController()
        taskController.clickCheckbox(for: self.task)
    }
    
    func todoTaskEditInfoView(_ infoView: TodoTaskEditInfoView, didEndEditingName name: String?) {
        todo.updateTask(task, name: name)
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
        todo.addStep(named: name, onTop: onTop, for: task)
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
    func todoTaskEditFooterViewDidClickMore(_ view: TodoTaskEditFooterView) {
        UIResponder.resignCurrentFirstResponder()
        let moreButton = view.moreButton
        let menuController = TodoTaskMenuController(task: task)
        menuController.didSelectMenuActionType = { type in
            self.performMenuActionType(type)
        }
        
        menuController.showMenu(from: moreButton,
                                sourceRect: moreButton.bounds.inset(by: .init(value: -5.0)),
                                isCovered: true)
    }
    
    private func performMenuActionType(_ type: TodoTaskActionType) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Event Response
    func selectPriority(_ priority: TodoTaskPriority) {
        guard task.priority != priority else {
            return
        }
        
        todo.updateTask(task, priority: priority)
    }
}
