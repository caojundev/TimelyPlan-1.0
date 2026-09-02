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
        return listView
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
    
    // MARK: - Initialization
    
    let interactor: GoalPlanInteractor
    
    init(configuration: GoalPlanConfiguration) {
        self.interactor = GoalPlanInteractor(configuration: configuration)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        navigationItem.rightBarButtonItem = moreBarButtonItem
        updateTitle()
        setupTaskListView()
        setupAddView()
        loadTestTaskGroups()
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
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    // MARK: - 目标任务列表视图
    private func setupTaskListView() {
        containerView.addSubview(taskListView)
        taskListView.addRefreshControl()
    }
    
    private func layoutTaskListView() {
        taskListView.frame = containerView.bounds
        let layoutFrame = view.safeAreaFrame()
        let insetBottom = layoutFrame.maxY - (addView?.top ?? layoutFrame.maxY)
        taskListView.contentInset = UIEdgeInsets(top: 0.0,
                                                 left: 0.0,
                                                 bottom: max(insetBottom, 0.0),
                                                 right: 0.0)
    }
    
    /// 加载测试目标任务分组数据
    func loadTestTaskGroups() {
        var groups = [GoalTaskGroup]()
        
        /// 第一组：未完成任务
        let uncompletedGroup = GoalTaskGroup(identifier: "Uncompleted")
        uncompletedGroup.title = "未完成"
        uncompletedGroup.goalTasks = makeTestTasks(count: 4, isCompleted: false)
        groups.append(uncompletedGroup)
        
        /// 第二组：已完成任务
        let completedGroup = GoalTaskGroup(identifier: "Completed")
        completedGroup.title = "已完成"
        completedGroup.goalTasks = makeTestTasks(count: 2, isCompleted: true)
        groups.append(completedGroup)
        
        taskListView.groups = groups
        taskListView.reloadData()
    }
    
    /// 生成测试目标任务数组
    private func makeTestTasks(count: Int, isCompleted: Bool) -> [GoalTask] {
        let calculationValues: [GoalProgressCalculation] = [.sum, .update]
        let recordTypes: [GoalProgressRecordType] = [.manual, .auto]
        
        var tasks = [GoalTask]()
        for index in 0..<count {
            let task = GoalTask()
            task.isAddedToMyDay = index % 2 == 0
            task.note = isCompleted ? "已完成的任务备注" : "任务备注 \(index + 1)"
            task.initialValue = Int64(index * 10)
            task.targetValue = 100
            task.calculation = calculationValues[index % calculationValues.count]
            task.recordType = recordTypes[index % recordTypes.count]
            task.autoRecordValue = recordTypes[index % recordTypes.count] == .auto ? index + 1 : nil
            task.presetRecordValues = [index, index * 2, index * 3]
            task.weight = Int64((index % 10) + 1)
            tasks.append(task)
        }
        
        return tasks
    }
    
    // MARK: - 添加视图
    private func setupAddView() {
        if canAddGoal() {
            let addView = TPAddView()
            addView.normalBackgroundColor = .primary
            addView.didClickAdd = { [weak self] _ in
                self?.clickAddGoal()
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
    /// 更新标题
    private func updateTitle() {
        titleView.title = interactor.title()
        titleView.sizeToFit()
    }
    
    // MARK: - Event Response
    /// 点击更多
    @objc func clickMore(_ button: UIButton) {
        guard let config = self.interactor.planOptionConfig() else {
            return
        }

        let optionMenuController = GoalPlanOptionMenuController(config: config)
        optionMenuController.didSelectPlanOption = { [weak self] option in
//            self?.selectListOption(option)
        }
        
        optionMenuController.didSelectGroupType = { [weak self] groupType in
//            self?.selectGroupType(groupType)
        }
        
        optionMenuController.didSelectSortType = { [weak self] sortType in
//            self?.selectSortType(sortType)
        }
        
        optionMenuController.didSelectSortOrder = { [weak self] sortOrder in
//            self?.selectSortOrder(sortOrder)
        }
        
        let menuItems = optionMenuController.menuItems()
        let menuController = TPLevelMenuViewController(menuItems: menuItems)
        let sourceRect = CGRect(x: moreButton.bounds.maxX,
                                y: moreButton.bounds.maxY,
                                size: .zero)
        menuController.show(from: moreButton, sourceRect: sourceRect, isCovered: false)
    }
    
    /// 点击添加目标
    private func clickAddGoal() {
        TPImpactFeedback.impactWithLightStyle()
        GoalPresenter.createNewGoalTask()
    }
    
    func canAddGoal() -> Bool {
        return true
    }
    
    // MARK: - GoalTaskListViewDelegate
    func goalTaskListView(_ listView: GoalTaskListView, didSelectGoalTask goalTask: GoalTask) {
        TPImpactFeedback.impactWithSoftStyle()
        /// 测试：点击目标任务
    }
    
    func goalTaskListView(_ listView: GoalTaskListView, didClickMoreForGoalTask goalTask: GoalTask) {
        /// 测试：点击目标任务更多按钮
    }
    
    func goalTaskListViewHandleRefresh(_ listView: GoalTaskListView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else {
                return
            }
            
            self.loadTestTaskGroups()
            listView.endRefreshing()
        }
    }
}
