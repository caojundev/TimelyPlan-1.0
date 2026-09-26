//
//  GanttTimelineListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/26.
//

import Foundation
import UIKit

/// 甘特图时间线基类
///
/// 职责：
/// - 提供 `dateButton`、`scaleBarButtonItem`、`timelineView` 等与时间线展示相关的 UI 与交互
/// - 管理时间尺度、可见日期以及导航栏标题的刷新
class GanttTimelineListViewController: TPViewController {

    // MARK: - 可重写配置

    /// 当前时间刻度（子类可重写以读取持久化状态）
    var scale: GanttTimeScale.Scale {
        return scaleBarButtonItem.scale
    }

    // MARK: - 视图

    /// 日期按钮
    lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()

    /// 时间刻度按钮
    lazy var scaleBarButtonItem: GanttTimeScaleBarButtonItem = {
        let item = GanttTimeScaleBarButtonItem()
        item.scale = scale
        item.didSelectScale = { [weak self] scale in
            self?.selectScale(scale)
        }

        return item
    }()

    /// 时间尺度
    private(set) lazy var timeScale: GanttTimeScale = {
        return GanttTimeScale(scale: scale, date: date)
    }()

    /// 时间线视图
    lazy var timelineView: GanttTimelineView = { [weak self] in
        let view = GanttTimelineView(
            frame: .zero,
            timeScale: timeScale,
            headerHeight: GanttTimelineConfig.headerHeight
        )

        // 可见日期改变时更新标题
        view.onDateChanged = { date in
            self?.timelineVisbleDateChanged(date)
        }

        // 点击事项
        view.onBarTap = { event in
            self?.clickEvent(event)
        }

        return view
    }()

    // MARK: - 状态

    /// 当前显示日期
    var date: Date = .now

    /// 是否已滚动到初始日期（仅首次进入时执行一次）
    private var hasScrolledToInitialDate = false

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = dateButton
        updateTitle()

        setupBarButtonItems()
        view.addSubview(timelineView)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        timelineView.frame = view.safeAreaFrame()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // 首次布局完成后滚动到初始日期位置
        if !hasScrolledToInitialDate {
            hasScrolledToInitialDate = true
            timelineView.scrollToDate(date, animated: false)
        }
    }

    // MARK: - 子类重写

    /// 右侧附加的导航栏按钮（位于时间刻度按钮之前）
    func additionalRightBarButtonItems() -> [UIBarButtonItem] {
        return []
    }

    /// 时间刻度改变（子类可在此持久化状态）
    func didSelectScale(_ scale: GanttTimeScale.Scale) {
    }

    /// 加载当前时间尺度范围内的事项（子类重写）
    func reloadEvents() {
    }

    /// 点击事项（子类重写）
    func clickEvent(_ event: GanttEvent) {
    }

    // MARK: - 视图设置

    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItems = additionalRightBarButtonItems() + [scaleBarButtonItem]
    }

    /// 更新标题
    func updateTitle() {
        dateButton.title = date.slashFormattedYearMonthString
    }

    // MARK: - 时间线

    /// 应用行高类型到时间线视图
    func setRowHeightType(_ type: GanttRowHeightType) {
        timelineView.setRowHeightType(type)
    }

    /// 可见日期改变
    private func timelineVisbleDateChanged(_ date: Date) {
        guard self.date.isInSameYearAs(date) else {
            return
        }

        self.date = date
        updateTitle()
    }

    /// 选择时间刻度
    func selectScale(_ scale: GanttTimeScale.Scale) {
        didSelectScale(scale)

        scaleBarButtonItem.scale = scale
        timeScale = GanttTimeScale(scale: scale, date: date)
        timelineView.setTimeScale(self.timeScale)
        timelineView.scrollToDate(date, animated: false)
        updateTitle()
        reloadEvents()
    }

    // MARK: - 事件响应

    /// 点击日期按钮
    @objc private func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = date
        datePickerVC.yearRange = CalendarYearConfig.yearRange
        datePickerVC.didPickDate = { [weak self] date in
            self?.pickDate(date.startOfMonth())
        }

        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }

    /// 选择日期
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

        reloadEvents()
    }
}
