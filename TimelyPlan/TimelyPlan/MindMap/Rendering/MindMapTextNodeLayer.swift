//
//  MindMapTextNodeLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/8.
//
//  文本节点图层：内容就是一行（或多行）文本。
//
//  也是所有「文本 + 左侧附件」类型（待办、图标…）的父类：它们只需要重写
//  `leadingTextInset(...)` 给附件让出左侧空间，以及 `updateContent(...)` 画自己的附件。
//

import UIKit
import QuartzCore

open class MindMapTextNodeLayer: MindMapNodeLayer {

    private let textLayer = CATextLayer()

    // MARK: 初始化

    public required init(palette: MindMapPalette) {
        super.init(palette: palette)
        textLayer.isWrapped = true
        textLayer.truncationMode = .end
        textLayer.alignmentMode = .left
        addSublayer(textLayer)
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 内容

    /// 文本左侧需要为类型附件空出的宽度。子类（勾选框 / 图标）重写。
    open func leadingTextInset(metrics: MindMapMetrics,
                               content: MindMapNodeContent?,
                               isRoot: Bool) -> CGFloat { 0 }

    open override func updateContent(_ node: MindMapNodeLayout, bounds: CGRect) {
        let insets = metrics.contentInsets(isRoot: node.isRoot)
        let font = metrics.textFont(isRoot: node.isRoot)
        let leading = insets.left
            + leadingTextInset(metrics: metrics, content: node.content, isRoot: node.isRoot)

        // 换行宽度直接由内容块宽度倒推：尺寸计算与绘制因此永远一致，
        // 不会出现「量的时候按 A 换行、画的时候按 B 换行」。
        let wrapWidth = max(0, bounds.width - leading - insets.right)
        let textSize = MindMapNodeLayer.measureText(node.text, font: font, maxWidth: wrapWidth)

        let defaultColor = node.isRoot ? palette.rootText : palette.text
        textLayer.string = node.text
        textLayer.font = font
        textLayer.fontSize = font.pointSize
        textLayer.foregroundColor = contentColor(node, default: defaultColor).cgColor
        // 垂直居中：附件比文本高时（勾选框 + 单行小字）文本不会被顶到上方。
        textLayer.frame = CGRect(x: leading,
                                 y: max(0, (bounds.height - textSize.height) / 2),
                                 width: wrapWidth,
                                 height: textSize.height)
    }

    /// 文本颜色。默认按根 / 非根取色；子类可覆盖以表达状态（如完成态淡化）。
    open func contentColor(_ node: MindMapNodeLayout, default color: UIColor) -> UIColor {
        color
    }
}
