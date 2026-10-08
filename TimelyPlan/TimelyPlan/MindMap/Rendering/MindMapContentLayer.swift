//
//  MindMapContentLayer.swift
//  MindMapKit
//
//  渲染层：把布局结果画到一组 CALayer 上。
//
//  设计要点：
//  - 折线用 CAShapeLayer：矢量、GPU 合成、缩放时无需重绘，缩放画布时性能最优。
//  - 文本用 CATextLayer：避免为每个节点创建 UIView，几百个节点也只有图层开销。
//
//  ── 过渡动画为什么全部用「显式 CABasicAnimation」────────────────────────
//
//  1. 图层池按身份复用（nodeID / fromID→toID），而不是按数组下标。
//     展开 / 收起会插入或移除整棵子树，nodes / edges 的下标会整体错位；按下标
//     复用会让同一个图层在动画前后代表不同元素，文字瞬间变成新节点的内容、
//     位置却还在从旧节点滑过来 —— 也就是「内容跳位」。
//
//  2. 所有属性写入都在同一个「关闭隐式动画」的事务里完成，再由显式动画驱动过渡。
//     隐式动画会为每次属性写入各自生成动画，且容易受嵌套 CATransaction 的设置
//     影响而拿到不同时长 / 曲线，几个元素各走各的节奏就是「不流畅、有残影」。
//     显式动画只有一个时长、一条曲线，所有元素严格同步。
//
//  3. 只有会移动的东西才加动画（position / transform.scale / path），文字、描边、
//     折叠标记等子图层随父图层一起平移缩放，不再各自插值，消除内部错位。
//
//  ── 展开 / 收起的方向感 ──────────────────────────────────────────────
//
//  过渡会带两个参考点，都取被展开 / 收起节点**右侧折叠标记**的中心 —— 也就是连线
//  离开该节点的位置，子节点与连线都从这一点长出 / 收回这一点：
//    · expandOrigin   —— 取「旧布局」里的位置。t=0 那一刻容器 bounds 还是旧尺寸，
//                        标记也仍渲染在旧位置，只有这样新元素才恰好从标记处长出。
//    · collapseTarget —— 取「新布局」里的位置。动画结束时标记正好在那里，
//                        收缩进去才能精确汇入标记。
//

import UIKit
import QuartzCore

/// 负责把 MindMapLayoutResult 渲染成图层树的内容容器。
public final class MindMapContentLayer: CALayer {

    // MARK: 依赖

    private var metrics: MindMapMetrics
    /// 当前配色，运行时可替换。
    public private(set) var palette: MindMapPalette

    /// 过渡时长。容器尺寸、节点位移、连线形变、淡入淡出全部共用这一个值，
    /// 保证所有元素同进同出。
    public var transitionDuration: CFTimeInterval = 0.22

    /// 过渡曲线，同样只定义一次。
    private static let transitionTiming = CAMediaTimingFunction(name: .easeOut)

    /// 展开时子节点的起始缩放、收起时的结束缩放。
    /// 取一个极小值而不是 0：缩放矩阵可逆，避免文本在退化变换下渲染异常。
    private static let collapsedScale: CGFloat = 0.01

    /// 固定动画 key：同一属性的新动画会覆盖旧动画，不会叠加。
    private enum AnimationKey {
        static let bounds = "mindmap.bounds"
        static let position = "mindmap.position"
        static let scale = "mindmap.scale"
        static let path = "mindmap.path"
        static let fade = "mindmap.fade"
    }

    /// 运行时替换度量参数（换字号 / 间距等）。
    ///
    /// 只记录，不逐个刷新已有图层 —— 尺寸属于各节点图层，改度量等于要重新布局，
    /// 调用方（MindMapCanvasView）会随即触发一次完整重排，这里再刷一遍纯属重复。
    public var metricsValue: MindMapMetrics {
        get { metrics }
        set { metrics = newValue }
    }

    // MARK: 图层池（按身份索引）

    private var edgeLayers: [String: CAShapeLayer] = [:]
    private var nodeLayers: [String: MindMapNodeLayer] = [:]

    /// 正在淡出的图层：收起后不立即摘除，等动画结束再移除。期间若节点又被展开，
    /// 可以据此撤销，避免「已移除的图层」和「新建的图层」同时存在。
    ///
    /// 值是一次性的令牌：同一个节点在动画未结束时被反复收起，只有最后一次登记的
    /// 清理任务会真正摘除图层，否则旧的延时任务会把它提前摘掉。
    private var fadingOutNodeTokens: [String: Int] = [:]
    private var fadingOutEdgeTokens: [String: Int] = [:]
    private var fadeTokenSequence = 0

    // MARK: 初始化

    public init(metrics: MindMapMetrics, palette: MindMapPalette) {
        self.metrics = metrics
        self.palette = palette
        super.init()
        masksToBounds = false
        backgroundColor = UIColor.clear.cgColor
    }

    override init(layer: Any) {
        let other = layer as? MindMapContentLayer
        self.metrics = other?.metrics ?? MindMapMetrics()
        self.palette = other?.palette ?? MindMapPalette()
        super.init(layer: layer)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 主题切换

    /// 运行时替换配色。同样只记录：连线的颜色、框型装饰与折叠标记的颜色都是布局时
    /// 按当时配色算好的，调用方会重新布局并整体刷新。
    public func paletteChanged(_ palette: MindMapPalette) {
        self.palette = palette
    }

    // MARK: 应用布局

    /// 将一次布局结果渲染出来。
    /// - Parameters:
    ///   - result: 新的布局结果。
    ///   - animated: 是否过渡到新布局（展开 / 收起建议开启）。
    ///   - expandOrigin: 展开时新元素出现的起点，应当传「被展开节点右侧折叠标记在
    ///     **旧布局**中的位置」。容器 bounds 的动画从旧尺寸开始，所以 t=0 那一刻整个
    ///     内容坐标系还是旧的，节点也还渲染在旧位置；若用新位置作起点，起点就会偏离
    ///     标记本身。
    ///   - collapseTarget: 收起时消失元素的终点，传「被收起节点右侧折叠标记在
    ///     **新布局**中的位置」，这样它们最终正好收进动画结束时标记所在的位置。
    ///   - 两者传 nil 时，新元素只在原地淡入、消失的元素只在原地淡出。
    public func apply(_ result: MindMapLayoutResult,
                      animated: Bool,
                      expandOrigin: CGPoint? = nil,
                      collapseTarget: CGPoint? = nil) {
        // 只在这一处关闭隐式动画，而且绝不嵌套 CATransaction：
        // 属性立即落到模型值，需要过渡的部分由显式动画负责。
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        applyBounds(result, animated: animated)
        applyEdges(result.edges, animated: animated,
                   expandOrigin: expandOrigin, collapseTarget: collapseTarget)
        applyNodes(result.nodes, animated: animated,
                   expandOrigin: expandOrigin, collapseTarget: collapseTarget)

        CATransaction.commit()
    }

    // MARK: 容器尺寸

    private func applyBounds(_ result: MindMapLayoutResult, animated: Bool) {
        let newBounds = CGRect(origin: .zero, size: result.contentBounds.size)
        guard bounds != newBounds else { return }

        let oldBounds = bounds
        bounds = newBounds

        guard animated else {
            removeAnimation(forKey: AnimationKey.bounds)
            return
        }
        // 本层绕 anchorPoint 居中，bounds 变化会平移整个内容坐标系。
        // 它必须和节点的位移用同样的时长 / 曲线，否则动画期间整图会先偏一下再归位。
        add(makeAnimation(keyPath: "bounds",
                          from: NSValue(cgRect: oldBounds),
                          to: NSValue(cgRect: newBounds)),
            forKey: AnimationKey.bounds)
    }

    // MARK: 节点

    private func applyNodes(_ nodes: [MindMapNodeLayout],
                            animated: Bool,
                            expandOrigin: CGPoint?,
                            collapseTarget: CGPoint?) {
        var activeIDs = Set<String>(minimumCapacity: nodes.count)

        for (index, node) in nodes.enumerated() {
            activeIDs.insert(node.id)

            var appeared = false
            let layer: MindMapNodeLayer
            // 图层类由节点类型决定；类型变了（节点被改成另一种节点）就换一个图层，
            // 否则复用同一实例 —— 池是按 nodeID 复用的，类型不匹配必须重建，
            // 不然会残留上一个类型的子图层。
            let layerType = MindMapNodeLayer.layerType(for: node.kind)

            if let existing = nodeLayers[node.id], type(of: existing) == layerType {
                layer = existing
                if fadingOutNodeTokens.removeValue(forKey: node.id) != nil {
                    // 上一轮收起的动画还没走完，节点又被展开：撤销淡出，
                    // 并且同样按「重新长出来」处理，保持观感一致。
                    layer.removeAllAnimations()
                    layer.opacity = 1
                    appeared = true
                }
            } else {
                // 新出现（展开时被揭示），或类型被换掉。
                nodeLayers.removeValue(forKey: node.id)?.removeFromSuperlayer()
                layer = MindMapNodeLayer.make(for: node.kind, palette: palette)
                layer.updateContentsScale(contentsScale)
                nodeLayers[node.id] = layer
                addSublayer(layer)
                appeared = true
            }

            // 记录动画前的位置：优先取呈现值，快速连续点击时才能从「当前看到的
            // 位置」继续，而不是从上一轮的目标位置跳一下。
            let oldPosition = layer.presentation()?.position ?? layer.position

            layer.apply(node, metrics: metrics, palette: palette)
            layer.zPosition = CGFloat(index)

            guard animated else {
                layer.removeAllAnimations()
                layer.opacity = 1
                continue
            }

            if appeared {
                // 展开：从被展开节点处滑向自身位置，同时由 0 放大到 1 并淡入。
                layer.opacity = 1
                layer.add(makeAnimation(keyPath: "opacity",
                                        from: NSNumber(value: 0), to: NSNumber(value: 1)),
                          forKey: AnimationKey.fade)
                if let origin = expandOrigin {
                    layer.add(makeAnimation(keyPath: "transform.scale",
                                            from: NSNumber(value: Double(Self.collapsedScale)),
                                            to: NSNumber(value: 1)),
                              forKey: AnimationKey.scale)
                    if origin != layer.position {
                        layer.add(makeAnimation(keyPath: "position",
                                                from: NSValue(cgPoint: origin),
                                                to: NSValue(cgPoint: layer.position)),
                                  forKey: AnimationKey.position)
                    }
                }
            } else if oldPosition != layer.position {
                layer.add(makeAnimation(keyPath: "position",
                                        from: NSValue(cgPoint: oldPosition),
                                        to: NSValue(cgPoint: layer.position)),
                          forKey: AnimationKey.position)
            }
        }

        // 收起：被隐藏的子树整体收缩回锚点，动画结束再摘除图层。
        let staleIDs = nodeLayers.keys.filter {
            !activeIDs.contains($0) && fadingOutNodeTokens[$0] == nil
        }
        for id in staleIDs {
            guard let layer = nodeLayers[id] else { continue }
            guard animated else {
                nodeLayers.removeValue(forKey: id)?.removeFromSuperlayer()
                continue
            }

            fadeTokenSequence += 1
            let token = fadeTokenSequence
            fadingOutNodeTokens[id] = token

            let fromPosition = layer.presentation()?.position ?? layer.position
            let fromOpacity = layer.presentation()?.opacity ?? layer.opacity
            let target = collapseTarget ?? fromPosition

            layer.position = target
            layer.opacity = 0
            layer.add(makeAnimation(keyPath: "position",
                                    from: NSValue(cgPoint: fromPosition),
                                    to: NSValue(cgPoint: target)),
                      forKey: AnimationKey.position)
            layer.add(makeAnimation(keyPath: "opacity",
                                    from: NSNumber(value: fromOpacity), to: NSNumber(value: 0)),
                      forKey: AnimationKey.fade)
            if collapseTarget != nil {
                layer.add(makeAnimation(keyPath: "transform.scale",
                                        from: NSNumber(value: 1),
                                        to: NSNumber(value: Double(Self.collapsedScale))),
                          forKey: AnimationKey.scale)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) { [weak self] in
                guard let self = self, self.fadingOutNodeTokens[id] == token else { return }
                self.fadingOutNodeTokens.removeValue(forKey: id)
                self.nodeLayers.removeValue(forKey: id)?.removeFromSuperlayer()
            }
        }
    }

    // MARK: 连线

    private func applyEdges(_ edges: [MindMapEdgeLayout],
                            animated: Bool,
                            expandOrigin: CGPoint?,
                            collapseTarget: CGPoint?) {
        var activeKeys = Set<String>(minimumCapacity: edges.count)

        for edge in edges {
            let key = Self.edgeKey(edge)
            activeKeys.insert(key)

            var appeared = false
            let layer: CAShapeLayer
            if let existing = edgeLayers[key] {
                layer = existing
                if fadingOutEdgeTokens.removeValue(forKey: key) != nil {
                    layer.removeAllAnimations()
                    layer.opacity = 1
                    appeared = true
                }
            } else {
                layer = CAShapeLayer()
                layer.fillColor = UIColor.clear.cgColor
                layer.lineCap = .round
                layer.lineJoin = .round
                layer.contentsScale = contentsScale
                layer.zPosition = -1   // 连线恒在节点之下
                edgeLayers[key] = layer
                addSublayer(layer)
                appeared = true
            }

            let oldPath = layer.presentation()?.path ?? layer.path
            layer.path = edge.path
            layer.strokeColor = edge.color.cgColor
            layer.lineWidth = edge.lineWidth

            guard animated else {
                layer.removeAllAnimations()
                layer.opacity = 1
                continue
            }

            if appeared {
                layer.opacity = 1
                layer.add(makeAnimation(keyPath: "opacity",
                                        from: NSNumber(value: 0), to: NSNumber(value: 1)),
                          forKey: AnimationKey.fade)
                // 展开：连线从被展开节点处「抽」出来。
                if let origin = expandOrigin {
                    layer.add(makeAnimation(keyPath: "path",
                                            from: Self.path(edge.path, collapsedAt: origin),
                                            to: edge.path),
                              forKey: AnimationKey.path)
                }
            } else if let oldPath = oldPath {
                // from / to 结构一致（见 MindMapLayoutEngine.makeEdge），
                // 因此这里是真正的形状插值，不会退化成交叉淡入淡出。
                layer.add(makeAnimation(keyPath: "path", from: oldPath, to: edge.path),
                          forKey: AnimationKey.path)
            }
        }

        // 收起：连线整体缩回锚点。
        let staleKeys = edgeLayers.keys.filter {
            !activeKeys.contains($0) && fadingOutEdgeTokens[$0] == nil
        }
        for key in staleKeys {
            guard let layer = edgeLayers[key] else { continue }
            guard animated else {
                edgeLayers.removeValue(forKey: key)?.removeFromSuperlayer()
                continue
            }

            fadeTokenSequence += 1
            let token = fadeTokenSequence
            fadingOutEdgeTokens[key] = token

            let fromPath = layer.presentation()?.path ?? layer.path
            let fromOpacity = layer.presentation()?.opacity ?? layer.opacity
            let targetPath = (collapseTarget.flatMap { point in
                fromPath.map { Self.path($0, collapsedAt: point) }
            }) ?? fromPath

            layer.path = targetPath
            layer.opacity = 0
            if let fromPath = fromPath, let targetPath = targetPath {
                layer.add(makeAnimation(keyPath: "path", from: fromPath, to: targetPath),
                          forKey: AnimationKey.path)
            }
            layer.add(makeAnimation(keyPath: "opacity",
                                    from: NSNumber(value: fromOpacity), to: NSNumber(value: 0)),
                      forKey: AnimationKey.fade)

            DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) { [weak self] in
                guard let self = self, self.fadingOutEdgeTokens[key] == token else { return }
                self.fadingOutEdgeTokens.removeValue(forKey: key)
                self.edgeLayers.removeValue(forKey: key)?.removeFromSuperlayer()
            }
        }
    }

    private static func edgeKey(_ edge: MindMapEdgeLayout) -> String {
        "\(edge.fromID)->\(edge.toID)"
    }

    /// 生成与 `path` 元素结构完全一致、但整体收缩到 `point` 的路径。
    ///
    /// 逐元素改写而不是直接画一个点：CAShapeLayer 在两端 path 的控制点数量不同时
    /// 无法插值，只能交叉淡入淡出（看起来就是残影），因此必须保持结构一致。
    private static func path(_ path: CGPath, collapsedAt point: CGPoint) -> CGPath {
        let collapsed = CGMutablePath()
        path.applyWithBlock { element in
            switch element.pointee.type {
            case .moveToPoint:
                collapsed.move(to: point)
            case .addLineToPoint:
                collapsed.addLine(to: point)
            case .addQuadCurveToPoint:
                collapsed.addQuadCurve(to: point, control: point)
            case .addCurveToPoint:
                collapsed.addCurve(to: point, control1: point, control2: point)
            case .closeSubpath:
                collapsed.closeSubpath()
            @unknown default:
                break
            }
        }
        return collapsed
    }

    // MARK: 动画

    private func makeAnimation(keyPath: String, from: Any?, to: Any?) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.fromValue = from
        animation.toValue = to
        animation.duration = transitionDuration
        animation.timingFunction = Self.transitionTiming
        return animation
    }

    /// 统一设置内容缩放比（Retina 适配）。
    /// 不用 `override var contentsScale`，因为 CALayer 的该属性是 @NSManaged，
    /// Swift 的 didSet 观察器在其上不保证被回调。
    public func updateContentsScale(_ scale: CGFloat) {
        contentsScale = scale
        edgeLayers.values.forEach { $0.contentsScale = scale }
        nodeLayers.values.forEach { $0.updateContentsScale(scale) }
    }
}
