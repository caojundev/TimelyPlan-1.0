//
//  MindMapCanvasView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/8.
//
//  视图层：可拖动、可缩放的画布。所有尺寸均由手工计算得出，未使用 Auto Layout。
//
//  手势方案：
//  - 单指拖动 → 平移
//  - 双指捏合 → 缩放（以捏合中心为锚点，视觉上更自然）
//  - 单击节点标记区域 → 展开 / 收起
//  平移与缩放统一通过 contentLayer 的 transform 实现，不触发重新布局。
//

import UIKit

public final class MindMapCanvasView: UIView {

    // MARK: 配置

    /// 度量参数。修改后自动触发重新布局。
    /// 注意：Swift 的 didSet 在 init 期间不触发，因此初始值在 init 中显式下发。
    public var metrics: MindMapMetrics {
        didSet {
            engine.update(metrics: metrics)
            contentLayer.metricsValue = metrics
            needsRelayout = true
            setNeedsLayout()
        }
    }

    /// 配色。修改后立即换肤。
    public var palette: MindMapPalette {
        didSet {
            engine.update(palette: palette)
            contentLayer.paletteChanged(palette)
            backgroundColor = palette.background
            // 连线的颜色、节点装饰与折叠标记的颜色都是布局时按当时配色算好的，
            // 换肤后要重算一次布局才能整体刷新（纯计算、O(n)，不做动画）。
            if root != nil { rebuildLayout(animated: false) }
        }
    }
    /// 缩放范围。
    public var minScale: CGFloat = 0.25
    public var maxScale: CGFloat = 3.0

    /// 双击空白画布放大到的比例；已经放大到该比例（或更大）时，双击改为缩回
    /// 「整棵树自适应屏幕」的比例（`fitScale`，上限为 1）。缩放始终以双击点为不动点。
    ///
    /// 取 1.2 而不是 1.0：自适应比例本身不超过 1，若目标也是 1.0，那么对一棵
    /// 刚好以 1:1 铺满的图，双击放大和目标缩回会落在同一个比例上，双击就失效了。
    /// 1.2 保证了「放大 / 缩回」这一对状态在任何情况下都不同，且文字仍接近自然大小。
    public var doubleTapZoomScale: CGFloat = 1.2

    /// 展开 / 收起动画时长。内容是唯一的时长来源，会同步给内容图层，
    /// 保证容器尺寸、节点位移、连线形变、淡入淡出共用同一个节奏。
    public var expandAnimationDuration: TimeInterval = 0.22 {
        didSet { contentLayer.transitionDuration = expandAnimationDuration }
    }

    /// 节点点击回调（仅在点击展开标记区域时触发）。
    public var onNodeToggled: ((MindMapNodeType) -> Void)?

    /// 所在环境的明暗发生变化时回调，并把当前 trait 一起传出去。
    ///
    /// 主题管理器（MindMapThemeManager）接入时会挂上它，用来在系统深/浅色切换时
    /// 自动套用对应配色；其它需要跟随明暗的 UI 也可以使用。
    /// - Note: 接入主题管理器期间该回调归它占用，请勿在同一个画布上另接实现。
    public var appearanceDidChange: ((UITraitCollection) -> Void)?

    /// 缩放百分比指示器：捏合画布时自动显示在双指之间。
    ///
    /// 它是个独立组件（见 MindMapZoomIndicatorView），其它需要提示缩放的场景
    /// 可以直接复用，例如双击放大、代码设置缩放：
    ///
    ///     canvas.zoomIndicator.update(scale: 2, anchor: pointInCanvas)
    ///     canvas.zoomIndicator.dismiss()
    public let zoomIndicator = MindMapZoomIndicatorView()

    // MARK: 内部

    private let contentLayer: MindMapContentLayer
    private let engine: MindMapLayoutEngine

    private var root: MindMapNodeType?
    private var layoutResult: MindMapLayoutResult = .empty

    /// 内容相对画布中心的累积偏移（屏幕坐标，未受缩放影响）。
    private var panOffset: CGPoint = .zero
    private var zoomScale: CGFloat = 1

    private var needsRelayout = true
    /// 是否已经完成首次自适应居中。
    private var didFitOnce = false

    // MARK: 初始化

    public init(metrics: MindMapMetrics = MindMapMetrics(),
                palette: MindMapPalette = MindMapPalette()) {
        self.metrics = metrics
        self.palette = palette
        self.engine = MindMapLayoutEngine(metrics: metrics, palette: palette)
        self.contentLayer = MindMapContentLayer(metrics: metrics, palette: palette)
        super.init(frame: .zero)

        backgroundColor = palette.background
        clipsToBounds = true

        layer.addSublayer(contentLayer)
        contentLayer.updateContentsScale(UIScreen.main.scale)
        // didSet 在 init 期间不触发，这里显式下发一次。
        contentLayer.transitionDuration = expandAnimationDuration

        // 指示器是普通子视图，不随内容图层的缩放变换，恒在最上层。
        addSubview(zoomIndicator)

        installGestures()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 尺寸变化

    public override func layoutSubviews() {
        super.layoutSubviews()

        // 内容图层绕自身锚点变换，锚点固定在画布中心
        contentLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        if needsRelayout {
            needsRelayout = false
            rebuildLayout()
        }

        applyTransform()
    }

    // MARK: 环境明暗

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // 只关心深/浅色切换，忽略尺寸类等其它 trait 变化。
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else {
            return
        }
        appearanceDidChange?(traitCollection)
    }

    // MARK: 数据入口

    /// 设置根节点。传入任意满足 MindMapNodeType 的数据模型即可。
    public func setRoot(_ root: MindMapNodeType, animated: Bool = false) {
        self.root = root
        self.didFitOnce = false
        self.panOffset = .zero
        self.zoomScale = 1
        contentLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rebuildLayout(animated: animated)
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: 布局

    private func rebuildLayout(animated: Bool = false, anchorID: String? = nil) {
        guard let root = root else { return }

        // 展开的起点要用「旧布局」里标记的位置：t=0 时容器 bounds 还是旧尺寸，
        // 节点也还渲染在旧位置上，用新位置当起点会让新节点从节点旁边冒出来。
        let expandOrigin = markerAnchor(anchorID, in: layoutResult)

        layoutResult = engine.layout(root: root)

        contentLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        // 收起的终点用「新布局」里的位置：动画结束时节点正好在那里，
        // 子树收进去才能在视觉上精确汇入标记。
        let collapseTarget = markerAnchor(anchorID, in: layoutResult)
        // bounds（容器尺寸）由 contentLayer 在同一个动画事务内更新，
        // 保证与节点、连线的过渡时长/曲线一致，避免动画期间整图偏移。
        contentLayer.apply(layoutResult, animated: animated,
                           expandOrigin: expandOrigin, collapseTarget: collapseTarget)

        // 首次布局：整棵树自适应居中
        if !didFitOnce {
            didFitOnce = true
            fitToScreen()
        }
    }

    /// 某个节点右侧折叠标记的中心（内容坐标）。用于展开 / 收起的起点与终点：
    /// 子节点从折叠标记处展开、收起时收回折叠标记处，和连线起点在同一位置。
    private func markerAnchor(_ id: String?, in layout: MindMapLayoutResult) -> CGPoint? {
        guard let id = id, let node = layout.nodeIndex[id] else { return nil }
        return metrics.collapseMarkerCenter(forNodeFrame: node.frame, isRoot: node.isRoot)
    }

    /// 让整棵导图自适应屏幕（留出边距）。
    public func fitToScreen() {
        guard !layoutResult.contentBounds.isEmpty else { return }
        zoomScale = fitScale
        panOffset = .zero
        applyTransform(animated: true)
    }

    /// 整棵树恰好铺满屏幕（留边距）时的缩放比例，不改变当前状态。
    /// 双击的「缩回」目标就是它。
    private var fitScale: CGFloat {
        let content = layoutResult.contentBounds.size
        let available = CGSize(width: bounds.width - 48, height: bounds.height - 48)
        guard content.width > 0, content.height > 0,
              available.width > 0, available.height > 0 else { return 1 }

        let scale = min(available.width / content.width, available.height / content.height, 1.0)
        return max(minScale, min(maxScale, scale))
    }

    /// 重置视图到自适应状态。
    public func resetViewport() {
        zoomScale = 1
        panOffset = .zero
        fitToScreen()
    }

    // MARK: 变换

    private func applyTransform(animated: Bool = false) {
        let center = CGPoint(x: bounds.midX + panOffset.x, y: bounds.midY + panOffset.y)
        let transform = CGAffineTransform(translationX: center.x, y: center.y)
            .scaledBy(x: zoomScale, y: zoomScale)

        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(expandAnimationDuration)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeOut))
            contentLayer.setAffineTransform(transform)
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            contentLayer.setAffineTransform(transform)
            CATransaction.commit()
        }
    }

    /// 以 `anchor`（画布坐标）为不动点缩放到 `scale`，并同步换算平移偏移。
    ///
    /// 要求锚点下方的内容点在缩放前后屏幕位置不变。设内容点 P 满足
    /// P = (L - C) / S + M（C 为内容屏幕中心、M 为内容中心坐标、S 为缩放），
    /// 令 P 不变即得 C' = L - (L - C) * S' / S。
    ///
    /// 捏合（跟手）与双击（带过渡）共用这一份数学，交互手感一致。
    private func setZoom(_ scale: CGFloat, anchor: CGPoint, animated: Bool) {
        let target = max(minScale, min(maxScale, scale))
        guard target != zoomScale else { return }

        let ratio = target / zoomScale
        let centerX = anchor.x - (anchor.x - (bounds.midX + panOffset.x)) * ratio
        let centerY = anchor.y - (anchor.y - (bounds.midY + panOffset.y)) * ratio
        panOffset = CGPoint(x: centerX - bounds.midX, y: centerY - bounds.midY)
        zoomScale = target
        applyTransform(animated: animated)
    }

    /// 内容包围盒当前在画布上占据的矩形。
    ///
    /// 内容图层的变换是「平移到中心 + 按 S 缩放」，锚点居中，因此包围盒映射到
    /// 屏幕后仍是一个矩形：中心在内容中心、尺寸为内容尺寸 × S。
    private var contentRectOnScreen: CGRect {
        let size = layoutResult.contentBounds.size
        let scaled = CGSize(width: size.width * zoomScale, height: size.height * zoomScale)
        return CGRect(x: bounds.midX + panOffset.x - scaled.width / 2,
                      y: bounds.midY + panOffset.y - scaled.height / 2,
                      width: scaled.width,
                      height: scaled.height)
    }

    /// 把画布上的点收进「节点绘制区域」，作为缩放锚点。
    ///
    /// 屏幕空间与内容空间之间是同一组正比例的仿射映射，所以在哪一侧夹取完全等价；
    /// 这里直接在屏幕空间夹，省掉一次来回换算。
    ///
    /// 再与画布可见区域求交，锚点就一定同时是「内容上的点」和「屏幕上的点」：
    /// 缩放保持它不动，内容因此必然留在画面里，不会缩到一片空白。
    private func zoomAnchor(for point: CGPoint) -> CGPoint {
        let area = contentRectOnScreen.intersection(bounds)
        guard !area.isEmpty else { return point }
        return CGPoint(x: min(max(point.x, area.minX), area.maxX),
                       y: min(max(point.y, area.minY), area.maxY))
    }

    // MARK: 手势

    private func installGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.maximumNumberOfTouches = 1
        addGestureRecognizer(pan)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        addGestureRecognizer(pinch)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)

        // 双击画布缩放。它只在没落在节点上时才生效（见 handleDoubleTap），并且
        // 刻意不让单击去等它失败 —— 单击是展开 / 收起的主交互，保持即时响应。
        let doubleTap = UITapGestureRecognizer(target: self,
                                               action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTap)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        switch gesture.state {
        case .began, .changed:
            panOffset.x += translation.x
            panOffset.y += translation.y
            gesture.setTranslation(.zero, in: self)
            applyTransform()
        default:
            break
        }
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            // 捏合一旦被识别，中途松开一指仍会随剩下的手指继续回调 —— 那时它其实
            // 已经是单指平移了（由 pan 接管）。所以先要求双指，否则既不缩放，
            // 也不显示指示器，否则指示器会跟着那根手指到处跑。
            guard gesture.numberOfTouches >= 2 else {
                gesture.scale = 1
                zoomIndicator.dismiss()
                return
            }

            // 捏合手势的 location 就是两指中点，指示器就显示在这里。
            let anchor = gesture.location(in: self)
            let scale = zoomScale * gesture.scale
            gesture.scale = 1

            // 跟手缩放，不做过渡动画。
            setZoom(scale, anchor: anchor, animated: false)
            // 指示器始终跟随双指中点；即使已经缩放到上下限也继续跟随。
            zoomIndicator.update(scale: zoomScale, anchor: anchor)
        case .ended, .cancelled, .failed:
            zoomIndicator.dismiss()
        default:
            break
        }
    }

    /// 双击空白画布：在点击处放大 / 缩回。
    ///
    /// 落在节点或折叠标记上的双击不处理 —— 那里归单击的展开 / 收起，避免两套
    /// 行为打架。
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)
        guard hitNodeMarker(at: point) == nil, hitNode(at: point) == nil else { return }

        // 锚点收进节点绘制区域：在边缘空白处双击时，直接拿点击点当锚点会把缩放
        // 中心放到画面外，放大后只剩一片空白。
        let anchor = zoomAnchor(for: point)
        // 没放大到位就放大到双击比例，否则缩回「整棵树自适应」的比例。
        let target = zoomScale < doubleTapZoomScale ? doubleTapZoomScale : fitScale

        setZoom(target, anchor: anchor, animated: true)
        zoomIndicator.update(scale: zoomScale, anchor: anchor)
        DispatchQueue.main.asyncAfter(deadline: .now() + expandAnimationDuration) { [weak self] in
            self?.zoomIndicator.dismiss()
        }
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: self)

        // 1. 先精确命中「展开标记」
        if let node = hitNodeMarker(at: point), let model = modelNode(for: node) {
            toggle(node: model, animated: true)
            return
        }

        // 2. 命中节点主体也允许切换（单指点击不会有拖动手势冲突）
        if let node = hitNode(at: point), let model = modelNode(for: node), model.children.isEmpty == false {
            toggle(node: model, animated: true)
        }
    }

    // MARK: 展开 / 收起

    private func toggle(node: MindMapNodeType, animated: Bool) {
        guard let model = node as? MindMapNode else { return }
        model.isExpanded.toggle()
        // 以该节点为锚点：子节点从它展开 / 缩回它。
        rebuildLayout(animated: animated, anchorID: model.nodeID)
        // 立刻按新内容尺寸收敛偏移，并与布局动画同时进行。
        // 若延后到动画结束再执行，会再补一段位移，看起来是「动完又动一下」。
        clampPanOffset(animated: animated)
        onNodeToggled?(model)
    }

    /// 折叠后内容变小，若偏移过大则收敛回可视区。
    private func clampPanOffset(animated: Bool) {
        let scaled = CGSize(width: layoutResult.contentBounds.width * zoomScale,
                            height: layoutResult.contentBounds.height * zoomScale)
        let limitX = max(0, (scaled.width - bounds.width) / 2) + 80
        let limitY = max(0, (scaled.height - bounds.height) / 2) + 80
        let clamped = CGPoint(x: max(-limitX, min(limitX, panOffset.x)),
                              y: max(-limitY, min(limitY, panOffset.y)))
        guard clamped != panOffset else { return }
        panOffset = clamped
        applyTransform(animated: animated)
    }

    // MARK: 命中测试

    /// 把屏幕坐标转换到内容坐标。
    private func contentPoint(from viewPoint: CGPoint) -> CGPoint {
        let center = CGPoint(x: bounds.midX + panOffset.x, y: bounds.midY + panOffset.y)
        let dx = (viewPoint.x - center.x) / zoomScale
        let dy = (viewPoint.y - center.y) / zoomScale
        return CGPoint(x: contentLayer.bounds.midX + dx,
                       y: contentLayer.bounds.midY + dy)
    }

    private func hitNodeMarker(at viewPoint: CGPoint) -> MindMapNodeLayout? {
        let point = contentPoint(from: viewPoint)
        // 命中半径随缩放放大，保证缩小后仍易点中
        let slop = max(0, metrics.collapseMarkerSize)

        for node in layoutResult.nodes.reversed() {
            guard node.hasChildren else { continue }
            let size = metrics.collapseMarkerSize
            // 与渲染层共用同一份几何：标记在节点内容块右边缘外侧。
            let center = metrics.collapseMarkerCenter(forNodeFrame: node.frame,
                                                      isRoot: node.isRoot)
            let radius = size / 2 + slop / 2
            let dx = point.x - center.x
            let dy = point.y - center.y
            if dx * dx + dy * dy <= radius * radius { return node }
        }
        return nil
    }

    private func hitNode(at viewPoint: CGPoint) -> MindMapNodeLayout? {
        let point = contentPoint(from: viewPoint)
        return layoutResult.nodes.reversed().first { $0.frame.contains(point) }
    }

    // MARK: 模型查找

    private func modelNode(for layout: MindMapNodeLayout) -> MindMapNodeType? {
        root?.node(withID: layout.id)
    }
}

// MARK: - 主题宿主

/// 画布本身就是一个主题宿主：持有 `palette`，并在环境明暗变化时通过
/// `appearanceDidChange` 上报。主题管理器只依赖 MindMapThemeHost 协议，
/// 不需要认识这个类型；两者因此可以各自独立演进而互不影响。
extension MindMapCanvasView: MindMapThemeHost {}

// MARK: - 便捷访问

public extension MindMapCanvasView {

    /// 当前布局结果（只读），便于外部做自定义扩展。
    var currentLayout: MindMapLayoutResult { layoutResult }

    /// 当前缩放比例。
    var currentScale: CGFloat { zoomScale }
}
