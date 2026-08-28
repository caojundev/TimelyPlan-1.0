//
//  GanttTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/25.
//

import Foundation
import UIKit

class GanttTimelineView: UIView {
    
    /// 当前时间尺度（日/周/月）
    private(set) var timeScale: GanttTimeScale

    /// 任务数据
    var tasks: [GanttEvent] = [] {
        didSet {
            chartView.tasks = tasks
            taskListView.tasks = tasks
        }
    }
    
    /// 顶部刻度视图（只读，供外部访问其内部 collectionView 等）
    var headerView: GanttTimelineHeaderView {
        return _headerView
    }

    /// 甘特图视图（只读）
    var chartView: GanttTimelineChartView {
        return _chartView
    }

    /// 左侧任务列表视图（只读）
    var taskListView: GanttEventListView {
        return _taskListView
    }

    // MARK: - 私有属性

    private let _headerView: GanttTimelineHeaderView
    private let _chartView: GanttTimelineChartView
    private let _taskListView: GanttEventListView

    /// 顶部刻度高度
    private let headerHeight: CGFloat

    /// 左侧任务列表宽度
    private let taskListWidth: CGFloat

    /// 横向滚动同步器
    private let horizontalSynchronizer = HorizontalScrollSynchronizer()

    /// 垂直滚动同步器
    private let verticalSynchronizer = VerticalScrollSynchronizer()

    /// 显示任务列表的按钮（左下角）
    private let toggleButton: TPImageButton

    /// 回到今天的按钮（左下角，toggleButton 右侧）
    private let todayButton: TPImageButton

    /// 任务列表下方的遮罩视图
    private let overlayMaskView: UIControl

    /// 任务列表是否处于显示状态
    private(set) var isTaskListVisible = false {
        didSet {
            toggleButton.isSelected = isTaskListVisible
        }
    }

    /// 最左侧日期（天）改变时回调（转发自 chartView）
    var onDateChanged: ((Date) -> Void)? {
        get { return _chartView.onDateChanged }
        set { _chartView.onDateChanged = newValue }
    }

    // MARK: - 初始化

    /// - Parameters:
    ///   - frame: 初始 frame
    ///   - timeScale: 时间尺度
    ///   - headerHeight: 顶部刻度高度
    ///   - taskListWidth: 左侧任务列表宽度
    init(frame: CGRect,
         timeScale: GanttTimeScale,
         headerHeight: CGFloat = GanttTimelineConfig.headerHeight,
         taskListWidth: CGFloat = GanttTimelineConfig.taskListWidth) {
        self.timeScale = timeScale
        self.headerHeight = headerHeight
        self.taskListWidth = taskListWidth
        self._headerView = GanttTimelineHeaderView(
            frame: .zero,
            headerHeight: headerHeight,
            timeScale: timeScale
        )
        self._chartView = GanttTimelineChartView(timeScale: timeScale)
        self._taskListView = GanttEventListView(frame: .zero)
        self.toggleButton = TPImageButton()
        self.todayButton = TPImageButton()
        self.overlayMaskView = UIControl()
        super.init(frame: frame)

        setupViews()
        setupScrollSynchronization()
        setupTaskList()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 视图设置

    private func setupViews() {
        addSubview(_headerView)
        addSubview(_chartView)
    }

    private func setupScrollSynchronization() {
        horizontalSynchronizer.addSyncableView(_headerView)
        horizontalSynchronizer.addSyncableView(_chartView)
        verticalSynchronizer.addSyncableView(_chartView)
        verticalSynchronizer.addSyncableView(_taskListView)
    }

    private func setupTaskList() {
        // 遮罩视图
        overlayMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        overlayMaskView.addTarget(self, action: #selector(maskTapped), for: .touchUpInside)
        overlayMaskView.isHidden = true

        // 显示/隐藏任务列表按钮（左下角）
        toggleButton.normalImage = resGetImage("gantt_taskList_toggle_normal_24")
        toggleButton.selectedImage = resGetImage("gantt_taskList_toggle_active_24")
        toggleButton.cornerRadius = .greatestFiniteMagnitude
        toggleButton.normalBackgroundColor = .systemBackground
        toggleButton.selectedBackgroundColor = .primary
        toggleButton.borderWidth = 1.0
        toggleButton.normalBorderColor = UIColor.lightGray.withAlphaComponent(0.5)
        toggleButton.selectedBorderColor = .clear
        toggleButton.normalImageColor = .label
        toggleButton.selectedImageColor = .white
        toggleButton.imageSize = .mini
        toggleButton.addTarget(self, action: #selector(toggleTaskList), for: .touchUpInside)
        toggleButton.isSelected = isTaskListVisible
        
        // 回到今天按钮
        todayButton.normalImage = resGetImage("gantt_backToday_24")
        todayButton.cornerRadius = .greatestFiniteMagnitude
        todayButton.normalBackgroundColor = .systemBackground
        todayButton.borderWidth = 1.0
        todayButton.normalBorderColor = UIColor.lightGray.withAlphaComponent(0.5)
        todayButton.normalImageColor = .label
        todayButton.imageSize = .mini
        todayButton.addTarget(self, action: #selector(scrollToTodayTapped), for: .touchUpInside)

        addSubview(overlayMaskView)
        addSubview(_taskListView)
        addSubview(toggleButton)
        addSubview(todayButton)

        // 点击任务列表中的任务时，将对应任务滚动到可视位置
        _taskListView.onTaskSelect = { [weak self] task in
            TPImpactFeedback.impactWithSoftStyle()
            self?.hideTaskList(animated: true)
            self?.chartView.scrollToTaskStart(task)
        }
        
        // 初始状态：隐藏在最左侧
        _taskListView.frame = CGRect(x: -taskListWidth,
                                     y: headerHeight,
                                     width: taskListWidth,
                                     height: bounds.height - headerHeight)
    }

    @objc private func toggleTaskList() {
        if isTaskListVisible {
            hideTaskList()
        } else {
            showTaskList()
        }
    }

    @objc private func maskTapped() {
        TPImpactFeedback.impactWithSoftStyle()
        hideTaskList()
    }

    @objc private func scrollToTodayTapped() {
        scrollToToday()
    }

    /// 显示任务列表
    func showTaskList(animated: Bool = true) {
        guard !isTaskListVisible else { return }
        isTaskListVisible = true

        overlayMaskView.isHidden = false
        overlayMaskView.alpha = 0
        todayButton.isHidden = true

        let show = {
            self._taskListView.frame.origin.x = 0
            self.overlayMaskView.alpha = 1
        }
        let completion: (Bool) -> Void = { _ in }

        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .beginFromCurrentState,
                           animations: show,
                           completion: completion)
        } else {
            show()
            completion(true)
        }
    }

    /// 隐藏任务列表
    func hideTaskList(animated: Bool = true) {
        guard isTaskListVisible else { return }
        isTaskListVisible = false
        
        let hide = {
            self._taskListView.frame.origin.x = -self.taskListWidth
            self.overlayMaskView.alpha = 0
            self.todayButton.isHidden = false
        }
        let completion: (Bool) -> Void = { _ in
            if !self.isTaskListVisible {
                self.overlayMaskView.isHidden = true
            }
        }

        if animated {
            UIView.animate(withDuration: 0.25,
                           delay: 0.0,
                           options: .beginFromCurrentState,
                           animations: hide,
                           completion: completion)
        } else {
            hide()
            completion(true)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        _headerView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: bounds.width,
                                   height: headerHeight)
        _chartView.frame = CGRect(x: 0,
                                  y: headerHeight,
                                  width: bounds.width,
                                  height: bounds.height - headerHeight)

        // 任务列表
        _taskListView.frame = CGRect(x: isTaskListVisible ? 0 : -taskListWidth,
                                     y: headerHeight,
                                     width: taskListWidth,
                                     height: bounds.height - headerHeight)

        // 遮罩视图（覆盖任务列表下方区域）
        overlayMaskView.frame = CGRect(x: 0,
                                       y: headerHeight,
                                       width: bounds.width,
                                       height: bounds.height - headerHeight)

        // 左下角按钮
        let buttonSize: CGFloat = 48.0
        let buttonY = bounds.height - buttonSize - 12.0
        toggleButton.frame = CGRect(x: 18,
                                    y: buttonY,
                                    width: buttonSize,
                                    height: buttonSize)
        todayButton.frame = CGRect(x: toggleButton.right + 16.0,
                                   y: buttonY,
                                   width: buttonSize,
                                   height: buttonSize)
    }

    // MARK: - 公开方法

    /// 切换时间刻度
    func setTimeScale(_ timeScale: GanttTimeScale) {
        guard self.timeScale != timeScale else {
            return
        }
        
        self.timeScale = timeScale
        chartView.timeScale = timeScale
        headerView.configure(timeScale: timeScale)
    }

    /// 滚动到"今天"所在位置
    func scrollToToday(animated: Bool = true) {
        chartView.scrollToToday(animated: animated)
    }

    /// 滚动到指定日期位置
    func scrollToDate(_ date: Date, animated: Bool = false) {
        chartView.scrollToDate(date, animated: animated)
    }

    /// 滚动到任务开始位置
    func scrollToTaskStart(_ task: GanttEvent) {
        chartView.scrollToTaskStart(task)
    }

    /// 滚动到任务结束位置
    func scrollToTaskEnd(_ task: GanttEvent) {
        chartView.scrollToTaskEnd(task)
    }
}
