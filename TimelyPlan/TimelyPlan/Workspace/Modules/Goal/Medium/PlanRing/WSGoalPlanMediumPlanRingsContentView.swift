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
/// 左侧为三环视图，每个环对应一个所选计划的任务进度；
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
        static let ringLineWidthRatio: CGFloat = 0.09
        static let ringGapRatio: CGFloat = 0.03
        static let minimumRingLineWidth: CGFloat = 4.0
        static let minimumRingGap: CGFloat = 2.0
    }
    
    /// 环视图
    private let ringView: GoalSummaryRingView = {
        let view = GoalSummaryRingView()
        view.theme = .standard
        return view
    }()
    
    /// 右侧计划信息行，顺序与所选计划一致
    private let planInfoRows: [WSGoalPlanRingInfoRowView] = (0..<Metrics.ringCount).map { _ in
        return WSGoalPlanRingInfoRowView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.padding = Metrics.padding
        
        addSubview(ringView)
        
        for rowView in planInfoRows {
            /// 点击行打开对应计划详情
            rowView.didSelectPlanHandler = { [weak self] dataItem in
                self?.interactor?.performAction(with: dataItem)
            }
            addSubview(rowView)
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
        
        /// 右侧计划行等分内容高度
        let listLeft = ringView.right + Metrics.contentSpacing
        let listWidth = max(layoutFrame.maxX - listLeft, 0.0)
        let rowHeight = max((layoutFrame.height - Metrics.rowSpacing * CGFloat(Metrics.ringCount - 1)) / CGFloat(Metrics.ringCount), 0.0)
        for (index, rowView) in planInfoRows.enumerated() {
            rowView.frame = CGRect(x: listLeft,
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
        
        for (index, rowView) in planInfoRows.enumerated() {
            /// 空位传 nil，信息行内部会切换为骨架展示
            rowView.update(with: items[safe: index])
        }
        
        applyRings()
        
        setNeedsLayout()
    }
    
    /// 应用环视图：按选择顺序由外到内排列，颜色与进度取对应计划
    ///
    /// 固定绘制三个环，计划不足时以进度为 0 的空环占位，保证环的层数、半径与间距一致。
    private func applyRings() {
        let items = (dataItem as? WSGoalPlanRowsDataItem)?.items ?? []
        let metrics = ringView.metrics
        guard metrics.side > 0.0, !items.isEmpty else {
            ringView.rings = []
            return
        }
        
        let gap = max(floor(metrics.side * Metrics.ringGapRatio), Metrics.minimumRingGap)
        var rings: [GoalSummaryRingView.Ring] = []
        for index in 0..<Metrics.ringCount {
            let radius = metrics.outerRadius - CGFloat(index) * (metrics.outerLineWidth + gap)
            guard radius > 0.0 else {
                break
            }
            
            let item = items[safe: index]
            rings.append(GoalSummaryRingView.Ring(radius: radius,
                                                  lineWidth: metrics.outerLineWidth,
                                                  progress: item?.progress ?? 0.0,
                                                  color: item?.color ?? GoalConfig.goalPlanDefaultColor))
        }
        
        ringView.rings = rings
    }
}
