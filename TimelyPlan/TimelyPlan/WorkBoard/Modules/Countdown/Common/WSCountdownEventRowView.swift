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
class WSCountdownEventRowView: UIView {
    
    /// 布局参数。均按行高换算，保证不同尺寸下比例一致
    private enum Metrics {
        static let padding = UIEdgeInsets(horizontal: 12.0, vertical: 4.0)
        
        /// 图标与信息的间距
        static let iconInfoSpacing: CGFloat = 8.0
        
        /// 信息与剩余时间的间距
        static let infoValueSpacing: CGFloat = 8.0
        
        /// 图标边长占行高的比例
        static let iconHeightRatio: CGFloat = 0.78
        
        /// 图标边长范围
        static let iconMinSide: CGFloat = 20.0
        static let iconMaxSide: CGFloat = 36.0
        
        /// emoji 字号占图标边长的比例
        static let iconFontRatio: CGFloat = 0.5
        
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
        
        /// 数值字号占行高的比例及范围
        static let valueFontRatio: CGFloat = 0.46
        static let valueMinFontSize: CGFloat = 12.0
        static let valueMaxFontSize: CGFloat = 24.0
        
        /// 单位字号占数值字号的比例
        static let unitFontRatio: CGFloat = 0.5
        
        /// 「今天」字号占数值字号的比例
        static let todayFontRatio: CGFloat = 0.7
        
        /// 剩余时间最大宽度占行宽的比例
        static let valueWidthRatio: CGFloat = 0.45
        
        /// 骨架数值块宽度占行宽的比例
        static let skeletonValueWidthRatio: CGFloat = 0.22
        
        /// 骨架数值块最大宽度
        static let skeletonValueMaximumWidth: CGFloat = 52.0
    }
    
    /// 图标视图
    private let iconView = TPIconView()
    
    /// 信息视图
    private let infoView = TPInfoView()
    
    /// 剩余时间视图
    private let valueView = CountdownTimeValueView()
    
    /// 上一次布局的尺寸，仅在尺寸变化时重新换算字号
    private var laidOutSize: CGSize = .zero
    
    /// 点击回调，参数为当前行展示的事项
    var didSelectHandler: ((WSCountdownDataItem) -> Void)?
    
    /// 当前展示的事项
    private var dataItem: WSCountdownDataItem?
    
    /// 点击手势
    private lazy var tapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(clickRow(_:)))
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.padding = Metrics.padding
        
        /// 点击行展示该行的倒数日事项
        addGestureRecognizer(tapGesture)
        
        addSubview(iconView)
        
        infoView.titleConfig.textColor = .label
        infoView.subtitleConfig.textColor = .secondaryLabel
        infoView.subtitleConfig.alpha = 1.0
        addSubview(infoView)
        
        /// 组件为浅色背景，剩余时间使用常规文本色，单位弱化，不绘制光晕
        valueView.textAlignment = .right
        valueView.textColor = .label
        valueView.unitColor = .secondaryLabel
        valueView.glowColor = .clear
        addSubview(valueView)
        
        /// 骨架标记：与 Demo 一致，直接标记真实子视图，由 Skeleton 统一绘制
        iconView.isSkeletonable = true
        iconView.skeletonShape = .circle
        
        infoView.titleLabel.isSkeletonable = true
        infoView.titleLabel.skeletonShape = .capsule
        infoView.titleLabel.skeletonWidthRatio = 0.55
        
        infoView.subtitleLabel.isSkeletonable = true
        infoView.subtitleLabel.skeletonShape = .capsule
        infoView.subtitleLabel.skeletonWidthRatio = 0.38
        
        valueView.isSkeletonable = true
        valueView.skeletonShape = .capsule
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layoutFrame = layoutFrame()
        let isSizeChanged = laidOutSize != layoutFrame.size
        if isSizeChanged {
            laidOutSize = layoutFrame.size
            updateFonts()
        }
        
        /// 图标：靠左、垂直居中
        let iconSide = iconViewSide()
        iconView.size = CGSize(width: iconSide, height: iconSide)
        iconView.left = layoutFrame.minX
        iconView.centerY = layoutFrame.midY
        iconView.cornerRadius = iconSide / 2.0
        
        /// 剩余时间：靠右，宽度按内容自适应并限制最大宽度，超出时由数值视图自行缩放
        let valueFitSize = valueView.sizeThatFits(CGSize(width: .greatestFiniteMagnitude,
                                                         height: layoutFrame.height))
        /// 骨架态没有数值内容，给一个固定宽度用于占位
        let valueWidth = dataItem == nil
            ? min(layoutFrame.width * Metrics.skeletonValueWidthRatio, Metrics.skeletonValueMaximumWidth)
            : min(ceil(valueFitSize.width), layoutFrame.width * Metrics.valueWidthRatio)
        valueView.size = CGSize(width: valueWidth, height: layoutFrame.height)
        valueView.left = layoutFrame.maxX - valueWidth
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
        
        /// 骨架已展示时按最新布局重算，覆盖首次在零尺寸下创建的情况
        if isSizeChanged, sk.isShowing {
            infoView.layoutIfNeeded()
            sk.reload()
        }
    }
    
    /// 图标边长
    private func iconViewSide() -> CGFloat {
        let layoutFrame = layoutFrame()
        let side = floor(layoutFrame.height * Metrics.iconHeightRatio)
        return min(max(side, Metrics.iconMinSide), Metrics.iconMaxSide)
    }
    
    /// 按行高换算字号
    private func updateFonts() {
        let layoutFrame = layoutFrame()
        guard layoutFrame.height > 0.0 else {
            return
        }
        
        iconView.font = .systemFont(ofSize: floor(iconViewSide() * Metrics.iconFontRatio))
        
        let titleFontSize = min(max(floor(layoutFrame.height * Metrics.titleFontRatio), Metrics.titleMinFontSize),
                                Metrics.titleMaxFontSize)
        infoView.titleConfig.font = .systemFont(ofSize: titleFontSize, weight: .semibold)
        
        let subtitleFontSize = min(max(floor(layoutFrame.height * Metrics.subtitleFontRatio), Metrics.subtitleMinFontSize),
                                   Metrics.subtitleMaxFontSize)
        infoView.subtitleConfig.font = .systemFont(ofSize: subtitleFontSize, weight: .regular)
        infoView.subtitleTopMargin = max(2.0, floor(layoutFrame.height * Metrics.subtitleSpacingRatio))
        infoView.setNeedsLayout()
        
        let valueFontSize = min(max(floor(layoutFrame.height * Metrics.valueFontRatio), Metrics.valueMinFontSize),
                                Metrics.valueMaxFontSize)
        valueView.valueFont = .monospacedDigitSystemFont(ofSize: valueFontSize, weight: .heavy)
        valueView.unitFont = .systemFont(ofSize: max(floor(valueFontSize * Metrics.unitFontRatio), 11.0), weight: .medium)
        valueView.todayFont = .systemFont(ofSize: max(floor(valueFontSize * Metrics.todayFontRatio), 11.0), weight: .bold)
    }
    
    // MARK: - 渲染
    /// 更新展示的事项。传 nil 时清空内容并展示骨架
    func update(with dataItem: WSCountdownDataItem?) {
        self.dataItem = dataItem
        
        guard let dataItem = dataItem else {
            iconView.icon = nil
            iconView.backColor = .clear
            infoView.title = nil
            infoView.subtitle = nil
            valueView.result = nil
            
            /// 清空内容后再展示骨架，避免旧内容短暂透出；
            /// 子视图不能隐藏，否则 Skeleton 遍历时会直接跳过
            setNeedsLayout()
            sk.show()
            return
        }
        
        sk.hide()
        
        iconView.icon = TPIcon(text: dataItem.emoji)
        iconView.backColor = dataItem.color
        infoView.title = dataItem.title
        infoView.subtitle = dataItem.dateText
        valueView.result = dataItem.timeResult
        
        setNeedsLayout()
    }
    
    // MARK: - 点击
    /// 点击行，回调当前行展示的事项
    @objc private func clickRow(_ gesture: UITapGestureRecognizer) {
        guard let dataItem = dataItem else {
            return
        }
        
        TPImpactFeedback.impactWithSoftStyle()
        didSelectHandler?(dataItem)
    }
    
    // MARK: - 高亮
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard dataItem != nil else {
            return
        }
        
        setHighlighted(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        setHighlighted(false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setHighlighted(false)
    }
    
    /// 设置高亮背景，提示行可点击
    private func setHighlighted(_ isHighlighted: Bool) {
        UIView.animate(withDuration: 0.15) {
            self.backgroundColor = isHighlighted ? Color(0x888888, 0.1) : .clear
        }
    }
}
