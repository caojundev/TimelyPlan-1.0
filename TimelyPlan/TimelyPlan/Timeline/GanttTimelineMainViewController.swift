//
//  GanttTimelineMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/23.
//

import Foundation
import UIKit

class GanttTimelineMainViewController: TPViewController {

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
        let timeScale = GanttTimeScale(scale: .day, date: date)
        return timeScale
    }()
    
    private lazy var timelineView: GanttTimelineView = {
        let view = GanttTimelineView(
            frame: .zero,
            timeScale: timeScale,
            headerHeight: GanttTimelineConfig.headerHeight
        )
        
        // 日期改变时更新标题
        view.onDateChanged = { [weak self] date in
            self?.timelineVisbleDateChanged(date)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = dateButton
        updateTitle()
        
        setupBarButtonItems()
        view.addSubview(timelineView)
        setupAddView()
        setupTestData()
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
    
    // MARK: - Event Response
    
    private func timelineVisbleDateChanged(_ date: Date) {
        guard self.date.isInSameYearAs(date) else {
            return
        }
        
        self.date = date
        updateTitle()
    }
    
    private func selectScale(_ scale: GanttTimeScale.Scale) {
        guard timelineView.timeScale.scale != scale else {
            return
        }
        
        let newTimeScale = GanttTimeScale(scale: scale, date: date)
        timelineView.setTimeScale(newTimeScale)
        timelineView.scrollToDate(date, animated: false)
    }
    
    @objc private func clickMore() {
        TPImpactFeedback.impactWithSoftStyle()
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
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        self.date = date
        updateTitle()
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
    
    
    private func setupTestData() {
        let calendar = Calendar.current
        let today = Date()
        
        var testTasks: [GanttTask] = []
        
        // 创建测试任务
        for phase in 1...5 {
            let phaseColor = UIColor(hue: CGFloat(phase) / 5.0, saturation: 0.6, brightness: 0.8, alpha: 1.0)
            
            // 创建子任务
            var children: [GanttTask] = []
            for i in 1...3 {
                let child = GanttTask(
                    id: "\(phase).\(i)",
                    name: "任务 \(phase).\(i)",
                    startDate: calendar.date(byAdding: .day, value: (phase - 1) * 20 + i * 2, to: today)!,
                    endDate: calendar.date(byAdding: .day, value: (phase - 1) * 20 + i * 2 + 10, to: today)!,
                    progress: CGFloat(i) / 3.0,
                    color: phaseColor,
                    level: 1
                )
                children.append(child)
            }
            
            // 创建组任务
            let group = GanttTask(
                id: "\(phase)",
                name: "阶段 \(phase)",
                startDate: calendar.date(byAdding: .day, value: (phase - 1) * 20, to: today)!,
                endDate: calendar.date(byAdding: .day, value: (phase - 1) * 20 + 18, to: today)!,
                progress: CGFloat(phase % 4) / 4.0,
                color: phaseColor,
                level: 0,
                children: children
            )
            testTasks.append(group)
        }
        
        // 添加一些独立任务
        for i in 1...10 {
            let task = GanttTask(
                id: "standalone_\(i)",
                name: "独立任务 \(i)",
                startDate: calendar.date(byAdding: .day, value: i * 5 - 10, to: today)!,
                endDate: calendar.date(byAdding: .day, value: i * 5 + 5, to: today)!,
                progress: CGFloat(i) / 10.0,
                color: UIColor.systemBlue,
                level: 0
            )
            testTasks.append(task)
        }
        
        timelineView.tasks = testTasks
    }

}
