//
//  GanttTimelineMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/23.
//

import Foundation
import UIKit

class GanttTimelineMainViewController: GanttTimelineListViewController, SettingAgentObserver {

    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    }
    
    /// 侧边栏管理器
    var sidebarController: SidebarController?
    
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("ellipsis_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickMore))
        return item
    }()
    
    /// 添加视图
    private lazy var addView: TPAddView = {
        let view = TPAddView()
        view.normalBackgroundColor = .primary
        view.didClickAdd = { [weak self] _ in
            self?.clickAddTask()
        }
        
        return view
    }()

    /// 任务快速添加控制器
    private(set) lazy var quickAddManager: TodoTaskQuickAddManager = {
        let options = TodoQuickAddOptions(showMoreSetting: false, forbidContinuousAdd: true)
        let manager = TodoTaskQuickAddManager(containerViewController: self, options: options)
        return manager
    }()

    /// 事项添加控制器
    private lazy var addController: EventAddController = {
        let controller = EventAddController()
        controller.quickAddManager = quickAddManager
        return controller
    }()

    private let eventProcessor = GanttEventProcessor()

    /// 时间线视图模型
    private let viewModel = GanttTimelineViewModel()
    
    // MARK: - GanttTimelineListViewController

    override var scale: GanttTimeScale.Scale {
        return GanttState.shared.scale
    }
    
    override func additionalRightBarButtonItems() -> [UIBarButtonItem] {
        return [moreBarButtonItem]
    }
    
    override func didSelectScale(_ scale: GanttTimeScale.Scale) {
        GanttState.shared.scale = scale
    }
    
    /// 加载当前时间尺度覆盖范围内的事项
    override func reloadEvents() {
        let range = DateInterval(start: timeScale.startDate, end: timeScale.endDate)
        viewModel.loadEvents(in: range)
    }
    
    override func clickEvent(_ event: GanttEvent) {
        eventProcessor.clickEvent(event)
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSidebarButtonItem()
        setupAddView()
        setupViewModel()
        reloadEvents()

        // 监听并应用行高设置
        GanttSetting.shared.addObserver(self)
        setRowHeightType(GanttSetting.shared.rowHeightType)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        layoutAddView()
    }
     
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    private func layoutAddView() {
        let layoutFrame = view.safeAreaFrame()
        if addView.superview != nil {
            addView.size = Config.addViewSize
            addView.bottom = layoutFrame.maxY - Config.addViewMargins.bottom
            addView.right = layoutFrame.maxX - Config.addViewMargins.right
        }
    }
    
    private func setupSidebarButtonItem() {
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
    }
    
    private func setupAddView() {
        if canAddTask() {
            self.view.insertSubview(addView, at: 999)
        }
    }

    // MARK: - SettingAgentObserver

    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = GanttSetting.Key(name: keyName) else {
            return
        }

        switch key {
        case .rowHeightType:
            setRowHeightType(GanttSetting.shared.rowHeightType)
        case .showCompleted, .showTodo, .showGoal:
            reloadEvents()
        default:
            break
        }
    }
    
    @objc private func clickMore() {
        TPImpactFeedback.impactWithSoftStyle()
        
        let settingVC = GanttTimelineSettingViewController(scale: timeScale.scale)
        settingVC.didSelectScale = { newScale in
            self.selectScale(newScale)
        }

        let navController = UINavigationController(rootViewController: settingVC)
        let configure = TPSlidePresentationConfigure.rightSlideConfigure
        configure.automaticallyAdjustsForKeyboard = false
        configure.cornerRadius = 0.0
        configure.contentSize = CGSize(width: 280.0, height: .greatestFiniteMagnitude)
        configure.edgeInsets = .zero
        slidePresent(navController,
                     configure: configure,
                     isInteractive: true,
                     animated: true,
                     completion: nil)
    }
    
    /// 点击添加
    private func clickAddTask() {
        TPImpactFeedback.impactWithSoftStyle()
        
        // 弹出菜单选择事项类型（待办 / 目标）
        let menuController = MyDayEventAddMenuController(addTypes: [.todo, .goal])
        menuController.didSelectMenuActionType = { [weak self] type in
            guard let self = self else { return }
            let dateInfo = self.addTaskDateInfo(for: type)
            self.addController.performAddMenuAction(with: type, with: dateInfo)
        }
        
        let sourceRect = addView.bounds.insetBy(dx: -5.0, dy: -5.0)
        menuController.showMenu(from: addView,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    /// 计算添加事项的日期信息
    private func addTaskDateInfo(for type: EventAddType) -> TaskDateInfo {
        let date = quickAddTaskDate()
        
        switch type {
        case .goal:
            // 目标：今天开始，一周之后结束（全天）
            let startDate = date.startOfDay()
            let endDate = (date.dateByAddingWeeks(1) ?? date).endOfDay()
            return TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: true)
        default:
            // 其他事项：以当前小时为开始时间，持续一小时
            let startDate = date.dateByReplacingHour(with: Date().hour)
            let endDate = startDate.dateByAddingHours(1) ?? startDate
            return TaskDateInfo(startDate: startDate, endDate: endDate, isAllDay: false)
        }
    }
    
    // MARK: - 数据加载
    
    /// 绑定视图模型回调
    private func setupViewModel() {
        viewModel.onEventsChanged = { [weak self] in
            self?.updateTimelineEvents()
        }
    }
    
    /// 更新甘特图任务数据
    private func updateTimelineEvents() {
        timelineView.events = viewModel.events ?? []
    }
    
    // MARK: - 待办任务操作

    func showQuickAddTask(on date: Date) {
        // 检查并清理过期的草稿任务
        if shouldClearDraftTask(with: date) {
            quickAddManager.clearDraftTask()
        }

        let task = quickAddTask(on: date)
        quickAddManager.show(with: task)
    }
    
    func canAddTask() -> Bool {
        return true
    }
    
    func quickAddTaskDate() -> Date {
        return .now
    }
    
    // MARK: - Helpers
    private func quickAddTask(on date: Date) -> TodoQuickAddTask {
        let dateInfo = TaskDateInfo(date: date)
        let schedule = TaskSchedule(dateInfo: dateInfo,
                                    reminder: nil,
                                    repeatRule: nil)
        let task = TodoQuickAddTask()
        task.schedule = schedule
        return task
    }
    
    private func shouldClearDraftTask(with date: Date) -> Bool {
        guard let draftTask = quickAddManager.draftTask,
              let dateInfo = draftTask.schedule?.dateInfo else {
            return quickAddManager.draftTask != nil // 无日期信息的草稿需要清理
        }
        
        return !dateInfo.startDate.isInSameDayAs(date)
    }

}
