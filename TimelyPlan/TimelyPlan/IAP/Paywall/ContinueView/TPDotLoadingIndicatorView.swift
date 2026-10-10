//
//  TPDotLoadingIndicatorView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/10.
//

import Foundation
import UIKit

/// 三圆点加载指示器。
///
/// 圆点在视图中水平居中，开始动画后从左到右依次明暗闪烁（透明度变化），
/// 形成扫描式的加载效果。用法与 `UIActivityIndicatorView` 类似：
final class TPDotLoadingIndicatorView: UIView {

    // MARK: - 可配置属性

    /// 圆点数量（默认 3）
    var dotCount: Int = 3 {
        didSet {
            guard dotCount > 0, dotCount != oldValue else { return }
            rebuildDots()
        }
    }

    /// 圆点直径
    var dotSize: CGFloat = 8.0 {
        didSet {
            updateDotAppearance()
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    /// 相邻圆点的间距
    var dotSpacing: CGFloat = 6.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
        }
    }

    /// 圆点颜色
    var dotColor: UIColor = IAPColor.subtitleGray {
        didSet { updateDotAppearance() }
    }

    /// 单次「亮起」或「熄灭」的时长；一个完整脉动周期为它的两倍
    var pulseDuration: TimeInterval = 0.45

    /// 最暗状态下的透明度
    var minimumAlpha: CGFloat = 0.25

    /// 停止动画时是否自动隐藏（同 `UIActivityIndicatorView`）
    var hidesWhenStopped: Bool = true

    // MARK: - 状态

    /// 是否正在动画
    private(set) var isAnimating: Bool = false

    private var dots: [UIView] = []

    private static let pulseAnimationKey = "TPDotLoadingIndicatorView.pulse"

    // MARK: - 初始化

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
        isUserInteractionEnabled = false
        rebuildDots()
    }

    // MARK: - 圆点

    private func rebuildDots() {
        dots.forEach { $0.removeFromSuperview() }
        dots.removeAll()

        for _ in 0..<dotCount {
            let dot = UIView()
            addSubview(dot)
            dots.append(dot)
        }

        updateDotAppearance()
        if isAnimating { startAnimating() }

        invalidateIntrinsicContentSize()
        setNeedsLayout()
    }

    private func updateDotAppearance() {
        dots.forEach {
            $0.backgroundColor = dotColor
            $0.layer.cornerRadius = dotSize / 2
        }
    }

    // MARK: - 动画

    /// 开始动画。可重复调用，会以当前时刻为起点重新计算相位。
    func startAnimating() {
        guard !dots.isEmpty else { return }

        isAnimating = true
        isHidden = false

        // 相邻圆点相位依次错开 1/dotCount 个周期，形成从左到右的扫描效果
        let period = pulseDuration * 2
        let stagger = period / TimeInterval(dots.count)

        for (index, dot) in dots.enumerated() {
            // 模型值设为最暗，动画开始前保持暗态，不会出现「先全亮再跳动」
            dot.alpha = minimumAlpha
            dot.layer.removeAnimation(forKey: Self.pulseAnimationKey)

            let animation = CABasicAnimation(keyPath: "opacity")
            animation.fromValue = minimumAlpha
            animation.toValue = 1.0
            animation.duration = pulseDuration
            animation.autoreverses = true
            animation.repeatCount = .infinity
            animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            animation.beginTime = CACurrentMediaTime() + TimeInterval(index) * stagger
            dot.layer.add(animation, forKey: Self.pulseAnimationKey)
        }
    }

    /// 停止动画
    func stopAnimating() {
        isAnimating = false

        dots.forEach {
            $0.layer.removeAnimation(forKey: Self.pulseAnimationKey)
            $0.alpha = 1.0
        }

        if hidesWhenStopped { isHidden = true }
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let count = CGFloat(dots.count)
        guard count > 0 else { return }

        let totalWidth = count * dotSize + (count - 1) * dotSpacing
        var x = (bounds.width - totalWidth) / 2
        let y = (bounds.height - dotSize) / 2

        for dot in dots {
            dot.frame = CGRect(x: x, y: y, width: dotSize, height: dotSize)
            x += dotSize + dotSpacing
        }
    }

    override var intrinsicContentSize: CGSize {
        let count = CGFloat(dots.count)
        guard count > 0 else { return .zero }
        return CGSize(width: count * dotSize + (count - 1) * dotSpacing, height: dotSize)
    }

    // MARK: - 生命周期

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        // 加入视图层级后重新起动画，保证相位从当前时刻开始
        if superview != nil, isAnimating {
            startAnimating()
        }
    }
}
