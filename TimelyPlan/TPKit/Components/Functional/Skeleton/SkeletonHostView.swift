//
//  SkeletonHostView.swift
//  Skeleton
//
//  骨架视图本体：覆盖在目标视图上，内部只有两层：
//    fillLayer  —— CAGradientLayer，负责底色/高光
//    shapeLayer —— CAShapeLayer，作为 fillLayer 的 mask，承载所有占位块合成的一条 path
//
//  所以无论页面上有多少个占位块，最终只多出一个 UIView、两个 CALayer。
//
//  为什么用 autoresizingMask 而不是 Auto Layout 约束：
//  约束挂在 UIScrollView 的子视图上会参与 contentSize 计算，一旦骨架打在 tableView /
//  scrollView 上就会干扰滚动；autoresizing 只跟 frame 走，没有副作用。
//  尺寸同步由 syncFrame() + layoutSubviews hook 兜底，初始 0 尺寸的情况也能覆盖。
//

import UIKit

public final class SkeletonHostView: UIView {

    private(set) weak var target: UIView?
    private(set) var config: SkeletonConfig

    private let fillLayer = CAGradientLayer()
    private let shapeLayer = CAShapeLayer()

    /// 被标记为“待重算”，用于去重 setNeedsLayout，避免一轮布局里反复触发
    private var needsRebuild = true
    private var isBuilding = false
    private var reduceMotionObserver: NSObjectProtocol?

    // MARK: - 生命周期

    init(target: UIView, config: SkeletonConfig) {
        self.target = target
        self.config = config
        super.init(frame: CGRect(origin: .zero, size: target.bounds.size))

        backgroundColor = .clear
        isOpaque = false
        clipsToBounds = true
        isUserInteractionEnabled = config.blocksUserInteraction
        autoresizingMask = [.flexibleWidth, .flexibleHeight]

        shapeLayer.fillColor = UIColor.black.cgColor
        fillLayer.mask = shapeLayer
        layer.addSublayer(fillLayer)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let observer = reduceMotionObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: - 安装 / 卸载

    /// 挂到目标视图上（由 `view.sk.show()` 调用）
    func install() {
        guard let target = target else { return }

        if let stackView = target as? UIStackView {
            // UIStackView 的 addSubview 会顺带进入 arrangedSubviews，这里立刻摘出来，
            // 让它退化成普通子视图，不参与堆栈布局
            stackView.addSubview(self)
            stackView.removeArrangedSubview(self)
        } else {
            target.addSubview(self)
        }

        syncFrame()

        SkeletonLayoutMonitor.register(self)

        reduceMotionObserver = NotificationCenter.default.addObserver(
            forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyAppearance()
        }

        applyAppearance()
        refresh()
    }

    func remove() {
        SkeletonLayoutMonitor.unregister(self)
        if let target = target, target.skHost === self {
            target.skHost = nil
        }
        removeFromSuperview()
    }

    func update(config: SkeletonConfig) {
        self.config = config
        isUserInteractionEnabled = config.blocksUserInteraction
        applyAppearance()
        needsRebuild = true
        setNeedsLayout()
    }

    // MARK: - 刷新

    /// 强制重算占位块，并保证自己在最上层
    public func refresh() {
        Skeleton.assertMainThread()
        syncFrame()
        if let superview = superview, superview.subviews.last !== self {
            superview.bringSubviewToFront(self)
        }
        needsRebuild = true
        rebuild()
    }

    /// 布局期间被 SkeletonLayoutMonitor 标记为脏；去重后交给本轮布局消化
    func setNeedsRebuild() {
        // 目标视图在这轮布局里可能刚好从 0 尺寸变成真实尺寸，这里兜底同步一次 frame
        syncFrame()
        guard !needsRebuild else { return }
        needsRebuild = true
        setNeedsLayout()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        rebuild()
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard window != nil else { return }
        syncFrame()
        needsRebuild = true
        setNeedsLayout()
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        applyAppearance()
    }

    // MARK: - 绘制

    /// 保持和 target 的 frame 一致。
    /// - 普通视图：等价于 bounds（origin 为 0），autoresizing 已经处理，这里是兜底；
    /// - scrollView：bounds.origin 会随滚动变化，同步后骨架贴合可视区域而不是被内容带走；
    /// - 初始 0 尺寸：目标拿到真实尺寸后，这里把 frame 补上。
    private func syncFrame() {
        guard let target = target, superview === target else { return }
        let expected = target.bounds
        guard frame != expected else { return }
        frame = expected
    }

    private func rebuild() {
        guard !isBuilding,
              let target = target,
              bounds.width > 0,
              bounds.height > 0 else { return }

        isBuilding = true
        defer { isBuilding = false }
        needsRebuild = false

        let placeholders = SkeletonBuilder.build(root: target, config: config)

        let path = UIBezierPath()
        for placeholder in placeholders {
            // root 坐标系 -> 骨架自身坐标系
            let rect = convert(placeholder.frame, from: target).standardized
            guard rect.width > 0.5, rect.height > 0.5 else { continue }
            let radius = min(placeholder.cornerRadius, min(rect.width, rect.height) / 2)
            path.append(UIBezierPath(roundedRect: rect, cornerRadius: radius))
        }

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        fillLayer.frame = bounds
        shapeLayer.frame = bounds
        shapeLayer.path = path.isEmpty ? nil : path.cgPath
        fillLayer.isHidden = path.isEmpty
        CATransaction.commit()
    }

    private func applyAppearance() {
        let animation: SkeletonConfig.Animation
        if config.respectsReduceMotion, UIAccessibility.isReduceMotionEnabled {
            animation = .none
        } else {
            animation = config.animation
        }
        SkeletonAnimator.apply(to: fillLayer,
                               config: config,
                               animation: animation,
                               traits: traitCollection)
    }
}
