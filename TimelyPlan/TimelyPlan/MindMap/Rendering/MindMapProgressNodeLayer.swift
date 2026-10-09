//
//  MindMapProgressNodeLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/9.
//

import Foundation
import UIKit
import QuartzCore

/// 进度节点图层：文本 + 左侧圆形进度环。
///
/// 与 `MindMapIconNodeLayer` 结构一致，只是把左侧附件从 `TPIconView` 换成
/// `TPCircleOutlineProgressView`：进度值（0～1）与颜色从节点的 `content` 读取，
/// 颜色缺省时跟随分支色。
open class MindMapProgressNodeLayer: MindMapTextNodeLayer {

    public override class var kind: MindMapNodeKind { .progress }

    // MARK: 样式（该类型自己的可调参数）

    /// 进度环边长。
    open class var progressSize: CGFloat { 18 }
    /// 进度环与文本之间的间距。
    open class var accessorySpacing: CGFloat { 4.0 }
    /// 进度环线条宽度。
    open class var progressLineWidth: CGFloat { 2.0 }
    /// 底环（轨道）相对进度色的不透明度。
    open class var trackOpacity: CGFloat { 0.25 }

    /// 进度环视图：复用 `TPCircleOutlineProgressView` 的绘制。
    ///
    /// 图层树是 `CALayer` 体系（不为每个节点建 UIView），这里把进度视图自身的 layer
    /// 挂进来，既复用了它的绘制逻辑，又不额外引入视图层级。
    private let progressView = TPCircleOutlineProgressView()

    // MARK: 初始化

    public required init(palette: MindMapPalette) {
        super.init(palette: palette)
        progressView.isUserInteractionEnabled = false
        progressView.progressLineWidth = Self.progressLineWidth
        progressView.backLineWidth = Self.progressLineWidth
        addSublayer(progressView.layer)
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 尺寸（自定义：文本 + 进度环）

    open override class func size(constrainedTo constraint: CGSize,
                                  text: String,
                                  content: MindMapNodeContent?,
                                  metrics: MindMapMetrics,
                                  isRoot: Bool) -> CGSize {
        let accessory = CGSize(width: progressSize, height: progressSize)
        let insets = metrics.contentInsets(isRoot: isRoot)

        // 限定宽度先扣掉进度环占位，文本在剩余空间里换行。
        var textConstraint = constraint
        if textConstraint.width > 0 {
            textConstraint.width -= accessory.width + accessorySpacing
        }
        let textPart = super.size(constrainedTo: textConstraint, text: text,
                                  content: content, metrics: metrics, isRoot: isRoot)

        return CGSize(
            width: textPart.width + accessory.width + accessorySpacing,
            height: max(textPart.height, accessory.height + insets.top + insets.bottom))
    }

    // MARK: 内容

    open override func leadingTextInset(metrics: MindMapMetrics,
                                        content: MindMapNodeContent?,
                                        isRoot: Bool) -> CGFloat {
        Self.progressSize + Self.accessorySpacing
    }

    open override func updateContent(_ node: MindMapNodeLayout, bounds: CGRect) {
        super.updateContent(node, bounds: bounds)

        guard let content = node.content as? MindMapProgressContent else {
            progressView.isHidden = true
            return
        }
        progressView.isHidden = false

        // 取整到整点，配合 contentsScale 让圆环落到整像素上，避免虚边。
        let side = min(Self.progressSize, bounds.height).rounded()
        let insets = metrics.contentInsets(isRoot: node.isRoot)
        progressView.frame = CGRect(x: insets.left,
                                    y: (bounds.height - side) / 2,
                                    width: side,
                                    height: side)

        // 进度环颜色即可配置项：优先取载荷里的 tint，否则跟随分支色；
        // 底环用同色的低透明度版本作为轨道。
        let lineColor = content.tint ?? node.color
        progressView.progressLineWidth = Self.progressLineWidth
        progressView.backLineWidth = Self.progressLineWidth
        progressView.progressLineColor = lineColor
        progressView.backLineColor = lineColor.withAlphaComponent(Self.trackOpacity)
        progressView.progress = content.progress

        // 进度视图不在 window 中，布局不会自动触发，这里显式唤醒一次
        // （圆环路径与颜色都在 layoutSubviews 里落地）。
        progressView.layoutIfNeeded()
    }
}
