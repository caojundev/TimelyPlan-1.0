//
//  MindMapLayout.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/8.
//
//  布局层：纯几何计算，不创建视图 / 图层，可独立单元测试。
//
//  ── 算法（两遍 DFS，O(n)）──────────────────────────────────────────────
//
//  第一遍（后序）measure：
//    为每个节点计算
//      subtreeHeight —— 该子树占据的垂直高度
//                        叶子：自身高度
//                        内部：max(子节点高度之和 + 兄弟间距之和, 自身高度)
//      childrenSpan  —— 子节点区间的总高度（不含父节点自身）
//
//  第二遍（前序）place：
//    以「父节点中心 y」为唯一基准向下展开，保证两个不变量恒成立：
//      ① 子节点区间整体中心 == 父节点中心
//      ② 兄弟节点依次排列，间距为 siblingSpacing
//    子节点自身中心 = 子节点区间顶部 + 该子节点 subtreeHeight / 2
//
//  这样递归自洽，全树零偏差：任意父节点都精确垂直居中于其整个子树区间。
//
//  ── 为什么不用「父节点居中于子节点自身框」────────────────────────────
//    当子节点本身还有很深的分支时，子节点的「框」远小于它的子树区间，
//    按框对齐会让深层分支明显偏斜。按子树区间对齐才是脑图的标准做法。
//
//  ── 坐标系统 ──────────────────────────────────────────────────────────
//    内部以根节点左侧中点为参考原点，最后统一平移使包围盒落在 (0, 0)，
//    视图层可以完全不管坐标原点问题。
//
//  ── 节点尺寸 ──────────────────────────────────────────────────────────
//    尺寸计算不属于布局，而属于**图层子类**：引擎只向
//    `MindMapNodeLayer.layerType(for:)` 要一个尺寸（外部限定尺寸由 `metrics`
//    下发），因此新增节点类型不需要改动本文件。
//

import UIKit

// MARK: - 输出结构

/// 单个节点在画布上的完整几何信息。
public struct MindMapNodeLayout {
    public let id: String
    public let text: String
    /// 节点类型（文本 / 待办 / 图标 / 自定义）。
    public let kind: MindMapNodeKind
    /// 节点携带的类型化数据：图层子类据此配置自己。
    public let content: MindMapNodeContent?
    /// 节点内容块的包围盒。
    public let frame: CGRect
    /// 向右引出连线的起点。位置由节点框型决定：
    /// 下划线样式在内容块右下角（横线右端），线框样式在右边缘中点。
    public let anchorOut: CGPoint
    /// 从左侧接入连线的终点，与 anchorOut 同高。
    public let anchorIn: CGPoint
    public let depth: Int
    /// 所属一级分支下标（根节点为 -1），用于整条分支统一着色。
    public let branchIndex: Int
    public let color: UIColor
    /// 是否拥有子节点（决定是否绘制展开/折叠标记）。
    public let hasChildren: Bool
    public let isExpanded: Bool
    public let isRoot: Bool
}

/// 一条父子之间的圆角折线。
public struct MindMapEdgeLayout {
    public let fromID: String
    public let toID: String
    public let path: CGPath
    public let color: UIColor
    public let lineWidth: CGFloat
}

/// 一次布局的完整结果。
public struct MindMapLayoutResult {
    public let nodes: [MindMapNodeLayout]
    public let edges: [MindMapEdgeLayout]
    /// 整棵树包围盒，原点已归一化到 (0, 0)。
    public let contentBounds: CGRect
    /// 按 nodeID 索引，供交互与命中测试使用。
    public let nodeIndex: [String: MindMapNodeLayout]

    public static let empty = MindMapLayoutResult(nodes: [], edges: [],
                                                  contentBounds: .zero, nodeIndex: [:])
}

// MARK: - 布局引擎

public final class MindMapLayoutEngine {

    private var metrics: MindMapMetrics
    /// 配色会在运行时变化（换肤），因此不是 let。
    private var palette: MindMapPalette

    /// 第一遍产出的中间量，第二遍直接复用，避免重复递归。
    ///
    /// 使用 ObjectIdentifier 作为键，而不是 nodeID：
    /// nodeID 由调用方提供，理论上可能重复；ObjectIdentifier 基于对象地址，
    /// 在同一棵树内天然唯一，从根上杜绝 id 冲突导致的布局错乱。
    private var measures: [ObjectIdentifier: Measurement] = [:]

    /// 子树测量的中间结果。
    private struct Measurement {
        /// 子树占据的垂直高度。
        var subtreeHeight: CGFloat
        /// 子节点区间总高度（叶子为 0）。
        var childrenSpan: CGFloat
    }

    public init(metrics: MindMapMetrics, palette: MindMapPalette) {
        self.metrics = metrics
        self.palette = palette
    }

    /// 更新配色（换肤）。下次布局即生效。
    public func update(metrics: MindMapMetrics? = nil, palette: MindMapPalette? = nil) {
        if let metrics = metrics { self.metrics = metrics }
        if let palette = palette { self.palette = palette }
    }

    // MARK: 入口

    public func layout(root: MindMapNodeType) -> MindMapLayoutResult {
        measures.removeAll(keepingCapacity: true)

        // ---- 第一遍：后序测量 ----
        _ = measure(node: root, depth: 0)

        // ---- 第二遍：前序落位 ----
        var nodes: [MindMapNodeLayout] = []
        var edges: [MindMapEdgeLayout] = []
        let capacity = measures.count
        nodes.reserveCapacity(capacity)
        edges.reserveCapacity(max(0, capacity - 1))

        // 根节点：以 y = 0 为中心，x 从 0 开始
        place(node: root, depth: 0, centerY: 0, leftX: 0,
              branchIndex: -1, nodes: &nodes, edges: &edges)

        return normalize(nodes: nodes, edges: edges)
    }

    // MARK: 第一遍：后序测量

    @discardableResult
    private func measure(node: MindMapNodeType, depth: Int) -> CGFloat {
        let ownHeight = contentSize(of: node, depth: depth).height
        let key = ObjectIdentifier(node)

        let children = node.visibleChildren
        guard !children.isEmpty else {
            let result = Measurement(subtreeHeight: ownHeight, childrenSpan: 0)
            measures[key] = result
            return result.subtreeHeight
        }

        var span: CGFloat = 0
        for (index, child) in children.enumerated() {
            span += measure(node: child, depth: depth + 1)
            if index > 0 { span += metrics.siblingSpacing }
        }

        let result = Measurement(subtreeHeight: max(span, ownHeight), childrenSpan: span)
        measures[key] = result
        return result.subtreeHeight
    }
    // MARK: 第二遍：前序落位

    @discardableResult
    private func place(node: MindMapNodeType,
                       depth: Int,
                       centerY: CGFloat,
                       leftX: CGFloat,
                       branchIndex: Int,
                       nodes: inout [MindMapNodeLayout],
                       edges: inout [MindMapEdgeLayout]) -> MindMapNodeLayout {

        let size = contentSize(of: node, depth: depth)
        let frame = CGRect(x: leftX,
                           y: centerY - size.height / 2,
                           width: size.width,
                           height: size.height)

        let color = resolveColor(depth: depth, branchIndex: branchIndex)
        let view = makeNodeLayout(node: node, depth: depth, frame: frame,
                                  branchIndex: branchIndex, color: color)
        nodes.append(view)

        let children = node.visibleChildren
        guard !children.isEmpty else { return view }

        // 子节点区间顶部：以父节点中心为基准向两侧对称展开
        // 这是全算法的核心一行 —— 它保证了「父居中于子整体」恒成立。
        let span = measures[ObjectIdentifier(node)]?.childrenSpan ?? 0
        var cursor = centerY - span / 2
        let childLeft = frame.maxX + metrics.levelSpacing

        for (index, child) in children.enumerated() {
            let childSubtreeHeight = measures[ObjectIdentifier(child)]?.subtreeHeight ?? 0
            let childCenterY = cursor + childSubtreeHeight / 2
            let childBranch = (depth == 0) ? index : branchIndex

            let childLayout = place(node: child, depth: depth + 1,
                                    centerY: childCenterY, leftX: childLeft,
                                    branchIndex: childBranch,
                                    nodes: &nodes, edges: &edges)

            // 连线的两个端点完全由节点框型决定（anchorOut / anchorIn）：
            // 下划线样式取横线两端，线框样式取左右边中点，这里不做任何假设。
            //
            // 颜色取「子节点」的（即所属分支色），而不是父节点的颜色 —— 父节点若是
            // 根节点，其颜色是中性文字色（白），会让根 → 第一层的连线变成白色。
            // 线宽仍按父节点深度决定：根节点引出的线更粗。
            edges.append(makeEdge(parent: view, child: childLayout, parentDepth: depth,
                                  color: resolveColor(depth: depth + 1,
                                                      branchIndex: childBranch)))

            cursor += childSubtreeHeight + metrics.siblingSpacing
        }

        return view
    }

    // MARK: 节点几何

    private func makeNodeLayout(node: MindMapNodeType, depth: Int, frame: CGRect,
                                branchIndex: Int, color: UIColor) -> MindMapNodeLayout {
        let isRoot = depth == 0
        // 连线锚点交给框型（MindMapNodeStyle）计算，换框型时这里不用改。
        return MindMapNodeLayout(id: node.nodeID,
                                 text: node.text,
                                 kind: node.kind,
                                 content: node.content,
                                 frame: frame,
                                 anchorOut: metrics.anchorOut(in: frame, isRoot: isRoot),
                                 anchorIn: metrics.anchorIn(in: frame, isRoot: isRoot),
                                 depth: depth,
                                 branchIndex: branchIndex,
                                 color: color,
                                 hasChildren: !node.children.isEmpty,
                                 isExpanded: node.isExpanded,
                                 isRoot: isRoot)
    }

    // MARK: 尺寸测量

    /// 尺寸完全交给节点类型对应的图层子类计算。
    ///
    /// 限定尺寸（`metrics.maxNodeSize`）由这里外部下发，图层子类自行决定怎么用
    /// （文本节点用来限制换行宽度，其它类型可以另作解释）。
    ///
    /// 不做缓存：尺寸可能依赖 `content`（如图标名），而 content 是可变的；
    /// 一次全树测量对几百个节点来说是微秒级开销，不值得为它引入缓存失效的坑。
    private func contentSize(of node: MindMapNodeType, depth: Int) -> CGSize {
        let layerType = MindMapNodeLayer.layerType(for: node.kind)
        return layerType.size(constrainedTo: metrics.maxNodeSize,
                              text: node.text,
                              content: node.content,
                              metrics: metrics,
                              isRoot: depth == 0)
    }

    // MARK: 颜色

    private func resolveColor(depth: Int, branchIndex: Int) -> UIColor {
        guard depth > 0 else { return palette.text }
        return palette.branchColor(at: max(0, branchIndex))
    }

    // MARK: 折线生成

    /// 生成「父 → 子」的圆角直角折线：横向 → 纵向 → 横向。
    /// 两端直接取两个节点的锚点，位置由节点框型决定（下划线样式是横线两端）。
    /// - Parameter color: 连线颜色，应传子节点所属分支的颜色（见 place 中的调用）。
    private func makeEdge(parent: MindMapNodeLayout,
                          child: MindMapNodeLayout,
                          parentDepth: Int,
                          color: UIColor) -> MindMapEdgeLayout {
        let start = parent.anchorOut
        let end = child.anchorIn

        let path = CGMutablePath()
        path.move(to: start)

        let dy = end.y - start.y
        let midX = start.x + (end.x - start.x) * 0.5
        let radius = min(metrics.cornerRadius, abs(dy) * 0.5, max(0, (end.x - start.x) * 0.5))
        let dir: CGFloat = dy >= 0 ? 1 : -1
        // 四分之一圆弧的贝塞尔控制点系数：≈ 4/3 * tan(π/8)
        let k = radius * 0.5522847498

        // 这里刻意不使用 addArc：它会在 radius == 0 时退化成直线，导致路径的元素
        // 个数随布局变化而增减。CAShapeLayer 在两端 path 的控制点数量不一致时无法
        // 插值，只能做交叉淡入淡出 —— 那正是展开 / 收起时连线出现的「残影」。
        // 因此固定输出「移动 → 直线 → 曲线 → 直线 → 曲线 → 直线」六个元素，
        // dy 为 0 时两个圆角自然收缩为一点，结构始终不变。
        path.addLine(to: CGPoint(x: midX - radius, y: start.y))
        path.addCurve(to: CGPoint(x: midX, y: start.y + dir * radius),
                      control1: CGPoint(x: midX - radius + k, y: start.y),
                      control2: CGPoint(x: midX, y: start.y + dir * (radius - k)))
        path.addLine(to: CGPoint(x: midX, y: end.y - dir * radius))
        path.addCurve(to: CGPoint(x: midX + radius, y: end.y),
                      control1: CGPoint(x: midX, y: end.y - dir * (radius - k)),
                      control2: CGPoint(x: midX + radius - k, y: end.y))
        path.addLine(to: end)

        return MindMapEdgeLayout(fromID: parent.id,
                                 toID: child.id,
                                 path: path,
                                 color: color,
                                 lineWidth: metrics.edgeLineWidth(isRoot: parentDepth == 0))
    }

    // MARK: 归一化

    private func normalize(nodes: [MindMapNodeLayout],
                           edges: [MindMapEdgeLayout]) -> MindMapLayoutResult {
        var bounds = CGRect.null
        for node in nodes { bounds = bounds.union(node.frame) }
        guard !bounds.isNull else { return .empty }

        let dx = -bounds.minX
        let dy = -bounds.minY

        if dx == 0 && dy == 0 {
            return MindMapLayoutResult(
                nodes: nodes, edges: edges,
                contentBounds: CGRect(origin: .zero, size: bounds.size),
                nodeIndex: Dictionary(uniqueKeysWithValues: nodes.map { ($0.id, $0) }))
        }

        var transform = CGAffineTransform(translationX: dx, y: dy)
        let movedNodes = nodes.map { shift($0, dx: dx, dy: dy) }
        let movedEdges = edges.map { edge -> MindMapEdgeLayout in
            guard let path = edge.path.copy(using: &transform) else { return edge }
            return MindMapEdgeLayout(fromID: edge.fromID, toID: edge.toID,
                                     path: path, color: edge.color, lineWidth: edge.lineWidth)
        }

        return MindMapLayoutResult(
            nodes: movedNodes,
            edges: movedEdges,
            contentBounds: CGRect(origin: .zero, size: bounds.size),
            nodeIndex: Dictionary(uniqueKeysWithValues: movedNodes.map { ($0.id, $0) }))
    }

    private func shift(_ node: MindMapNodeLayout, dx: CGFloat, dy: CGFloat) -> MindMapNodeLayout {
        MindMapNodeLayout(id: node.id,
                          text: node.text,
                          kind: node.kind,
                          content: node.content,
                          frame: node.frame.offsetBy(dx: dx, dy: dy),
                          anchorOut: CGPoint(x: node.anchorOut.x + dx, y: node.anchorOut.y + dy),
                          anchorIn: CGPoint(x: node.anchorIn.x + dx, y: node.anchorIn.y + dy),
                          depth: node.depth,
                          branchIndex: node.branchIndex,
                          color: node.color,
                          hasChildren: node.hasChildren,
                          isExpanded: node.isExpanded,
                          isRoot: node.isRoot)
    }
}
