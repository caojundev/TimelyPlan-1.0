//
//  GanttTimelineMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/23.
//

import Foundation
import UIKit

class GanttTimelineMainViewController: TPViewController, SettingAgentObserver {

    struct Config {
        /// 添加视图按钮
        static let addViewSize = CGSize(width: 50.0, height: 50.0)
        /// 添加视图边界间距
        static let addViewMargins = UIEdgeInsets(top: 10.0, left: 0.0, bottom: 10.0, right: 20.0)
    }
    
    /// 侧边栏管理器
    var sidebarController: SidebarController?
    
    /// 日期按钮
    lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var scaleBarButtonItem: GanttTimeScaleBarButtonItem = {
        let item = GanttTimeScaleBarButtonItem()
        item.scale = GanttState.shared.scale
        item.didSelectScale = { [weak self] scale in
            self?.selectScale(scale)
        }
        
        return item
    }()
    
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("ellipsis_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickMore))
        return item
    }()

    private lazy var timeScale: GanttTimeScale = {
        // 创建时间尺度
        let scale = GanttState.shared.scale
        let timeScale = GanttTimeScale(scale: scale, date: date)
        return timeScale
    }()
    
    private lazy var timelineView: GanttTimelineView = { [weak self] in
        let view = GanttTimelineView(
            frame: .zero,
            timeScale: timeScale,
            headerHeight: GanttTimelineConfig.headerHeight
        )
        
        // 日期改变时更新标题
        view.onDateChanged = { date in
            self?.timelineVisbleDateChanged(date)
        }
        
        view.onBarTap = { event in
            self?.eventProcessor.clickEvent(event)
        }
        
        return view
    }()
    
    /// 添加视图
    private var addView: TPAddView?

    /// 任务快速添加控制器
    private(set) lazy var quickAddManager: TodoTaskQuickAddManager = {
        let options = TodoQuickAddOptions(showMoreSetting: false, forbidContinuousAdd: true)
        let manager = TodoTaskQuickAddManager(containerViewController: self, options: options)
        return manager
    }()

    /// 当前显示日期
    var date: Date = .now

    /// 是否已滚动到初始日期（仅首次进入时执行一次）
    private var hasScrolledToInitialDate = false

    private let eventProcessor = GanttEventProcessor()

    /// 时间线视图模型
    private let viewModel = GanttTimelineViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = dateButton
        updateTitle()
        
        setupBarButtonItems()
        view.addSubview(timelineView)
        setupAddView()
        setupViewModel()
        loadEvents()

        // 监听并应用行高设置
        GanttSetting.shared.addObserver(self)
        applyRowHeightType(GanttSetting.shared.rowHeightType)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        timelineView.frame = view.safeAreaFrame()
        layoutAddView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 首次布局完成后滚动到初始日期位置
        if !hasScrolledToInitialDate {
            hasScrolledToInitialDate = true
            timelineView.scrollToDate(date, animated: false)
        }
    }
     
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    private func layoutAddView() {
        let layoutFrame = view.safeAreaFrame()
        if let addView = addView {
            addView.size = Config.addViewSize
            addView.bottom = layoutFrame.maxY - Config.addViewMargins.bottom
            addView.right = layoutFrame.maxX - Config.addViewMargins.right
        }
    }
    
    private func setupBarButtonItems() {
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
    
        navigationItem.rightBarButtonItems = [moreBarButtonItem,
                                              scaleBarButtonItem]
    }
    
    private func setupAddView() {
        if canAddTask() {
            let addView = TPAddView()
            addView.normalBackgroundColor = .primary
            addView.didClickAdd = { [weak self] _ in
                self?.clickAddTask()
            }
           
            self.addView = addView
            self.view.insertSubview(addView, at: 999)
        }
    }
    
    // MARK: - Update
    
    private func updateTitle() {
        dateButton.title = date.slashFormattedYearMonthString
    }

    // MARK: - 行高设置

    /// 应用行高类型到时间线视图
    private func applyRowHeightType(_ type: GanttRowHeightType) {
        timelineView.setRowHeightType(type)
    }

    // MARK: - SettingAgentObserver

    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = GanttSetting.Key(name: keyName) else {
            return
        }

        switch key {
        case .rowHeightType:
            applyRowHeightType(GanttSetting.shared.rowHeightType)
        case .showCompleted, .showTodo:
            loadEvents()
        default:
            break
        }
    }
    
    private func timelineVisbleDateChanged(_ date: Date) {
        guard self.date.isInSameYearAs(date) else {
            return
        }
        
        self.date = date
        updateTitle()
    }
    
    private func selectScale(_ scale: GanttTimeScale.Scale) {
        GanttState.shared.scale = scale
        
        scaleBarButtonItem.scale = scale
        timeScale = GanttTimeScale(scale: scale, date: date)
        timelineView.setTimeScale(self.timeScale)
        timelineView.scrollToDate(date, animated: false)
        updateTitle()
        loadEvents()
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
        TPImpactFeedback.impactWithLightStyle()
        
        // 检查并清理过期的草稿任务
        let date = quickAddTaskDate()
        showQuickAddTask(on: date)
    }
    
    @objc private func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = date
        datePickerVC.yearRange = CalendarYearConfig.yearRange
        datePickerVC.didPickDate = { date in
            self.pickDate(date.startOfMonth())
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        if self.date.isInSameMonthAs(date) {
            return
        }
        
        let animated = self.date.isInSameYearAs(date)
        self.date = date
        updateTitle()
        
        let scale = self.timeScale.scale
        self.timeScale = GanttTimeScale(scale: scale, date: date)
        
        timelineView.setTimeScale(self.timeScale)
        timelineView.scrollToDate(date, animated: animated)
        
        loadEvents()
    }
    
    // MARK: - 数据加载
    
    /// 绑定视图模型回调
    private func setupViewModel() {
        viewModel.onEventsChanged = { [weak self] in
            self?.updateTimelineTasks()
        }
    }
    
    /// 加载当前时间尺度覆盖范围内的事项
    private func loadEvents() {
        let range = DateInterval(start: timeScale.startDate, end: timeScale.endDate)
        viewModel.loadEvents(in: range)
    }
    
    /// 更新甘特图任务数据
    private func updateTimelineTasks() {
        timelineView.tasks = viewModel.events ?? []
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
