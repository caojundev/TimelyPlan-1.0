//
//  MindMapNodeLayer.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/8.
//
//  节点图层**基类**：把「一种节点类型」封装成一个图层子类。
//
//  ── 分工 ────────────────────────────────────────────────────────────
//    基类（本文件）        节点共有的部分：定位、框型装饰、展开/折叠标记，
//                          以及「文本 + 内边距」的默认尺寸算法。
//    子类                 该类型特有的部分：
//                          · `size(constrainedTo:...)` 尺寸计算（可自定义，外部可传限定尺寸）
//                          · `updateContent(_:bounds:)` 用节点上的 `content` 配置自己
//    内容图层              统一负责缩放（对整个内容图层的 transform），
//                          节点图层自身**不做任何缩放**。
//
//  ── 新增一种节点类型 ────────────────────────────────────────────────
//    1. 加一个 `MindMapNodeKind` 常量与一个 `MindMapNodeContent` 载荷；
//    2. 写一个 `MindMapNodeLayer` 子类，重写 `kind`（必要时重写尺寸与配置）；
//    3. `MindMapNodeLayer.register(_:)` 注册。
//  布局引擎、内容图层、画布、命中测试都不需要改动。
//

import UIKit
import QuartzCore

open class MindMapNodeLayer: CALayer {

    // MARK: 类型

    /// 该图层负责的节点类型。子类重写。
    open class var kind: MindMapNodeKind { .text }

    // MARK: 根节点外观

    /// 根节点线框宽度
    open class var rootBorderWidth: CGFloat { 3.2 }

    /// 根节点线框圆角（较原有 7 更大）。
    open class var rootCornerRadius: CGFloat { 12 }

    // MARK: 依赖

    /// 度量参数（全局样式）。由内容图层在每次 `apply` 时下发。
    private(set) var metrics: MindMapMetrics = MindMapMetrics()
    /// 当前配色。
    private(set) var palette: MindMapPalette
    /// 当前节点数据，供重绘与外部查询。
    private(set) var nodeLayout: MindMapNodeLayout?

    /// 节点共有的装饰：下划线 / 线框。
    private let decorationLayer = CAShapeLayer()
    /// 展开 / 折叠的小圆点标记。
    private let markerLayer = CAShapeLayer()

    // MARK: 初始化

    public required init(palette: MindMapPalette) {
        self.palette = palette
        super.init()
        masksToBounds = false
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        decorationLayer.fillColor = UIColor.clear.cgColor
        decorationLayer.lineJoin = .round
        decorationLayer.lineCap = .butt
        addSublayer(decorationLayer)

        markerLayer.fillColor = UIColor.clear.cgColor
        markerLayer.lineWidth = 1.5
        addSublayer(markerLayer)
    }

    public override init(layer: Any) {
        let other = layer as? MindMapNodeLayer
        self.palette = other?.palette ?? MindMapPalette()
        self.metrics = other?.metrics ?? MindMapMetrics()
        super.init(layer: layer)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 尺寸（布局层调用）
    //
    //  刻意做成类方法：布局引擎需要在不创建图层的情况下先量出尺寸。
    //  默认实现是「文本 + 内边距」，子类重写它即可自定义尺寸算法。

    /// 计算节点内容块尺寸。
    ///
    /// - Parameter constraint: 外部传入的限定尺寸（如画布给定的最大节点尺寸）。
    ///   某一维 ≤ 0 表示该方向不限制。
    open class func size(constrainedTo constraint: CGSize,
                         text: String,
                         content: MindMapNodeContent?,
                         metrics: MindMapMetrics,
                         isRoot: Bool) -> CGSize {
        let insets = metrics.contentInsets(isRoot: isRoot)
        let maxTextWidth = constraint.width > 0
            ? max(0, constraint.width - insets.left - insets.right)
            : .greatestFiniteMagnitude
        let textSize = measureText(text, font: metrics.textFont(isRoot: isRoot),
                                   maxWidth: maxTextWidth)
        return CGSize(width: ceil(textSize.width) + insets.left + insets.right,
                      height: ceil(textSize.height) + insets.top + insets.bottom)
    }

    /// 文本测量：按 `maxWidth` 换行，返回占用的实际尺寸。
    /// 尺寸计算与文本绘制共用它，保证「量出来的」和「画出来的」一致。
    public class func measureText(_ text: String,
                                  font: UIFont,
                                  maxWidth: CGFloat) -> CGSize {
        let natural = ceil((text as NSString).size(withAttributes: [.font: font]).width)
        let width = min(natural, maxWidth.isFinite ? max(0, maxWidth) : natural)
        let bounds = (text as NSString).boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil)
        return CGSize(width: width, height: ceil(bounds.height))
    }

    // MARK: 应用数据

    /// 应用一次布局结果，并同步样式依赖。
    ///
    /// 不包裹 CATransaction：动画开关统一由调用方（MindMapContentLayer）控制。
    func apply(_ node: MindMapNodeLayout, metrics: MindMapMetrics, palette: MindMapPalette) {
        self.nodeLayout = node
        self.metrics = metrics
        self.palette = palette

        // bounds + position 直接定位，避免 frame 在缩放场景下的歧义。
        bounds = CGRect(origin: .zero, size: node.frame.size)
        position = CGPoint(x: node.frame.midX, y: node.frame.midY)

        updateDecoration(node: node, bounds: bounds)
        updateMarker(node: node, bounds: bounds)
        updateContent(node, bounds: bounds)
    }

    /// 用节点数据配置类型特有的内容。子类重写（基类没有内容）。
    ///
    /// `bounds` 为本图层的局部坐标（原点 0,0），与内容块坐标系一致。
    open func updateContent(_ node: MindMapNodeLayout, bounds: CGRect) {}

    /// 同步内容缩放比（Retina 适配）。
    /// 不用 `override var contentsScale`：CALayer 的该属性是 @NSManaged，
    /// Swift 的 didSet 观察器在其上不保证被回调。
    func updateContentsScale(_ scale: CGFloat) {
        contentsScale = scale
        updateContentsScale(scale, for: sublayers)
    }

    private func updateContentsScale(_ scale: CGFloat, for layers: [CALayer]?) {
        for layer in layers ?? [] {
            layer.contentsScale = scale
            updateContentsScale(scale, for: layer.sublayers)
        }
    }

    // MARK: 框型装饰（按 MindMapNodeStyle 绘制）

    private func updateDecoration(node: MindMapNodeLayout, bounds: CGRect) {
        switch metrics.style(isRoot: node.isRoot) {
        case .underline:
            // 横线画在内容块底边，也就是连线所在的高度：两端正好是连线的两个端点，
            // 粗细与连线一致 —— 整体看起来像连线从横线延伸出来。
            decorationLayer.strokeColor = node.color.cgColor
            decorationLayer.lineWidth = metrics.edgeLineWidth(isRoot: node.isRoot)

            let y = metrics.connectionY(in: bounds, isRoot: node.isRoot)
            let path = CGMutablePath()
            path.move(to: CGPoint(x: bounds.minX, y: y))
            path.addLine(to: CGPoint(x: bounds.maxX, y: y))
            decorationLayer.path = path

        case .box:
            // 线框：把内容块框起来，连线接在左右两条边的中点。
            // 根节点用主题的 rootBorder 描边，比下层更粗、圆角更大；不随 nodeStyle 变化。
            decorationLayer.strokeColor = node.isRoot ? palette.rootBorder.cgColor
                                                      : node.color.cgColor
            let borderWidth: CGFloat = node.isRoot ? Self.rootBorderWidth
                                                   : metrics.edgeLineWidth(isRoot: false)
            decorationLayer.lineWidth = borderWidth
            // 描边居中于路径，内缩半个线宽才能让线框完整落在内容块内。
            decorationLayer.path = UIBezierPath(roundedRect: bounds.insetBy(dx: borderWidth / 2,
                                                                            dy: borderWidth / 2),
                                                cornerRadius: node.isRoot ? Self.rootCornerRadius
                                                                          : metrics.cornerRadius).cgPath
        }
    }

    // MARK: 展开 / 折叠标记

    private func updateMarker(node: MindMapNodeLayout, bounds: CGRect) {
        guard node.hasChildren else {
            markerLayer.isHidden = true
            return
        }
        markerLayer.isHidden = false
        // 根节点的 +/- 指示器与线框同色（主题 rootBorder），其余跟随所属分支色。
        markerLayer.strokeColor = (node.isRoot ? palette.rootBorder : node.color).cgColor

        let size = metrics.collapseMarkerSize
        // 标记位于节点内容块右边缘的**外侧**，纵向与连线对齐；用距填充把节点引出的
        // 连线遮掉，视觉上就是一个挂在连线上的指示器。
        let center = metrics.collapseMarkerCenter(forNodeFrame: bounds, isRoot: node.isRoot)
        markerLayer.fillColor = palette.background.cgColor
        let rect = CGRect(x: center.x - size / 2, y: center.y - size / 2,
                          width: size, height: size)

        let path = UIBezierPath(roundedRect: rect, cornerRadius: size / 2)
        // 展开时显示「−」，折叠时显示「+」
        let bar = size * 0.5
        path.move(to: CGPoint(x: center.x - bar / 2, y: center.y))
        path.addLine(to: CGPoint(x: center.x + bar / 2, y: center.y))
        if !node.isExpanded {
            path.move(to: CGPoint(x: center.x, y: center.y - bar / 2))
            path.addLine(to: CGPoint(x: center.x, y: center.y + bar / 2))
        }
        markerLayer.path = path.cgPath
    }

    // MARK: 类型 → 图层子类

    /// 类型 → 图层子类。内置四种；用 `register(_:)` 追加自定义类型。
    ///
    /// 全局可变注册表，约定在主线程读写（与图层操作同一线程）。
    private static var registry: [MindMapNodeKind: MindMapNodeLayer.Type] = [
        .text: MindMapTextNodeLayer.self,
        .todo: MindMapTodoNodeLayer.self,
        .icon: MindMapIconNodeLayer.self,
        .progress: MindMapProgressNodeLayer.self
    ]

    /// 注册（或替换）一种节点类型对应的图层子类。
    public static func register(_ layerType: MindMapNodeLayer.Type) {
        registry[layerType.kind] = layerType
    }

    /// 某种类型对应的图层子类；未注册时回退到文本图层。
    public static func layerType(for kind: MindMapNodeKind) -> MindMapNodeLayer.Type {
        registry[kind] ?? MindMapTextNodeLayer.self
    }

    /// 创建某种类型的图层。
    public static func make(for kind: MindMapNodeKind, palette: MindMapPalette) -> MindMapNodeLayer {
        layerType(for: kind).init(palette: palette)
    }
}
