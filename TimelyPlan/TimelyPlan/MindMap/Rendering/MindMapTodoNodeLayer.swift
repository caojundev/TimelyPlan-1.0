//
//  MindMapTodoNodeLayer.swift
//  MindMapKit
//
//  待办节点图层：文本 + 左侧勾选框，勾选状态、样式与颜色从节点的 `content` 读取。
//
//  尺寸计算（重写）与文本摆放（继承）都基于同一个 `leadingTextInset`，
//  因此「左侧让出的空间」在测量和绘制两处必然一致。
//

import UIKit
import QuartzCore

open class MindMapTodoNodeLayer: MindMapTextNodeLayer {

    public override class var kind: MindMapNodeKind { .todo }

    // MARK: 样式（该类型自己的可调参数）

    /// 勾选框边长。
    open class var checkboxSize: CGFloat { 14 }
    /// 勾选框描边线宽。
    open class var checkboxLineWidth: CGFloat { 1.5 }
    /// 勾选框与文本之间的间距。
    open class var accessorySpacing: CGFloat { 6 }
    /// 完成态文本的不透明度（相对分支色），用于淡化已完成项。
    open class var completedTextOpacity: CGFloat { 0.45 }

    /// 勾选框外框与「勾」分属两个图层：CAShapeLayer 会填充所有子路径，
    /// 而「勾」是开放折线，被填充后会变成奇怪的三角形。分开画互不影响。
    private let boxLayer = CAShapeLayer()
    private let checkLayer = CAShapeLayer()

    // MARK: 初始化

    public required init(palette: MindMapPalette) {
        super.init(palette: palette)
        boxLayer.fillColor = UIColor.clear.cgColor
        boxLayer.lineJoin = .round
        checkLayer.fillColor = UIColor.clear.cgColor
        checkLayer.lineCap = .round
        checkLayer.lineJoin = .round
        addSublayer(boxLayer)
        addSublayer(checkLayer)
    }

    public override init(layer: Any) {
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 尺寸（自定义：文本 + 勾选框）

    open override class func size(constrainedTo constraint: CGSize,
                                  text: String,
                                  content: MindMapNodeContent?,
                                  metrics: MindMapMetrics,
                                  isRoot: Bool) -> CGSize {
        let accessory = CGSize(width: checkboxSize, height: checkboxSize)
        let insets = metrics.contentInsets(isRoot: isRoot)

        // 限定宽度先扣掉勾选框占位，文本在剩余空间里换行。
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
        Self.checkboxSize + Self.accessorySpacing
    }

    open override func updateContent(_ node: MindMapNodeLayout, bounds: CGRect) {
        super.updateContent(node, bounds: bounds)

        let content = node.content as? MindMapTodoContent
        let isDone = content?.isDone ?? false
        let style = content?.style ?? .roundedRect
        let side = min(Self.checkboxSize, bounds.height)
        let insets = metrics.contentInsets(isRoot: node.isRoot)
        let origin = CGPoint(x: insets.left, y: (bounds.height - side) / 2)
        // 勾选框颜色：优先取载荷里的 tint（如任务优先级色），否则跟随分支色。
        let color = content?.tint ?? node.color

        draw(isDone: isDone, style: style, side: side, origin: origin, color: color)
    }

    open override func contentColor(_ node: MindMapNodeLayout, default color: UIColor) -> UIColor {
        guard (node.content as? MindMapTodoContent)?.isDone == true else { return color }
        return color.withAlphaComponent(Self.completedTextOpacity)
    }

    // MARK: 勾选框

    private func draw(isDone: Bool,
                      style: MindMapTodoCheckboxStyle,
                      side: CGFloat,
                      origin: CGPoint,
                      color: UIColor) {
        guard side > 0 else {
            boxLayer.path = nil
            checkLayer.path = nil
            return
        }
        let lineWidth = Self.checkboxLineWidth
        // 描边居中于路径，内缩半个线宽才能让外框完整落在 bounds 内。
        let inset = lineWidth / 2
        let rect = CGRect(x: origin.x + inset, y: origin.y + inset,
                          width: side - lineWidth, height: side - lineWidth)

        // 圆角矩形按固定比例收角，圆形取半宽（即内切圆）。
        let cornerRadius: CGFloat
        switch style {
        case .roundedRect: cornerRadius = max(2, side * 0.28)
        case .circle:      cornerRadius = rect.width / 2
        }

        boxLayer.frame = bounds
        boxLayer.lineWidth = lineWidth
        boxLayer.strokeColor = color.cgColor
        boxLayer.fillColor = isDone ? color.cgColor : UIColor.clear.cgColor
        boxLayer.path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).cgPath

        // 勾用背景色，正好从填充的框里「挖」出来。
        checkLayer.frame = bounds
        checkLayer.lineWidth = lineWidth
        checkLayer.strokeColor = palette.background.cgColor
        guard isDone else {
            checkLayer.path = nil
            return
        }
        let mark = UIBezierPath()
        mark.move(to: CGPoint(x: origin.x + side * 0.27, y: origin.y + side * 0.53))
        mark.addLine(to: CGPoint(x: origin.x + side * 0.44, y: origin.y + side * 0.70))
        mark.addLine(to: CGPoint(x: origin.x + side * 0.75, y: origin.y + side * 0.31))
        checkLayer.path = mark.cgPath
    }
}
