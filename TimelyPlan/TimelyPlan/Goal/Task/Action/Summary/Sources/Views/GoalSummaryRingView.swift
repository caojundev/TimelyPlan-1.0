//
//  GoalSummaryRingView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/13.
//

import Foundation
import UIKit

/// 双环绘制视图（纯渲染组件）。
///
/// 只接受「几何 + 进度 + 颜色」三要素，不含任何任务语义 ——
/// 因此可以复用到任何需要多层环形的场景。
final class GoalSummaryRingView: UIView {

    /// 单层环的绘制描述。
    struct Ring {
        /// 半径（到线宽中心）。
        var radius: CGFloat
        /// 线宽。
        var lineWidth: CGFloat
        /// 进度，0...1。
        var progress: CGFloat
        /// 进度弧颜色。
        var color: UIColor

        init(radius: CGFloat,
             lineWidth: CGFloat,
             progress: CGFloat,
             color: UIColor) {
            self.radius = radius
            self.lineWidth = lineWidth
            self.progress = progress
            self.color = color
        }
    }

    // MARK: - 配置

    var theme: GoalSummaryTheme = .standard {
        didSet { applyTheme() }
    }

    var metrics: GoalSummaryRingMetrics = .regular {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    /// 环列表，第 0 个绘制在最底层。外环在前、内环在后。
    var rings: [Ring] = [] {
        didSet { rebuildLayers() }
    }

    // MARK: - 内部图层

    private var trackLayers: [CAShapeLayer] = []
    private var progressLayers: [CAShapeLayer] = []
    private var hasRevealed = false

    // MARK: - 生命周期

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .clear
        isOpaque = false
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: metrics.side, height: metrics.side)
    }

    // MARK: - 图层构建

    private func rebuildLayers() {
        (trackLayers + progressLayers).forEach { $0.removeFromSuperlayer() }
        trackLayers.removeAll()
        progressLayers.removeAll()

        for _ in rings {
            let track = CAShapeLayer()
            track.fillColor = nil
            track.lineCap = .round
            layer.addSublayer(track)
            trackLayers.append(track)

            let progress = CAShapeLayer()
            progress.fillColor = nil
            progress.lineCap = .round
            progress.strokeEnd = 0
            layer.addSublayer(progress)
            progressLayers.append(progress)
        }

        hasRevealed = false
        applyTheme()
    }

    // MARK: - 布局（手动 frame）

    override func layoutSubviews() {
        super.layoutSubviews()
        guard bounds.width > 0, bounds.height > 0 else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        for (index, ring) in rings.enumerated() where index < trackLayers.count {
            let circlePath = UIBezierPath(arcCenter: center,
                                          radius: ring.radius,
                                          startAngle: -CGFloat.pi / 2,
                                          endAngle: CGFloat.pi * 1.5,
                                          clockwise: true).cgPath

            let track = trackLayers[index]
            track.frame = bounds
            track.path = circlePath
            track.lineWidth = ring.lineWidth
            track.strokeColor = theme.track.cgColor

            let progress = progressLayers[index]
            progress.frame = bounds
            progress.path = circlePath
            progress.lineWidth = ring.lineWidth
            progress.strokeColor = ring.color.cgColor
            progress.strokeEnd = ring.progress
            progress.isHidden = ring.progress <= 0
        }

        revealIfNeeded()
    }

    // MARK: - 出场动效

    private func revealIfNeeded() {
        guard !hasRevealed, !rings.isEmpty else { return }
        hasRevealed = true

        for (index, ring) in rings.enumerated() where index < progressLayers.count {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = ring.progress
            animation.duration = 0.9
            animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            progressLayers[index].add(animation, forKey: "reveal")
        }
    }

    // MARK: - 外观

    private func applyTheme() {
        trackLayers.forEach { $0.strokeColor = theme.track.cgColor }
        setNeedsLayout()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        applyTheme()
    }
}
