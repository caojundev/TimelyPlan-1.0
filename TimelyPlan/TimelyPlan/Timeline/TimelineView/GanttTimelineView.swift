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

    // MARK: - 私有属性

    private let _headerView: GanttTimelineHeaderView
    private let _chartView: GanttTimelineChartView

    /// 顶部刻度高度
    private let headerHeight: CGFloat

    /// 横向滚动同步器
    private let horizontalSynchronizer = HorizontalScrollSynchronizer()

    // MARK: - 初始化

    /// - Parameters:
    ///   - frame: 初始 frame
    ///   - timeScale: 时间尺度
    ///   - headerHeight: 顶部刻度高度
    init(frame: CGRect, timeScale: GanttTimeScale, headerHeight: CGFloat = 60) {
        self.timeScale = timeScale
        self.headerHeight = headerHeight
        self._headerView = GanttTimelineHeaderView(
            frame: .zero,
            headerHeight: headerHeight,
            timeScale: timeScale
        )
        self._chartView = GanttTimelineChartView(timeScale: timeScale)
        super.init(frame: frame)

        setupViews()
        setupScrollSynchronization()
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
