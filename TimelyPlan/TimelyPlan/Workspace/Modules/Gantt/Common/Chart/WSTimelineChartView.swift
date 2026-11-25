//
//  WSTimelineChartView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的事项区域
///
/// 组件不滚动，只展示固定数量的行：高度平均分为 `WSTimelineChartConfig.eventRowCount` 等分，
/// 每行显示一个事项；没有事项的行只显示交替底色。整体相当于某个时间段的快照。
final class WSTimelineChartView: UIView {

    /// 点击甘特条回调
    var onEventTap: ((GanttEvent) -> Void)?

    /// 当前展示的时间范围
    private var timeRange: WSTimelineChartTimeRange?

    /// 当前展示的事项，按顺序与行一一对应
    private var events: [GanttEvent] = []

    /// 事项行视图
    private var rowViews: [WSGanttChartEventRowView] = []

    /// 今天指示线，覆盖显示在事项行上方
    private let todayLine = GanttTimelineNowLineView()

    /// 今天指示线宽度（容纳顶部圆点）
    private let todayLineWidth: CGFloat = 6.0

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        clipsToBounds = true
        backgroundColor = WSTimelineChartConfig.chartBackgroundColor

        for index in 0..<WSTimelineChartConfig.eventRowCount {
            let rowView = WSGanttChartEventRowView()
            rowView.backgroundColor = index % 2 == 0
                ? WSTimelineChartConfig.rowBackgroundColor
                : WSTimelineChartConfig.alternateRowBackgroundColor
            rowView.onEventTap = { [weak self] event in
                self?.onEventTap?(event)
            }

            addSubview(rowView)
            rowViews.append(rowView)
        }

        todayLine.isUserInteractionEnabled = false
        addSubview(todayLine)
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let rowCount = max(rowViews.count, 1)
        let rowHeight = bounds.height / CGFloat(rowCount)

        for (index, rowView) in rowViews.enumerated() {
            rowView.frame = CGRect(x: 0.0,
                                   y: CGFloat(index) * rowHeight,
                                   width: bounds.width,
                                   height: rowHeight)
            rowView.configure(event: events[safe: index], timeRange: timeRange)
        }

        updateTodayLine()
    }

    // MARK: - 数据

    /// 绑定时间范围与事项。事项按顺序与行一一对应，超出的部分不展示
    func configure(timeRange: WSTimelineChartTimeRange, events: [GanttEvent]) {
        self.timeRange = timeRange
        self.events = Array(events.prefix(rowViews.count))

        setNeedsLayout()
    }

    // MARK: - 今天指示线

    /// 更新今天指示线位置。今天不在展示范围内时隐藏
    private func updateTodayLine() {
        guard let timeRange = timeRange, bounds.width > 0.0 else {
            todayLine.isHidden = true
            return
        }

        let now = Date()
        guard now >= timeRange.startDate, now <= timeRange.endDate else {
            todayLine.isHidden = true
            return
        }

        let x = timeRange.xPosition(for: now, in: bounds.width)
        todayLine.isHidden = x < -todayLineWidth || x > bounds.width + todayLineWidth
        todayLine.frame = CGRect(x: x - todayLineWidth / 2.0,
                                 y: 0.0,
                                 width: todayLineWidth,
                                 height: bounds.height)
    }
}
