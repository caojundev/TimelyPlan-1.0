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
    var tasks: [GanttTask] = [] {
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
    var taskListView: GanttTaskListView {
        return _taskListView
    }

    // MARK: - 私有属性

    private let _headerView: GanttTimelineHeaderView
    private let _chartView: GanttTimelineChartView
    private let _taskListView: GanttTaskListView

    /// 顶部刻度高度
    private let headerHeight: CGFloat

    /// 左侧任务列表宽度
    private let taskListWidth: CGFloat

    /// 横向滚动同步器
    private let horizontalSynchronizer = HorizontalScrollSynchronizer()

    /// 垂直滚动同步器
    private let verticalSynchronizer = VerticalScrollSynchronizer()

    /// 显示任务列表的按钮（左下角）
    private let toggleButton: UIButton

    /// 任务列表下方的遮罩视图
    private let overlayMaskView: UIControl

    /// 任务列表是否处于显示状态
    private(set) var isTaskListVisible = false

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
        self._taskListView = GanttTaskListView(frame: .zero)
        self.toggleButton = UIButton(type: .system)
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
        toggleButton.setImage(resGetImage("sideMenu_24"), for: .normal)
        toggleButton.tintColor = .label
        toggleButton.backgroundColor = .systemBackground
        toggleButton.layer.cornerRadius = 8
        toggleButton.layer.borderWidth = 1
        toggleButton.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        toggleButton.addTarget(self, action: #selector(toggleTaskList), for: .touchUpInside)

        addSubview(overlayMaskView)
        addSubview(_taskListView)
        addSubview(toggleButton)

        // 初始状态：隐藏在最左侧
        _taskListView.frame = CGRect(x: -taskListWidth,
                                     y: headerHeight,
                                     width: taskListWidth,
                                     height: bounds.height - headerHeight)
    }

    @objc private func toggleTaskList() {
        isTaskListVisible ? hideTaskList() : showTaskList()
    }

    @objc private func maskTapped() {
        hideTaskList()
    }

    /// 显示任务列表
    func showTaskList(animated: Bool = true) {
        guard !isTaskListVisible else { return }
        isTaskListVisible = true

        overlayMaskView.isHidden = false
        overlayMaskView.alpha = 0

        let show = {
            self._taskListView.frame.origin.x = 0
            self.overlayMaskView.alpha = 1
        }
        let completion: (Bool) -> Void = { _ in }

        if animated {
            UIView.animate(withDuration: 0.25, animations: show, completion: completion)
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
        }
        let completion: (Bool) -> Void = { _ in
            self.overlayMaskView.isHidden = true
        }

        if animated {
            UIView.animate(withDuration: 0.25, animations: hide, completion: completion)
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
        let buttonSize: CGFloat = 36
        toggleButton.frame = CGRect(x: 12,
                                    y: bounds.height - buttonSize - 12,
                                    width: buttonSize,
                                    height: buttonSize)
    }

    // MARK: - 公开方法

    /// 切换时间刻度
    func setScale(_ scale: GanttTimeScale.Scale) {
        guard timeScale.scale != scale else {
            return
        }

        var newTimeScale = timeScale
        newTimeScale.scale = scale
        timeScale = newTimeScale
        chartView.timeScale = newTimeScale
        headerView.configure(timeScale: newTimeScale)
    }

    /// 滚动到"今天"所在位置
    func scrollToToday(animated: Bool = true) {
        chartView.scrollToToday(animated: animated)
    }

    /// 滚动到任务开始位置
    func scrollToTaskStart(_ task: GanttTask) {
        chartView.scrollToTaskStart(task)
    }

    /// 滚动到任务结束位置
    func scrollToTaskEnd(_ task: GanttTask) {
        chartView.scrollToTaskEnd(task)
    }
}
