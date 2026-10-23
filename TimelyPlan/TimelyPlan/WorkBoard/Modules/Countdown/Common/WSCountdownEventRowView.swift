//
//  WSCountdownEventRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 行视图

/// 倒数日事项行视图。
///
/// 展示单个倒数日事项：左侧图标，中间名称与日期，右侧剩余时间，
/// 与倒数日列表单元格的排布一致。尺寸完全由外部决定，
/// 由 `WSCountdownRecentContentView` 在各尺寸的组件中复用。
class WSCountdownEventRowView: WSCountdownEventRowBaseView {
    
    /// 信息区与数值的布局参数。均按行高换算，保证不同尺寸下比例一致
    private enum Metrics {
        /// 图标与信息的间距
        static let iconInfoSpacing: CGFloat = 8.0
        
        /// 信息与剩余时间的间距
        static let infoValueSpacing: CGFloat = 8.0
        
        /// 标题字号占行高的比例及范围
        static let titleFontRatio: CGFloat = 0.3
        static let titleMinFontSize: CGFloat = 11.0
        static let titleMaxFontSize: CGFloat = 16.0
        
        /// 副标题字号占行高的比例及范围
        static let subtitleFontRatio: CGFloat = 0.24
        static let subtitleMinFontSize: CGFloat = 10.0
        static let subtitleMaxFontSize: CGFloat = 12.0
        
        /// 副标题与标题的间距占行高的比例
        static let subtitleSpacingRatio: CGFloat = 0.08
        
        /// 剩余时间最大宽度占行宽的比例
        static let valueWidthRatio: CGFloat = 0.45
        
        /// 骨架数值块宽度占行宽的比例及最大宽度
        static let skeletonValueWidthRatio: CGFloat = 0.22
        static let skeletonValueMaximumWidth: CGFloat = 52.0
    }
    
    /// 信息视图
    private let infoView = TPInfoView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 12.0, vertical: 4.0)
        
        /// 与倒数日列表单元格一致：图标偏大、数值靠右
        iconHeightRatio = 0.78
        iconMinSide = 20.0
        iconMaxSide = 36.0
        iconFontRatio = 0.5
        valueFontRatio = 0.46
        valueMinFontSize = 12.0
        valueMaxFontSize = 24.0
        unitFontRatio = 0.5
        todayFontRatio = 0.7
        valueView.textAlignment = .right
        
        infoView.titleConfig.textColor = .label
        infoView.subtitleConfig.textColor = .secondaryLabel
        infoView.subtitleConfig.alpha = 1.0
        addSubview(infoView)
        
        infoView.titleLabel.isSkeletonable = true
        infoView.titleLabel.skeletonShape = .capsule
        infoView.titleLabel.skeletonWidthRatio = 0.55
        
        infoView.subtitleLabel.isSkeletonable = true
        infoView.subtitleLabel.skeletonShape = .capsule
        infoView.subtitleLabel.skeletonWidthRatio = 0.38
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutContent(in layoutFrame: CGRect) {
        layoutIconAtLeadingCenter(in: layoutFrame)
        
        /// 剩余时间：靠右，宽度按内容自适应并限制最大宽度，超出时由数值视图自行缩放
        let valueFitSize = valueView.sizeThatFits(CGSize(width: .greatestFiniteMagnitude,
                                                         height: layoutFrame.height))
        /// 骨架态没有数值内容，给一个固定宽度用于占位
        let valueWidth = dataItem == nil
            ? min(layoutFrame.width * Metrics.skeletonValueWidthRatio, Metrics.skeletonValueMaximumWidth)
            : min(ceil(valueFitSize.width), layoutFrame.width * Metrics.valueWidthRatio)
        valueView.size = CGSize(width: valueWidth, height: layoutFrame.height)
        valueView.right = layoutFrame.maxX
        valueView.top = layoutFrame.minY
        
        /// 信息：占据中间的剩余空间
        let infoLeft = iconView.right + Metrics.iconInfoSpacing
        let infoRight = valueView.left - Metrics.infoValueSpacing
        infoView.frame = CGRect(x: infoLeft,
                                y: layoutFrame.minY,
                                width: max(0.0, infoRight - infoLeft),
                                height: layoutFrame.height)
        
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
        infoView.subtitleTopMargin = max(2.0, floor(layoutFrame.height * Metrics.subtitleSpacingRatio))
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
