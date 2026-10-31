//
//  WSGanttChartEventRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/29.
//

import Foundation
import UIKit

/// 甘特图组件的事项行视图
///
/// 显示内容与甘特主视图的 `TimelineCell` 一致（甘特条 + 进度 + 图标标题），
/// 但组件不滚动、整行都在可视范围内，因此不提供左右两侧的边缘指示器。
final class WSGanttChartEventRowView: UIView {

    // MARK: - 属性

    /// 点击甘特条回调
    var onEventTap: ((GanttEvent) -> Void)?

    /// 甘特条
    private let barView = UIView()

    /// 进度视图
    private let progressView = UIView()

    /// 甘特条信息视图（图标 + 标题）
    private let infoView = GanttTimelineChartBarInfoView()

    /// 当前展示的事项
    private(set) var event: GanttEvent?

    /// 当前展示的时间范围
    private var timeRange: WSTimelineChartTimeRange?

    /// 甘特条内部标题颜色
    private let insideTitleColor = Color(0xf2f2f2)

    /// 甘特条外部标题颜色
    private let outsideTitleColor = Color(light: 0x121212, dark: 0xf2f2f2)

    /// 信息视图可以显示在甘特条内部的最小条宽
    private let infoInBarMinBarWidth: CGFloat = 240.0

    /// 信息视图的最大宽度
    private let infoMaxWidth: CGFloat = 240.0

    // MARK: - 初始化

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear
        clipsToBounds = true

        barView.layer.borderWidth = 1.0
        barView.layer.masksToBounds = true
        barView.isUserInteractionEnabled = true
        barView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(barTapped)))

        progressView.isUserInteractionEnabled = false

        infoView.resetContent()
        infoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(barTapped)))

        addSubview(barView)
        barView.addSubview(progressView)
        /// 信息视图作为行视图的子视图，避免被甘特条裁剪，窄条时可以显示在条的外侧
        addSubview(infoView)
    }

    // MARK: - 数据

    /// 绑定事项与时间范围。事项为 nil 时只保留行底色
    func configure(event: GanttEvent?, timeRange: WSTimelineChartTimeRange?) {
        self.event = event
        self.timeRange = timeRange

        guard event != nil else {
            resetBarViews()
            return
        }

        setNeedsLayout()
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        guard let event = event,
              let timeRange = timeRange,
              bounds.width > 0.0,
              bounds.height > 0.0 else {
            resetBarViews()
            return
        }

        let rowHeight = bounds.height
        let barHeight = min(rowHeight - GanttTimelineConfig.barVerticalInset * 2.0,
                            GanttTimelineConfig.barMaxHeight)
        guard barHeight > 0.0 else {
            resetBarViews()
            return
        }

        let startX = timeRange.xPosition(for: event.startDate, in: bounds.width)
        let endX = timeRange.xPosition(for: event.endDate, in: bounds.width)

        /// 事项完全落在展示范围之外时不绘制
        guard endX > 0.0, startX < bounds.width else {
            resetBarViews()
            return
        }

        let barLeft = max(startX, 0.0)
        let barRight = min(max(endX, barLeft + GanttTimelineConfig.barMinWidth), bounds.width)
        let barWidth = barRight - barLeft
        guard barWidth > 0.0 else {
            resetBarViews()
            return
        }

        let barY = (rowHeight - barHeight) / 2.0
        layoutBar(event: event,
                  barLeft: barLeft,
                  barWidth: barWidth,
                  barY: barY,
                  barHeight: barHeight)
        layoutInfo(event: event,
                   barLeft: barLeft,
                   barRight: barRight,
                   barWidth: barWidth,
                   barY: barY,
                   barHeight: barHeight)
    }

    /// 设置甘特条及进度视图
    private func layoutBar(event: GanttEvent,
                           barLeft: CGFloat,
                           barWidth: CGFloat,
                           barY: CGFloat,
                           barHeight: CGFloat) {
        let cornerRadius = min(barHeight / 2.0, barWidth / 2.0)

        barView.frame = CGRect(x: barLeft, y: barY, width: barWidth, height: barHeight)
        barView.backgroundColor = event.color.withBrightness(0.4)
        barView.layer.borderColor = event.color.withAlphaComponent(0.4).cgColor
        barView.layer.cornerRadius = cornerRadius

        let progress = min(max(event.progress, 0.0), 1.0)
        progressView.frame = CGRect(x: 0.0,
                                    y: 0.0,
                                    width: barWidth * progress,
                                    height: barHeight)
        progressView.backgroundColor = event.color
        progressView.layer.cornerRadius = cornerRadius
    }

    /// 根据甘特条宽度定位信息视图：条足够宽时显示在条内，否则显示在条的两侧
    private func layoutInfo(event: GanttEvent,
                            barLeft: CGFloat,
                            barRight: CGFloat,
                            barWidth: CGFloat,
                            barY: CGFloat,
                            barHeight: CGFloat) {
        infoView.update(with: event)
        infoView.titleAlignment = .left
        infoView.titleLineBreakMode = .byTruncatingMiddle
        infoView.isHidden = false
        infoView.isUserInteractionEnabled = true

        /// 条足够宽时信息视图显示在条内并居中
        if barWidth >= infoInBarMinBarWidth {
            let infoWidth = infoView.contentWidth(limitedTo: min(barWidth * 0.6, infoMaxWidth))
            let infoX = barLeft + (barWidth - infoWidth) / 2.0

            infoView.frame = CGRect(x: infoX, y: barY, width: infoWidth, height: barHeight)
            infoView.titleColor = insideTitleColor
            return
        }

        /// 否则显示在条外侧：优先右侧，空间不足时放左侧，仍不足则贴在行内
        let infoWidth = infoView.contentWidth(limitedTo: min(bounds.width * 0.6, infoMaxWidth))
        var infoX = barRight
        if infoX + infoWidth > bounds.width {
            infoX = barLeft - infoWidth
        }

        if infoX < 0.0 {
            infoX = max(min(barRight, bounds.width - infoWidth), 0.0)
        }

        let onBar = infoX + infoWidth > barLeft && infoX < barRight
        infoView.frame = CGRect(x: infoX, y: barY, width: infoWidth, height: barHeight)
        infoView.titleColor = onBar ? insideTitleColor : outsideTitleColor
    }

    /// 无事项或事项越界时重置子视图
    private func resetBarViews() {
        barView.frame = .zero
        progressView.frame = .zero
        infoView.frame = .zero
        infoView.resetContent()
        infoView.isUserInteractionEnabled = false
    }

    // MARK: - 交互

    @objc private func barTapped() {
        guard let event = event else { return }

        TPImpactFeedback.impactWithSoftStyle()
        onEventTap?(event)
    }
}
