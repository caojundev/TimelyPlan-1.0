//
//  MindMapIconNodeLayer.swift
//  MindMapKit
//
//  图标节点图层：文本 + 左侧图标（资源图片或 Emoji）。
//  图标数据（`TPIcon`）与颜色从节点的 `content` 读取，统一交给 `TPIconView` 渲染；
//  颜色缺省时跟随分支色。
//

import Foundation
import UIKit
import QuartzCore

open class MindMapIconNodeLayer: MindMapTextNodeLayer {

    public override class var kind: MindMapNodeKind { .icon }

    // MARK: 样式（该类型自己的可调参数）

    /// 图标边长。
    open class var iconSize: CGFloat { 18 }
    /// 图标与文本之间的间距。
    open class var accessorySpacing: CGFloat { 4.0 }

    /// 图标视图：统一渲染「资源图片」与「Emoji 文本」两种 `TPIcon`。
    ///
    /// 图层树是 `CALayer` 体系（不为每个节点建 UIView），这里把 `TPIconView`
    /// 自身的 layer 挂进来，既复用了它的渲染逻辑，又不额外引入视图层级。
    private let iconView = TPIconView()

    // MARK: 初始化

    public required init(palette: MindMapPalette) {
        super.init(palette: palette)
        iconView.font = .boldSystemFont(ofSize: 18.0)
        iconView.cornerRadius = 0.0
        iconView.isUserInteractionEnabled = false
        iconView.backColor = .clear
        addSublayer(iconView.layer)
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 尺寸（自定义：文本 + 图标）

    open override class func size(constrainedTo constraint: CGSize,
                                  text: String,
                                  content: MindMapNodeContent?,
                                  metrics: MindMapMetrics,
                                  isRoot: Bool) -> CGSize {
        let accessory = CGSize(width: iconSize, height: iconSize)
        let insets = metrics.contentInsets(isRoot: isRoot)

        // 限定宽度先扣掉图标占位，文本在剩余空间里换行。
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
        Self.iconSize + Self.accessorySpacing
    }

    open override func updateContent(_ node: MindMapNodeLayout, bounds: CGRect) {
        super.updateContent(node, bounds: bounds)

        guard let content = node.content as? MindMapIconContent else {
            iconView.isHidden = true
            return
        }
        iconView.isHidden = false

        // 取整到整点，配合 contentsScale 让图标落到整像素上，避免虚边。
        let side = min(Self.iconSize, bounds.height).rounded()
        let insets = metrics.contentInsets(isRoot: node.isRoot)
        iconView.frame = CGRect(x: insets.left,
                                y: (bounds.height - side) / 2,
                                width: side,
                                height: side)

        // 数据即 `TPIcon`：图片走资源图、Emoji 走文本，颜色缺省跟随分支色。
        iconView.font = .systemFont(ofSize: side)
        iconView.foreColor = content.tint ?? node.color
        iconView.icon = content.icon
        // 图标视图不在 window 中，布局不会自动触发，这里显式唤醒一次。
        iconView.layoutIfNeeded()
    }
}
