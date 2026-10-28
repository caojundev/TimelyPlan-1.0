//
//  WSGoalPlanSmallPlanRingContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 目标·小·自选双环的内容视图。
///
/// 顶部为计划名称，中间为双环：内环展示任务进度、中心显示完成百分比与计划状态，
/// 外环展示时间进度，底部居中显示日期区间与时间进度百分比。
class WSGoalPlanSmallPlanRingContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 标题字号
        static let titleFont = UIFont.boldSystemFont(ofSize: 14.0)
        
        /// 时间信息字号
        static let timeFont = UIFont.systemFont(ofSize: 12.0, weight: .medium)
        
        /// 标题、双环、时间信息之间的间距
        static let contentSpacing: CGFloat = 6.0
        
        /// 内环中心的计划状态字号
        static let statusFont = UIFont.systemFont(ofSize: 10.0, weight: .medium)
        
        /// 百分比与计划状态的间距
        static let statusTopMargin: CGFloat = 1.0
        
        /// 百分号字号相对标题字号的比例
        static let titlePercentRatio: CGFloat = 0.6
    }
    
    /// 标题
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.titleFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    /// 双环视图
    private let ringView: GoalSummaryRingView = {
        let view = GoalSummaryRingView()
        view.theme = .standard
        return view
    }()
    
    /// 内环中心：任务完成百分比与计划状态
    private lazy var infoView: TPInfoView = {
        let view = TPInfoView()
        view.titleConfig = .withFont(UIFont.monospacedDigitSystemFont(ofSize: 14.0, weight: .semibold),
                                     textColor: .label,
                                     textAlignment: .center,
                                     adjustsFontSizeToFitWidth: true,
                                     minimumScaleFactor: 0.6)
        view.subtitleConfig = .withFont(Metrics.statusFont,
                                        textColor: .secondaryLabel,
                                        textAlignment: .center,
                                        adjustsFontSizeToFitWidth: true,
                                        minimumScaleFactor: 0.6)
        view.subtitleTopMargin = Metrics.statusTopMargin
        return view
    }()
    
    /// 外环底部的时间信息
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.timeFont
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()
    
    /// 已应用到环视图的尺寸、进度与颜色，避免重复重建图层
    private var appliedRingSide: CGFloat = 0.0
    private var appliedTaskProgress: CGFloat = -1.0
    private var appliedTimeProgress: CGFloat = -1.0
    private var appliedTaskColor: UIColor?
    
    /// 已应用到中心标题的字号，避免重复重建富文本
    private var appliedTitleFontSize: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(titleLabel)
        addSubview(ringView)
        addSubview(infoView)
        addSubview(timeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        guard layoutFrame.width > 0.0, layoutFrame.height > 0.0 else {
            return
        }
        
        /// 标题贴顶
        let titleHeight = ceil(titleLabel.font.lineHeight)
        titleLabel.frame = CGRect(x: layoutFrame.minX,
                                  y: layoutFrame.minY,
                                  width: layoutFrame.width,
                                  height: titleHeight)
        
        /// 时间信息贴底
        let timeHeight = ceil(timeLabel.font.lineHeight)
        timeLabel.frame = CGRect(x: layoutFrame.minX,
                                 y: layoutFrame.maxY - timeHeight,
                                 width: layoutFrame.width,
                                 height: timeHeight)
        
        /// 双环占据中间区域，保持正方形并居中
        let contentTop = titleLabel.bottom + Metrics.contentSpacing
        let availableHeight = max(timeLabel.top - Metrics.contentSpacing - contentTop, 0.0)
        let side = min(layoutFrame.width, availableHeight)
        
        ringView.frame = CGRect(x: layoutFrame.midX - side / 2.0,
                                y: contentTop + (availableHeight - side) / 2.0,
                                width: side,
                                height: side)
        
        guard side > 0.0 else {
            return
        }
        
        /// 环尺寸与中心文案字号随可用空间换算
        let metrics = ringMetrics(for: side)
        
        let innerSide = max((metrics.innerRadius - metrics.innerLineWidth / 2.0) * 2.0, 0.0)
        let titleFontSize = min(max(floor(innerSide * 0.32), 12.0), 24.0)
        if appliedTitleFontSize != titleFontSize {
            appliedTitleFontSize = titleFontSize
            infoView.titleConfig.font = UIFont.monospacedDigitSystemFont(ofSize: titleFontSize, weight: .semibold)
            applyTitle()
        }
        
        /// 中心信息按内容高度居中，宽度与内环内径一致
        let infoHeight = infoView.sizeThatFits(CGSize(width: innerSide, height: .greatestFiniteMagnitude)).height
        infoView.frame = CGRect(x: ringView.centerX - innerSide / 2.0,
                                y: ringView.centerY - infoHeight / 2.0,
                                width: innerSide,
                                height: infoHeight)
        
        /// 环的路径与进度在布局中设置，关闭隐式动画，避免每次布局都被补间
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        if ringView.metrics.side != side {
            ringView.metrics = metrics
        }
        
        applyRingsIfNeeded()
        
        /// 立即完成环的布局并移除出场动画，保证进度直接呈现
        ringView.layoutIfNeeded()
        ringView.layer.sublayers?.forEach { $0.removeAllAnimations() }
        
        CATransaction.commit()
    }
    
    /// 依据可用边长换算双环几何
    private func ringMetrics(for side: CGFloat) -> GoalSummaryRingMetrics {
        let lineWidth = max(floor(side * 0.085), 4.0)
        let gap = max(floor(side * 0.035), 2.0)
        let outerRadius = max(side / 2.0 - lineWidth / 2.0 - 1.0, 0.0)
        let innerRadius = max(outerRadius - lineWidth - gap, 0.0)
        
        return GoalSummaryRingMetrics(side: side,
                                      outerRadius: outerRadius,
                                      outerLineWidth: lineWidth,
                                      innerRadius: innerRadius,
                                      innerLineWidth: lineWidth)
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        guard let dataItem = dataItem as? WSGoalPlanDataItem else {
            titleLabel.text = nil
            infoView.title = nil
            infoView.subtitle = nil
            timeLabel.text = nil
            ringView.rings = []
            appliedRingSide = 0.0
            appliedTaskProgress = -1.0
            appliedTimeProgress = -1.0
            appliedTaskColor = nil
            setNeedsLayout()
            return
        }
        
        titleLabel.text = dataItem.title
        infoView.subtitle = dataItem.statusText
        timeLabel.text = timeText(for: dataItem)
        applyTitle()
        setNeedsLayout()
    }
    
    /// 中心标题：百分比数字沿用标题字号，百分号使用小号字体
    private func applyTitle() {
        guard let dataItem = dataItem as? WSGoalPlanDataItem else {
            infoView.title = nil
            return
        }
        
        let percentFont = UIFont.monospacedDigitSystemFont(ofSize: max(floor(infoView.titleConfig.font.pointSize * Metrics.titlePercentRatio), 8.0),
                                                           weight: .medium)
        infoView.title = Float(dataItem.progress).attributedPercentageString(decimalPlaces: 0,
                                                                             percentSignFont: percentFont)
    }
    
    /// 应用双环：外环时间进度，内环任务进度
    private func applyRingsIfNeeded() {
        guard let dataItem = dataItem as? WSGoalPlanDataItem else {
            ringView.rings = []
            appliedRingSide = 0.0
            appliedTaskProgress = -1.0
            appliedTimeProgress = -1.0
            appliedTaskColor = nil
            return
        }
        
        let taskProgress = dataItem.progress
        let timeProgress = self.timeProgress(for: dataItem)
        let side = ringView.metrics.side
        guard side != appliedRingSide
                || taskProgress != appliedTaskProgress
                || timeProgress != appliedTimeProgress
                || dataItem.color != appliedTaskColor else {
            return
        }
        
        appliedRingSide = side
        appliedTaskProgress = taskProgress
        appliedTimeProgress = timeProgress
        appliedTaskColor = dataItem.color
        
        let metrics = ringView.metrics
        ringView.rings = [
            GoalSummaryRingView.Ring(radius: metrics.outerRadius,
                                     lineWidth: metrics.outerLineWidth,
                                     progress: timeProgress,
                                     color: GoalSummaryTheme.standard.timeAccent),
            GoalSummaryRingView.Ring(radius: metrics.innerRadius,
                                     lineWidth: metrics.innerLineWidth,
                                     progress: taskProgress,
                                     color: dataItem.color)
        ]
    }
    
    /// 时间进度：已流逝时间占计划时长的比例
    private func timeProgress(for dataItem: WSGoalPlanDataItem) -> CGFloat {
        guard let startDate = dataItem.dateRange.startDate,
              let endDate = dataItem.dateRange.endDate else {
            return 0.0
        }
        
        let span = endDate.timeIntervalSince(startDate)
        let elapsed = Date().timeIntervalSince(startDate)
        if span > 0 {
            return CGFloat(min(max(elapsed / span, 0.0), 1.0))
        }
        
        return elapsed >= 0 ? 1.0 : 0.0
    }
    
    /// 时间信息：日期区间与时间进度百分比，与进度总结卡片的时间进度副标题一致
    private func timeText(for dataItem: WSGoalPlanDataItem) -> String? {
        guard let startDate = dataItem.dateRange.startDate,
              let endDate = dataItem.dateRange.endDate else {
            return nil
        }
        
        let timePercent = Float(timeProgress(for: dataItem)).percentageString(decimalPlaces: 0)
        return "\(startDate.monthDayString) - \(endDate.monthDayString) • \(timePercent)"
    }
}
