//
//  MindMapZoomIndicatorView.swift
//  MindMapKit
//
//  缩放百分比指示器：一个圆角矩形，显示当前缩放比例。
//
//  ── 定位：与画布、手势完全解耦的独立组件 ────────────────────────────
//
//  它只知道两件事：当前缩放比例、以及自己要居中到父视图的哪个点。
//  尺寸、样式、显隐动画都由它自己负责，不引用任何思维导图类型，
//  因此任何需要提示缩放的地方都能直接复用：
//
//      let indicator = MindMapZoomIndicatorView()
//      host.addSubview(indicator)
//      indicator.update(scale: 1.5, anchor: point)   // point 在 host 坐标系；会显示并跟随
//      indicator.dismiss()                           // 淡出
//
//  换风格只需换一个 MindMapZoomIndicatorStyle。
//

import UIKit

// MARK: - 样式

/// 缩放指示器的外观与位置参数。
public struct MindMapZoomIndicatorStyle {

    public var background: UIColor
    public var textColor: UIColor
    public var borderColor: UIColor
    public var borderWidth: CGFloat
    public var cornerRadius: CGFloat
    /// 文本与圆角矩形边缘之间的内边距。
    public var textInsets: UIEdgeInsets
    public var font: UIFont
    /// 相对锚点的偏移，默认正好居中在锚点上。
    public var anchorOffset: CGPoint
    /// 淡入 / 淡出时长。
    public var fadeDuration: TimeInterval

    public init(background: UIColor = UIColor(white: 0.06, alpha: 0.78),
                textColor: UIColor = .white,
                borderColor: UIColor = UIColor(white: 1, alpha: 0.18),
                borderWidth: CGFloat = 1,
                cornerRadius: CGFloat = 10,
                textInsets: UIEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12),
                font: UIFont = .systemFont(ofSize: 15, weight: .semibold),
                anchorOffset: CGPoint = .zero,
                fadeDuration: TimeInterval = 0.15) {
        self.background = background
        self.textColor = textColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.textInsets = textInsets
        self.font = font
        self.anchorOffset = anchorOffset
        self.fadeDuration = fadeDuration
    }
}

// MARK: - 指示器

public final class MindMapZoomIndicatorView: UIView {

    /// 外观参数，运行时替换立即生效。
    public var style: MindMapZoomIndicatorStyle {
        didSet {
            applyStyle()
            layoutForCurrentText()
        }
    }

    private let textLabel = UILabel()

    public init(style: MindMapZoomIndicatorStyle = MindMapZoomIndicatorStyle()) {
        self.style = style
        super.init(frame: .zero)

        // 纯展示，不参与命中测试 —— 盖在画布上也不能挡住手势。
        isUserInteractionEnabled = false
        clipsToBounds = true

        textLabel.textAlignment = .center
        addSubview(textLabel)

        applyStyle()
        alpha = 0
        isHidden = true
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: 对外接口

    /// 显示（尚未显示时淡入）并更新到新的缩放比例与锚点。
    ///
    /// 可以连续调用：位置与文本直接追随，不产生额外动画，适合跟手。
    ///
    /// - Parameters:
    ///   - scale: 当前缩放比例，1 表示 100%。
    ///   - anchor: 锚点在**父视图坐标系**中的位置；指示器居中到该点，再叠加
    ///     `style.anchorOffset`。
    public func update(scale: CGFloat, anchor: CGPoint) {
        textLabel.text = Self.percentText(for: scale)
        layoutForCurrentText()
        center = CGPoint(x: anchor.x + style.anchorOffset.x,
                         y: anchor.y + style.anchorOffset.y)

        isHidden = false
        guard alpha < 1 else { return }
        UIView.animate(withDuration: style.fadeDuration,
                       delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction],
                       animations: { self.alpha = 1 },
                       completion: nil)
    }

    /// 淡出隐藏。
    public func dismiss(animated: Bool = true) {
        guard !isHidden else { return }
        guard animated, style.fadeDuration > 0 else {
            alpha = 0
            isHidden = true
            return
        }
        UIView.animate(withDuration: style.fadeDuration,
                       delay: 0,
                       options: [.beginFromCurrentState, .allowUserInteraction],
                       animations: { self.alpha = 0 }) { [weak self] _ in
            // 淡出过程中可能又被 update 唤起（此刻 alpha 已被置回 1），此时不要隐藏。
            guard let self = self, self.alpha < 0.01 else { return }
            self.isHidden = true
        }
    }

    /// 百分比文本。抽成静态方法，方便其它地方沿用同一格式。
    public static func percentText(for scale: CGFloat) -> String {
        "\(Int((scale * 100).rounded()))%"
    }

    // MARK: 内部

    private func applyStyle() {
        backgroundColor = style.background
        layer.cornerRadius = style.cornerRadius
        layer.borderWidth = style.borderWidth
        layer.borderColor = style.borderColor.cgColor
        textLabel.font = style.font
        textLabel.textColor = style.textColor
    }

    /// 按当前文本重算尺寸。只改 bounds，不改 center，因此缩放百分比位数变化
    /// （99% → 100%）时视觉中心保持不动。
    private func layoutForCurrentText() {
        let limit = CGSize(width: CGFloat.greatestFiniteMagnitude,
                           height: CGFloat.greatestFiniteMagnitude)
        let textSize = textLabel.sizeThatFits(limit)
        let insets = style.textInsets
        bounds = CGRect(x: 0, y: 0,
                        width: ceil(textSize.width) + insets.left + insets.right,
                        height: ceil(textSize.height) + insets.top + insets.bottom)
        textLabel.frame = bounds.inset(by: insets)
    }
}
