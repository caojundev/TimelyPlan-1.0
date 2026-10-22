//
//  WSCountdownCompactEventRowView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/22.
//

import Foundation
import UIKit

// MARK: - 简略行视图

/// 倒数日事项简略行视图。
///
/// 是 `WSCountdownEventRowView` 的简略版：左侧图标，右侧「名称 + 剩余时间」两行文案，
/// 不再展示日期副标题。尺寸由外部决定，供小尺寸等空间有限的组件复用。
/// 背景色与圆角由 `normalBackColor`、`contentCornerRadius` 配置。
class WSCountdownCompactEventRowView: WSCountdownEventRowBaseView {
    
    /// 布局参数。均按行高换算，保证不同尺寸下比例一致
    private enum Metrics {
        static let padding = UIEdgeInsets(horizontal: 12.0, vertical: 6.0)
        
        /// 图标与文案的间距
        static let iconTitleSpacing: CGFloat = 8.0
        
        /// 图标边长占行高的比例及范围
        static let iconHeightRatio: CGFloat = 0.5
        static let iconMinSide: CGFloat = 22.0
        static let iconMaxSide: CGFloat = 40.0
        
        /// emoji 字号占图标边长的比例
        static let iconFontRatio: CGFloat = 0.52
        
        /// 标题字号占行高的比例及范围
        static let titleFontRatio: CGFloat = 0.2
        static let titleMinFontSize: CGFloat = 11.0
        static let titleMaxFontSize: CGFloat = 16.0
        
        /// 标题与数值的间距占行高的比例
        static let titleValueSpacingRatio: CGFloat = 0.06
        
        /// 数值字号占行高的比例及范围
        static let valueFontRatio: CGFloat = 0.3
        static let valueMinFontSize: CGFloat = 13.0
        static let valueMaxFontSize: CGFloat = 26.0
        
        /// 单位字号占数值字号的比例
        static let unitFontRatio: CGFloat = 0.45
        
        /// 「今天」字号占数值字号的比例
        static let todayFontRatio: CGFloat = 0.65
        
        /// 骨架文本块宽度占文案区宽度的比例
        static let skeletonTitleWidthRatio: CGFloat = 0.55
        static let skeletonValueWidthRatio: CGFloat = 0.4
    }
    
    /// 图标视图
    private let iconView = TPIconView()
    
    /// 名称标签
    private let titleLabel = UILabel()
    
    /// 剩余时间视图
    private let valueView = CountdownTimeValueView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        
        addSubview(iconView)
        
        titleLabel.font = .systemFont(ofSize: Metrics.titleMinFontSize, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)
        
        /// 组件为浅色背景，剩余时间使用常规文本色，单位弱化，不绘制光晕
        valueView.textAlignment = .left
        valueView.textColor = .label
        valueView.unitColor = .secondaryLabel
        valueView.glowColor = .clear
        addSubview(valueView)
        
        /// 骨架标记：直接标记真实子视图，由 Skeleton 统一绘制
        iconView.isSkeletonable = true
        iconView.skeletonShape = .circle
        
        titleLabel.isSkeletonable = true
        titleLabel.skeletonShape = .capsule
        titleLabel.skeletonWidthRatio = Metrics.skeletonTitleWidthRatio
        
        valueView.isSkeletonable = true
        valueView.skeletonShape = .capsule
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
        
        if isLayoutSizeChanged {
            updateFonts(for: layoutFrame)
        }
        
        /// 图标：靠左、垂直居中
        let iconSide = iconViewSide(for: layoutFrame)
        iconView.size = CGSize(width: iconSide, height: iconSide)
        iconView.left = layoutFrame.minX
        iconView.centerY = layoutFrame.midY
        iconView.cornerRadius = iconSide / 2.0
        
        /// 文案：名称在上、剩余时间在下，整组垂直居中
        let infoLeft = iconView.right + Metrics.iconTitleSpacing
        let infoWidth = max(0.0, layoutFrame.maxX - infoLeft)
        
        let titleHeight = ceil(titleLabel.font.lineHeight)
        let valueHeight = ceil(valueView.valueFont.lineHeight)
        let spacing = max(1.0, floor(layoutFrame.height * Metrics.titleValueSpacingRatio))
        let contentHeight = titleHeight + spacing + valueHeight
        
        var top = layoutFrame.minY + (layoutFrame.height - contentHeight) / 2.0
        top = max(top, layoutFrame.minY)
        
        titleLabel.frame = CGRect(x: infoLeft, y: top, width: infoWidth, height: titleHeight)
        valueView.frame = CGRect(x: infoLeft,
                                 y: titleLabel.bottom + spacing,
                                 width: infoWidth,
                                 height: valueHeight)
    }
    
    /// 图标边长
    private func iconViewSide(for layoutFrame: CGRect) -> CGFloat {
        let side = floor(layoutFrame.height * Metrics.iconHeightRatio)
        return min(max(side, Metrics.iconMinSide), Metrics.iconMaxSide)
    }
    
    /// 按行高换算字号
    private func updateFonts(for layoutFrame: CGRect) {
        iconView.font = .systemFont(ofSize: floor(iconViewSide(for: layoutFrame) * Metrics.iconFontRatio))
        
        let titleFontSize = min(max(floor(layoutFrame.height * Metrics.titleFontRatio), Metrics.titleMinFontSize),
                                Metrics.titleMaxFontSize)
        titleLabel.font = .systemFont(ofSize: titleFontSize, weight: .semibold)
        
        let valueFontSize = min(max(floor(layoutFrame.height * Metrics.valueFontRatio), Metrics.valueMinFontSize),
                                Metrics.valueMaxFontSize)
        valueView.valueFont = .monospacedDigitSystemFont(ofSize: valueFontSize, weight: .heavy)
        valueView.unitFont = .systemFont(ofSize: max(floor(valueFontSize * Metrics.unitFontRatio), 10.0), weight: .medium)
        valueView.todayFont = .systemFont(ofSize: max(floor(valueFontSize * Metrics.todayFontRatio), 11.0), weight: .bold)
    }
    
    // MARK: - 渲染
    override func reloadContent(with dataItem: WSCountdownDataItem) {
        iconView.icon = TPIcon(text: dataItem.emoji)
        iconView.backColor = dataItem.color
        titleLabel.text = dataItem.title
        valueView.result = dataItem.timeResult
    }
    
    override func clearContent() {
        iconView.icon = nil
        iconView.backColor = .clear
        titleLabel.text = nil
        valueView.result = nil
    }
}
