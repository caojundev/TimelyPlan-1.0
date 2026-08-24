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

    private lazy var taskListView: GanttTaskListView = {
        let view = GanttTaskListView()
        return view
    }()
    
    private lazy var timelineView: GanttTimelineView = {
        // 创建时间尺度
        let calendar = Calendar.current
        let today = Date()
        let startDate = calendar.date(byAdding: .month, value: -2, to: today)!
        let endDate = calendar.date(byAdding: .month, value: 6, to: today)!
        let timeScale = GanttTimeScale(scale: .day, startDate: startDate, endDate: endDate)
        
        // 创建 GanttTimelineView
        let view = GanttTimelineView(timeScale: timeScale)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarButtonItems()
        view.addSubview(timelineView)
        view.addSubview(taskListView)
        setupAddView()
        setupTestData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        timelineView.frame = view.safeAreaFrame()
        taskListView.width = 180.0
        taskListView.height = timelineView.height
        taskListView.top = timelineView.top
        
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
    
    // MARK: - Event Response
    private func selectScale(_ scale: GanttTimeScale.Scale) {
        guard timelineView.timeScale.scale != scale else {
            return
        }
        
        var newTimeScale = timelineView.timeScale
        newTimeScale.scale = scale
        timelineView.timeScale = newTimeScale
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
        taskListView.tasks = testTasks
    }

}
