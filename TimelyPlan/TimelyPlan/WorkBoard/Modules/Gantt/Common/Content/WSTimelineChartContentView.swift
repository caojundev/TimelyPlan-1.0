//
//  WSTimelineChartContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的内容视图
///
/// 上方为日期按钮与刻度，下方为事项区域；不再提供事项列表与刻度切换入口。
final class WSTimelineChartContentView: WSPluginContentView {

    private let headerView: WSTimelineChartHeaderView
    private let chartView: WSTimelineChartView
    private let dateButton: CalendarDateButton

    /// 回到今天按钮
    private let todayButton: TPImageButton

    /// 当前展示日期
    private var date: Date = .now

    /// 选择日期后等待数据刷新完成再滚动到该日期
    private var pendingScrollDate: Date?

    init(timeScale: GanttTimeScale) {
        self.headerView = WSTimelineChartHeaderView()
        self.chartView = WSTimelineChartView(timeScale: timeScale)
        self.dateButton = CalendarDateButton()
        self.dateButton.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        self.dateButton.titleConfig.textColor = Color(light: 0x232323,
                                                      dark: 0xf0f0f0)
        self.todayButton = TPImageButton()
        super.init(frame: .zero)

        headerView.timeScale = timeScale
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 视图设置

    private func setupViews() {
        addSubview(headerView)
        addSubview(chartView)

        dateButton.title = date.slashFormattedYearMonthString
        dateButton.addTarget(self, action: #selector(clickDate), for: .touchUpInside)
        addSubview(dateButton)

        chartView.onEventTap = { [weak self] event in
            (self?.interactor as? WSTimelineChartContentInteractor)?.openEvent(event)
        }

        chartView.onContentOffsetChange = { [weak self] xOffset in
            self?.headerView.contentOffsetX = xOffset
        }

        chartView.onDateChanged = { [weak self] date in
            self?.visibleDateChanged(date)
        }

        todayButton.normalImage = resGetImage("gantt_backToday_24")
        todayButton.normalImageColor = .label
        todayButton.imageSize = CGSize.size(5)
        todayButton.cornerRadius = .greatestFiniteMagnitude
        todayButton.normalBackgroundColor = .systemBackground
        todayButton.borderWidth = 1.0
        todayButton.normalBorderColor = UIColor.lightGray.withAlphaComponent(0.25)
        todayButton.hitTestEdgeInsets = UIEdgeInsets(value: -6.0)
        todayButton.addTarget(self, action: #selector(scrollToToday), for: .touchUpInside)
        addSubview(todayButton)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let headerTop = WSTimelineChartConfig.headerTopInset
        let headerHeight = WSTimelineChartConfig.headerHeight
        headerView.frame = CGRect(x: 0.0, y: headerTop, width: width, height: headerHeight)
        chartView.frame = CGRect(x: 0.0,
                                 y: headerTop + headerHeight,
                                 width: width,
                                 height: max(height - headerTop - headerHeight, 0.0))

        dateButton.sizeToFit()
        dateButton.center = CGPoint(x: width / 2.0, y: headerTop / 2.0)

        todayButton.size = CGSize.size(7)
        todayButton.right = width - 12.0
        todayButton.centerY = dateButton.centerY

        /// 布局变化后同步刻度偏移（如图层尺寸变化导致内容偏移被修正）
        headerView.contentOffsetX = chartView.contentOffsetX
    }

    // MARK: - 渲染

    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)

        guard let dataItem = dataItem as? WSTimelineChartDataItem else { return }

        /// 数据年份与当前展示年份不同（如单元格复用后交互器重新创建）时，同步日期按钮
        if !date.isInSameYearAs(dataItem.date) {
            date = dataItem.date
            dateButton.title = dataItem.date.slashFormattedYearMonthString
        }

        headerView.timeScale = dataItem.timeScale
        chartView.configure(timeScale: dataItem.timeScale, events: dataItem.events)

        if let scrollDate = pendingScrollDate {
            pendingScrollDate = nil
            chartView.scroll(to: scrollDate, animated: true)
        }

        setNeedsLayout()
    }

    // MARK: - 日期

    /// 点击日期按钮，选择年月
    @objc private func clickDate() {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = date
        datePickerVC.yearRange = CalendarYearConfig.yearRange
        datePickerVC.didPickDate = { [weak self] date in
            self?.pickDate(date.startOfMonth())
        }

        datePickerVC.popoverShow(from: dateButton, preferredPosition: .bottomCenter)
    }

    private func pickDate(_ date: Date, scrollTo scrollDate: Date? = nil) {
        guard !self.date.isInSameMonthAs(date) else {
            if let scrollDate = scrollDate {
                chartView.scroll(to: scrollDate, animated: true)
            }

            return
        }

        self.date = date
        dateButton.title = date.slashFormattedYearMonthString
        setNeedsLayout()

        pendingScrollDate = scrollDate ?? date
        (interactor as? WSTimelineChartContentInteractor)?.setDate(date)
    }

    /// 时间线水平滚动导致左侧可见日期变化时，同步日期按钮（与甘特主视图一致，仅同年更新）
    private func visibleDateChanged(_ date: Date) {
        guard self.date.isInSameYearAs(date) else { return }

        let monthChanged = !self.date.isInSameMonthAs(date)
        self.date = date

        guard monthChanged else { return }

        dateButton.title = date.slashFormattedYearMonthString
        setNeedsLayout()
    }

    // MARK: - 交互

    /// 回到今天。当前不是今天所在年份时，按日期选择逻辑切换到今年
    @objc private func scrollToToday() {
        TPImpactFeedback.impactWithSoftStyle()

        let today = Date()
        if date.isInSameYearAs(today) {
            chartView.scrollToToday(animated: true)
            return
        }

        pickDate(today.startOfMonth(), scrollTo: today)
    }
}
