//
//  GoalDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

class GoalDetailViewController: TPMultiColumnDetailViewController,
                                GoalTaskListViewDelegate {
    
    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    }

    /// 添加视图
    private var addView: TPAddView?
    
    /// 目标任务列表视图
    lazy var taskListView: GoalTaskListView = {
        let listView = GoalTaskListView(frame: .zero)
        listView.delegate = self
        listView.reorderDelegate = self
        return listView
    }()
    
    /// 进度条高度
    let progressHeight = 8.0

    /// 进度条
    private(set) lazy var progressView: TPBarProgressView = {
        let view = TPBarProgressView(frame: .zero, style: .horizontal)
        view.isUserInteractionEnabled = false
        view.cornerRadius = 0.0
        return view
    }()
    
    /// 标题视图
    private lazy var titleView: TPImageTitleView = {
        let view = TPImageTitleView()
        view.padding = .zero
        view.titleConfig.font = BOLD_BODY_FONT
        view.titleConfig.textAlignment = .center
        return view
    }()
    
    /// 更多按钮
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        return UIBarButtonItem(customView: moreButton)
    }()
    
    private lazy var moreButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.padding = UIEdgeInsets(horizontal: 5.0)
        button.image = resGetImage("ellipsis_24")
        button.imageConfig.color = resGetColor(.title)
        button.addTarget(self, action: #selector(clickMore(_:)), for: .touchUpInside)
        return button
    }()
    
    let taskController = GoalTaskController()
    
    let interactor: GoalPlanInteractor
    
    // MARK: - Initialization
    init(configuration: GoalListConfiguration) {
        self.interactor = GoalPlanInteractor(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    /// 是否显示顶部进度条
    var showsProgressView: Bool {
        return true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = moreBarButtonItem
        setupTaskListView()
        setupAddView()
        taskListView.placeholderProvider = interactor.placeholderProvider
        interactor.didChangeGroups = { [weak self] change in
            self?.taskGroupsDidChange(change)
        }
        
        interactor.didChangeGoalInfo = { [weak self] in
            self?.updateGoalInfo(animated: true)
        }
        
        /// 首次加载目标任务分组
        interactor.setNeedsRefresh()
        interactor.loadGroups()
        updateGoalInfo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        taskListView.reloadDataIfNeeded()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutTaskListView()
        layoutAddView()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - 目标任务列表视图
    private func setupTaskListView() {
        taskListView.expansionStates = GoalTaskGroupExpansionState(identifier: interactor.configuration.identifier)
        taskListView.placeholderProvider = interactor.placeholderProvider
        view.addSubview(taskListView)
        taskListView.addRefreshControl()
        if showsProgressView {
            view.addSubview(progressView)
        }
    }

    private func layoutTaskListView() {
        let layoutFrame = view.safeAreaFrame()
        
        /// 顶部偏移：有进度条时为其预留高度
        let topInset = showsProgressView ? progressHeight : 0.0
        if showsProgressView {
            /// 进度条位于列表上方
            progressView.width = view.width
            progressView.height = progressHeight
            progressView.left = 0.0
            progressView.top = 0.0
        }
        
        let insetBottom = layoutFrame.maxY - (addView?.top ?? layoutFrame.maxY)
        taskListView.frame = CGRect(x: 0.0,
                                    y: topInset,
                                    width: view.width,
                                    height: view.height - topInset)
        taskListView.contentInset = UIEdgeInsets(bottom: max(insetBottom, 0.0))
    }
    
    /// 目标任务分组数据发生改变
    private func taskGroupsDidChange(_ change: GoalPlanTaskChange? = nil) {
        taskListView.endRefreshing()
        taskListView.groups = interactor.groups
        taskListView.performUpdate(animated: true)
        
        guard let change = change else {
            return
        }

        switch change {
        case .create(let task):
            taskListView.revealGoalTask(task)
        case .update(let task, let change):
            taskListView.updateProgressChange(change, for: task)
        }
    }

    
    // MARK: - 添加视图
    private func setupAddView() {
        if canAddGoal() {
            let addView = TPAddView()
            addView.normalBackgroundColor = interactor.configuration.addButtonBackColor()
            addView.didClickAdd = { [weak self] _ in
                self?.handleAddTask()
            }
            
            self.addView = addView
            self.view.insertSubview(addView, at: 999)
        }
    }
    
    private func layoutAddView() {
        let layoutFrame = view.safeAreaFrame()
        if let addView = addView {
            addView.size = Config.addViewSize
            addView.bottom = layoutFrame.maxY - Config.addViewMargins.bottom
            addView.right = layoutFrame.maxX - Config.addViewMargins.right
        }
    }
    
    // MARK: - Update
    private func updateGoalInfo(animated: Bool = false) {
        updateTitle()
        updateProgressView(animated: animated)
    }
    
    /// 更新标题
    private func updateTitle() {
        titleView.title = interactor.title()
        titleView.sizeToFit()
    }
    
    private func updateProgressView(animated: Bool = false) {
        guard showsProgressView, let goalPlan = goalPlan else {
            return
        }
        
        let color = goalPlan.color ?? GoalConfig.goalPlanDefaultColor
        progressView.barForeColor = color
        progressView.barBackColor = color.withAlphaComponent(0.2)
        progressView.setProgress(goalPlan.progress, animated: animated)
    }
    
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        guard let config = self.interactor.planOptionConfig() else {
            return
        }

        let optionMenuController = GoalPlanOptionMenuController(config: config)
        optionMenuController.didSelectPlanOption = { [weak self] option in
            self?.selectGoalPlanOption(option)
        }
        
        optionMenuController.didSelectGroupType = { [weak self] groupType in
            self?.selectGroupType(groupType)
        }
        
        optionMenuController.didSelectSortType = { [weak self] sortType in
            self?.selectSortType(sortType)
        }
        
        optionMenuController.didSelectSortOrder = { [weak self] sortOrder in
            self?.selectSortOrder(sortOrder)
        }
        
        let menuItems = optionMenuController.menuItems()
        let menuController = TPLevelMenuViewController(menuItems: menuItems)
        let sourceRect = CGRect(x: moreButton.bounds.maxX,
                                y: moreButton.bounds.maxY,
                                size: .zero)
        menuController.show(from: moreButton, sourceRect: sourceRect, isCovered: false)
    }
    
    /// 点击添加目标任务（子类可重写以适配收件箱等场景）
    func handleAddTask() {
        TPImpactFeedback.impactWithLightStyle()
        guard let goalPlan = goalPlan else {
            return
        }
        
        GoalPresenter.createNewGoalTask(in: goalPlan)
    }
    
    func canAddGoal() -> Bool {
        return true
    }
    
    // MARK: - GoalTaskListViewDelegate
    func goalTaskListView(_ listView: GoalTaskListView, didSelectGoalTask goalTask: GoalTask) {
        TPImpactFeedback.impactWithSoftStyle()
        GoalPresenter.showActionViewController(for: goalTask)
    }
    
    func goalTaskListView(_ listView: GoalTaskListView, didClickMoreForTask goalTask: GoalTask, sourceView: UIView) {
        let menuController = GoalTaskMenuController(task: goalTask)
        menuController.didSelectMenuActionType = { [weak self] type in
            self?.taskController.performMenuAction(type, for: goalTask)
        }
        
        menuController.showMenu(from: sourceView)
    }
    
    func goalTaskListView(_ listView: GoalTaskListView, didClickCheckboxForTask goalTask: GoalTask) {
        taskController.clickCheckbox(for: goalTask)
    }
    
    func goalTaskListViewHandleRefresh(_ listView: GoalTaskListView) {
        interactor.setNeedsRefresh()
        interactor.loadGroups()
    }
    
    // MARK: - List Options
    
    /// 所属目标计划（收件箱配置下为 nil）
    var goalPlan: GoalPlan? {
        return (interactor.configuration as? GoalPlanConfiguration)?.goalPlan
    }
    
    func selectGoalPlanOption(_ option: GoalPlanOption) {
        guard let goalPlan = goalPlan else {
            return
        }
        
        let processor = GoalPlanMenuProcessor()
        switch option {
        case .edit:
            processor.performMenuAction(.edit, for: goalPlan)
        case .delete:
            processor.performMenuAction(.delete, for: goalPlan)
        default:
            break
        }
    }
    
    private func selectGroupType(_ groupType: GoalTaskGroupType) {
        interactor.setGroupType(groupType)
    }
    
    private func selectSortType(_ sortType: TodoSortType) {
        interactor.setSortType(sortType)
    }
    
    private func selectSortOrder(_ sortOrder: TodoSortOrder) {
        interactor.setSortOrder(sortOrder)
    }
    
}


// MARK: - 任务排序
extension GoalDetailViewController: TPCollectionDragInsertReorderDelegate {
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, willBeginAt indexPath: IndexPath) {
        
    }
    
    func collectionDragReorder(_ reorder: TPCollectionDragReorder, canMoveItemAt indexPath: IndexPath) -> Bool {
        return interactor.sort.type == .manually
    }
    
    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder, canInsertItemTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath) -> Bool {
        guard sourceIndexPath.section == targetIndexPath.section else {
            return false
        }
        
        return true
    }

    func collectionDragInsertReorder(_ reorder: TPCollectionDragInsertReorder, inserItemTo targetIndexPath: IndexPath, from sourceIndexPath: IndexPath, depth: Int) -> IndexPath? {
        guard targetIndexPath.row != sourceIndexPath.row,
              let goalPlan = self.goalPlan,
                let sourceTask = taskListView.goalTask(at: sourceIndexPath),
                let targetTask = taskListView.goalTask(at: targetIndexPath) else {
            return nil
        }
    
        var insertPosition: TodoTaskInsertPosition = .after
        if sourceIndexPath.row > targetIndexPath.row {
            insertPosition = .before
        }
        
        taskListView.moveItem(at: sourceIndexPath, to: targetIndexPath)
        
        GoalRepository.reorderGoalTask(sourceTask,
                                       postion: insertPosition,
                                       targetTask: targetTask,
                                       in: goalPlan)
        return targetIndexPath
    }
}


// MARK: - 收件箱
/// 收件箱详情视图控制器（展示未归属任何目标计划的目标任务）
class GoalInboxViewController: GoalDetailViewController {
    
    /// 收件箱不显示顶部进度条
    override var showsProgressView: Bool {
        return false
    }
    
    /// 在收件箱中创建目标任务
    override func handleAddTask() {
        TPImpactFeedback.impactWithLightStyle()
        GoalPresenter.createNewInboxGoalTask()
    }
}
