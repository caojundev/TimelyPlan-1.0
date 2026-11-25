//
//  WSCountdownColumnEventRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

// MARK: - 竖排卡片视图

/// 倒数日事项竖排卡片视图。
///
/// 适用于窄列卡片：图标在左上，名称与日期紧随其下，剩余时间靠底对齐。
/// 信息区与 `WSCountdownEventRowView` 一致使用 `TPInfoView`，标题与副标题各占两行。
/// 尺寸由外部决定，供一行多列等空间受限的组件复用；
/// 背景色与圆角由 `normalBackColor`、`contentCornerRadius` 配置。
class WSCountdownColumnEventRowView: WSCountdownEventRowBaseView {
    
    /// 信息区的布局参数。均按卡片高度换算，保证不同尺寸下比例一致
    private enum Metrics {
        /// 图标与信息区的间距
        static let iconInfoSpacing: CGFloat = 4.0
        
        /// 信息区与剩余时间的间距
        static let infoValueSpacing: CGFloat = 4.0
        
        /// 标题字号占卡片高度的比例及范围
        static let titleFontRatio: CGFloat = 0.09
        static let titleMinFontSize: CGFloat = 11.0
        static let titleMaxFontSize: CGFloat = 16.0
        
        /// 副标题字号占卡片高度的比例及范围
        static let subtitleFontRatio: CGFloat = 0.075
        static let subtitleMinFontSize: CGFloat = 10.0
        static let subtitleMaxFontSize: CGFloat = 13.0
        
        /// 副标题与标题的间距占卡片高度的比例
        static let subtitleSpacingRatio: CGFloat = 0.02
        
        /// 标题与副标题默认行数
        static let titleNumberOfLines = 2
        static let subtitleNumberOfLines = 2
        
        /// 骨架文本块宽度占卡片宽度的比例
        static let skeletonTitleWidthRatio: CGFloat = 0.95
        static let skeletonSubtitleWidthRatio: CGFloat = 0.8
        static let skeletonValueWidthRatio: CGFloat = 0.7
    }
    
    /// 信息视图
    private let infoView = TPInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 10.0, vertical: 8.0)
        
        /// 窄列卡片：图标更小、数值更大，信息区允许两行
        iconHeightRatio = 0.24
        iconMinSide = 24.0
        valueFontRatio = 0.18
        valueMinFontSize = 14.0
        valueMaxFontSize = 30.0
        
        infoView.titleConfig.textColor = .label
        infoView.titleConfig.numberOfLines = Metrics.titleNumberOfLines
        infoView.subtitleConfig.textColor = .secondaryLabel
        infoView.subtitleConfig.numberOfLines = Metrics.subtitleNumberOfLines
        infoView.subtitleConfig.alpha = 1.0
        addSubview(infoView)
        
        infoView.titleLabel.isSkeletonable = true
        infoView.titleLabel.skeletonShape = .capsule
        infoView.titleLabel.skeletonWidthRatio = Metrics.skeletonTitleWidthRatio
        
        infoView.subtitleLabel.isSkeletonable = true
        infoView.subtitleLabel.skeletonShape = .capsule
        infoView.subtitleLabel.skeletonWidthRatio = Metrics.skeletonSubtitleWidthRatio
        
        valueView.skeletonWidthRatio = Metrics.skeletonValueWidthRatio
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutContent(in layoutFrame: CGRect) {
        guard layoutFrame.height > 0.0 else {
            return
        }
        
        layoutIconAtLeadingTop(in: layoutFrame)
        layoutValueAtBottom(in: layoutFrame)
        
        /// 信息区：占据图标与剩余时间之间的空间
        let infoTop = iconView.bottom + Metrics.iconInfoSpacing
        let infoBottom = valueView.top - Metrics.infoValueSpacing
        infoView.frame = CGRect(x: layoutFrame.minX,
                                y: infoTop,
                                width: layoutFrame.width,
                                height: max(0.0, infoBottom - infoTop))
        
        /// 骨架态下保持标题 / 副标题一行高度，Skeleton 才能生成文本占位块
        let isSkeleton = dataItem == nil
        infoView.titleMinimumHeight = isSkeleton ? ceil(infoView.titleConfig.font.lineHeight) : 0.0
        infoView.subtitleMinimumHeight = isSkeleton ? ceil(infoView.subtitleConfig.font.lineHeight) : 0.0
        
        /// 骨架已展示时先完成内部布局，再由基类在本次布局结束后重算骨架
        if isLayoutSizeChanged, sk.isShowing {
            infoView.layoutIfNeeded()
        }
    }
    
    override func updateFonts(in layoutFrame: CGRect) {
        super.updateFonts(in: layoutFrame)
        
        let titleFontSize = min(max(floor(layoutFrame.height * Metrics.titleFontRatio), Metrics.titleMinFontSize),
                                Metrics.titleMaxFontSize)
        infoView.titleConfig.font = .systemFont(ofSize: titleFontSize, weight: .semibold)
        
        let subtitleFontSize = min(max(floor(layoutFrame.height * Metrics.subtitleFontRatio), Metrics.subtitleMinFontSize),
                                   Metrics.subtitleMaxFontSize)
        infoView.subtitleConfig.font = .systemFont(ofSize: subtitleFontSize, weight: .regular)
        infoView.subtitleTopMargin = max(1.0, floor(layoutFrame.height * Metrics.subtitleSpacingRatio))
        infoView.setNeedsLayout()
    }
    
    // MARK: - 渲染
    override func reloadInfo(with dataItem: WSCountdownDataItem) {
        infoView.title = dataItem.title
        infoView.subtitle = dataItem.dateText
    }
    
    override func clearInfo() {
        infoView.title = nil
        infoView.subtitle = nil
    }
}
