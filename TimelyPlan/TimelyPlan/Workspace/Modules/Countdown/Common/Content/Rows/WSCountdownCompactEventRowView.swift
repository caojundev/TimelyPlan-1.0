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
    
    /// 文案区的布局参数。均按行高换算，保证不同尺寸下比例一致
    private enum Metrics {
        /// 图标与文案的间距
        static let iconTitleSpacing: CGFloat = 8.0
        
        /// 标题字号占行高的比例及范围
        static let titleFontRatio: CGFloat = 0.2
        static let titleMinFontSize: CGFloat = 11.0
        static let titleMaxFontSize: CGFloat = 16.0
        
        /// 标题与数值的间距占行高的比例
        static let titleValueSpacingRatio: CGFloat = 0.06
        
        /// 骨架文本块宽度占文案区宽度的比例
        static let skeletonTitleWidthRatio: CGFloat = 0.55
        static let skeletonValueWidthRatio: CGFloat = 0.4
    }
    
    /// 名称标签
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = UIEdgeInsets(horizontal: 12.0, vertical: 6.0)
        
        titleLabel.font = .systemFont(ofSize: Metrics.titleMinFontSize, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)
        
        titleLabel.isSkeletonable = true
        titleLabel.skeletonShape = .capsule
        titleLabel.skeletonWidthRatio = Metrics.skeletonTitleWidthRatio
        
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
        
        layoutIconAtLeadingCenter(in: layoutFrame)
        
        /// 文案：名称在上、剩余时间在下，整组垂直居中
        let infoLeft = iconView.right + Metrics.iconTitleSpacing
        let infoWidth = max(0.0, layoutFrame.maxX - infoLeft)
        
        let titleHeight = ceil(titleLabel.font.lineHeight)
        let valueHeight = valueLineHeight
        let spacing = max(1.0, floor(layoutFrame.height * Metrics.titleValueSpacingRatio))
        let contentHeight = titleHeight + spacing + valueHeight
        
        let top = max(layoutFrame.minY + (layoutFrame.height - contentHeight) / 2.0, layoutFrame.minY)
        
        titleLabel.frame = CGRect(x: infoLeft, y: top, width: infoWidth, height: titleHeight)
        valueView.frame = CGRect(x: infoLeft,
                                 y: titleLabel.bottom + spacing,
                                 width: infoWidth,
                                 height: valueHeight)
    }
    
    override func updateFonts(in layoutFrame: CGRect) {
        super.updateFonts(in: layoutFrame)
        
        let titleFontSize = min(max(floor(layoutFrame.height * Metrics.titleFontRatio), Metrics.titleMinFontSize),
                                Metrics.titleMaxFontSize)
        titleLabel.font = .systemFont(ofSize: titleFontSize, weight: .semibold)
    }
    
    // MARK: - 渲染
    override func reloadInfo(with dataItem: WSCountdownDataItem) {
        titleLabel.text = dataItem.title
    }
    
    override func clearInfo() {
        titleLabel.text = nil
    }
}
