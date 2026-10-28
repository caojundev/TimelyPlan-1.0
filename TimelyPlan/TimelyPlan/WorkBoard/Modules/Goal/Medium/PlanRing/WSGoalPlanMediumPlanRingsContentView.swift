//
//  WSGoalPlanMediumPlanRingsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/28.
//

import Foundation
import UIKit

// MARK: - 内容视图

/// 目标·中·自选三环的内容视图。
///
/// 左侧为三环视图，每个环对应一个所选计划的任务进度，中心展示已完成计划数与计划总数；
/// 右侧按选择顺序展示计划的色块、名称与完成百分比，计划不足三个时展示骨架。
class WSGoalPlanMediumPlanRingsContentView: WSPluginContentView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 内容与组件边缘的间距
        static let padding = UIEdgeInsets(value: 12.0)
        
        /// 环视图与右侧列表的间距
        static let contentSpacing: CGFloat = 12.0
        
        /// 环视图的最大宽度占内容宽度的比例
        static let ringWidthRatio: CGFloat = 0.5
        
        /// 环数量，与右侧计划行数一致
        static let ringCount = 3
        
        /// 计划行间距
        static let rowSpacing: CGFloat = 6.0
        
        /// 环线宽、环间距与内容宽度的比例及下限
        static let ringLineWidthRatio: CGFloat = 0.07
        static let ringGapRatio: CGFloat = 0.02
        static let minimumRingLineWidth: CGFloat = 4.0
        static let minimumRingGap: CGFloat = 2.0
        
        /// 中心完成计划数字号
        static let valueFont = UIFont.monospacedDigitSystemFont(ofSize: 26.0, weight: .semibold)
    }
    
    /// 环视图
    private let ringView: GoalSummaryRingView = {
        let view = GoalSummaryRingView()
        view.theme = .standard
        return view
    }()
    
    /// 中心已完成计划数与计划总数
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.font = Metrics.valueFont
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()
    
    /// 右侧计划信息，顺序与所选计划一致
    private let planInfoViews: [WSGoalPlanRingInfoView] = (0..<Metrics.ringCount).map { _ in
        return WSGoalPlanRingInfoView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(ringView)
        addSubview(valueLabel)
        
        for infoView in planInfoViews {
            addSubview(infoView)
        }
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
        
        /// 左侧环视图为正方形，宽度不超过内容的一半
        let side = min(layoutFrame.height, layoutFrame.width * Metrics.ringWidthRatio)
        ringView.frame = CGRect(x: layoutFrame.minX,
                                y: layoutFrame.midY - side / 2.0,
                                width: side,
                                height: side)
        
        /// 中心完成计划数在环心居中
        let valueHeight = ceil(valueLabel.font.lineHeight)
        valueLabel.frame = CGRect(x: ringView.left,
                                  y: ringView.centerY - valueHeight / 2.0,
                                  width: ringView.width,
                                  height: valueHeight)
        
        /// 右侧计划行等分内容高度
        let listLeft = ringView.right + Metrics.contentSpacing
        let listWidth = max(layoutFrame.maxX - listLeft, 0.0)
        let rowHeight = max((layoutFrame.height - Metrics.rowSpacing * CGFloat(Metrics.ringCount - 1)) / CGFloat(Metrics.ringCount), 0.0)
        for (index, infoView) in planInfoViews.enumerated() {
            infoView.frame = CGRect(x: listLeft,
                                    y: layoutFrame.minY + CGFloat(index) * (rowHeight + Metrics.rowSpacing),
                                    width: listWidth,
                                    height: rowHeight)
        }
        
        guard side > 0.0 else {
            return
        }
        
        /// 环几何随可用边长换算
        let lineWidth = max(floor(side * Metrics.ringLineWidthRatio), Metrics.minimumRingLineWidth)
        let gap = max(floor(side * Metrics.ringGapRatio), Metrics.minimumRingGap)
        let outerRadius = max(side / 2.0 - lineWidth / 2.0 - 1.0, 0.0)
        let innerRadius = max(outerRadius - CGFloat(Metrics.ringCount - 1) * (lineWidth + gap), 0.0)
        let metrics = GoalSummaryRingMetrics(side: side,
                                             outerRadius: outerRadius,
                                             outerLineWidth: lineWidth,
                                             innerRadius: innerRadius,
                                             innerLineWidth: lineWidth)
        
        if ringView.metrics.side != side {
            ringView.metrics = metrics
            applyRings()
        }
    }
    
    // MARK: - 渲染
    override func update(with dataItem: WSPluginDataItem?) {
        super.update(with: dataItem)
        
        let items = (dataItem as? WSGoalPlanRowsDataItem)?.items ?? []
        
        for (index, infoView) in planInfoViews.enumerated() {
            /// 空位传 nil，信息行内部会切换为骨架展示
            infoView.update(with: items[safe: index])
        }
        
        /// 分子为已完成计划数，分母为已选计划总数
        let completedCount = items.filter { $0.status == .completed }.count
        valueLabel.text = items.isEmpty ? nil : "\(completedCount)/\(items.count)"
        applyRings()
        
        setNeedsLayout()
    }
    
    /// 应用环视图：按选择顺序由外到内排列，颜色与进度取对应计划
    private func applyRings() {
        let items = (dataItem as? WSGoalPlanRowsDataItem)?.items ?? []
        let metrics = ringView.metrics
        guard metrics.side > 0.0, !items.isEmpty else {
            ringView.rings = []
            return
        }
        
        let gap = max(floor(metrics.side * Metrics.ringGapRatio), Metrics.minimumRingGap)
        var rings: [GoalSummaryRingView.Ring] = []
        for (index, item) in items.prefix(Metrics.ringCount).enumerated() {
            let radius = metrics.outerRadius - CGFloat(index) * (metrics.outerLineWidth + gap)
            guard radius > 0.0 else {
                break
            }
            
            rings.append(GoalSummaryRingView.Ring(radius: radius,
                                                  lineWidth: metrics.outerLineWidth,
                                                  progress: item.progress,
                                                  color: item.color))
        }
        
        ringView.rings = rings
    }
}

// MARK: - 计划信息行

/// 右侧计划信息：色块、名称与完成百分比。
///
/// 使用 `TPColorInfoView` 承载色块与两行文本，无数据时展示骨架。
private class WSGoalPlanRingInfoView: TPColorInfoView {
    
    /// 布局尺寸
    private enum Metrics {
        
        /// 色块尺寸及其与文本的间距
        static let colorBarSize = CGSize(width: 6.0, height: 28.0)
        static let colorBarMargins = UIEdgeInsets(horizontal: 8.0)
        
        /// 名称字号
        static let titleFont = UIFont.systemFont(ofSize: 13.0, weight: .medium)
        
        /// 百分比字号
        static let valueFont = UIFont.monospacedDigitSystemFont(ofSize: 15.0, weight: .bold)
        
        /// 百分号字号
        static let valueUnitFont = UIFont.monospacedDigitSystemFont(ofSize: 10.0, weight: .bold)
        
        /// 名称与百分比的间距
        static let subtitleTopMargin: CGFloat = 4.0
        
        /// 骨架块颜色。组件底色偏亮，骨架块需要更明显的对比
        static let skeletonColor = Color(light: 0x000000, 0.12, dark: 0xFFFFFF, 0.22)
    }
    
    /// 骨架块配置
    private let skeletonConfig: SkeletonConfig = {
        var config = Skeleton.config
        config.baseColor = Metrics.skeletonColor
        return config
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleConfig = .withFont(Metrics.titleFont,
                                textColor: .secondaryLabel,
                                adjustsFontSizeToFitWidth: true,
                                minimumScaleFactor: 0.7)
        subtitleConfig = .withFont(Metrics.valueFont,
                                   textColor: .label,
                                   adjustsFontSizeToFitWidth: true,
                                   minimumScaleFactor: 0.5)
        subtitleTopMargin = Metrics.subtitleTopMargin
        
        let colorConfig = TPColorAccessoryConfig.withColor(nil, size: Metrics.colorBarSize)
        colorConfig.margins = Metrics.colorBarMargins
        self.colorConfig = colorConfig
        
        setupSkeleton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 标记骨架块：名称与百分比；色块不参与骨架
    private func setupSkeleton() {
        colorView.isSkeletonExcluded = true
        
        titleLabel.isSkeletonable = true
        titleLabel.skeletonShape = .capsule
        titleLabel.skeletonWidthRatio = 0.5
        
        subtitleLabel.isSkeletonable = true
        subtitleLabel.skeletonShape = .capsule
        subtitleLabel.skeletonWidthRatio = 0.3
    }
    
    /// 更新展示的目标计划。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSGoalPlanDataItem?) {
        guard let dataItem = dataItem else {
            colorView.backgroundColor = nil
            title = nil
            subtitle = nil
            
            /// 骨架态保留名称 / 百分比一行高度，Skeleton 才能生成文本占位块
            titleMinimumHeight = ceil(titleConfig.font.lineHeight)
            subtitleMinimumHeight = ceil(subtitleConfig.font.lineHeight)
            
            setNeedsLayout()
            layoutIfNeeded()
            sk.show(config: skeletonConfig)
            return
        }
        
        sk.hide()
        titleMinimumHeight = 0.0
        subtitleMinimumHeight = 0.0
        colorView.backgroundColor = dataItem.color
        title = dataItem.title
        subtitle = Float(dataItem.progress).attributedPercentageString(decimalPlaces: 0,
                                                                       percentSignFont: Metrics.valueUnitFont)
        setNeedsLayout()
    }
}
