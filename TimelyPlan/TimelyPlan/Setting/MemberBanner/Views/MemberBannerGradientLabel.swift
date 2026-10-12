//
//  MemberBannerGradientLabel.swift
//  MemberBanner
//
//  金色渐变文字 Label。用于「尊享会员 · 年度」这类需要金属质感的标题。
//
//  实现思路（可靠且简单）：
//  用一个容器 UIView 承载渐变层，再把「只渲染文字」的 UILabel 作为容器层的 mask。
//  这样渐变就精确地只出现在文字笔画上，且不依赖 drawRect 重绘。
//
//  用法：把它当普通 UIView 使用，通过 `text` / `font` 驱动内容，
//  布局时给它一个 frame 即可（内部 label 自适应撑满）。
//

import UIKit

final class MemberBannerGradientLabel: UIView {

    // MARK: - 对外属性

    /// 显示文字
    var text: String? {
        didSet {
            textLabel.text = text
            invalidateIntrinsicContentSize()
        }
    }

    /// 字体
    var font: UIFont {
        didSet {
            textLabel.font = font
            invalidateIntrinsicContentSize()
        }
    }

    /// 渐变颜色（起点 → 终点）
    var gradientColors: [UIColor] {
        didSet { gradientLayer.colors = gradientColors.map { $0.cgColor } }
    }

    var textAlignment: NSTextAlignment = .left {
        didSet { textLabel.textAlignment = textAlignment }
    }

    // MARK: - 私有

    private let gradientLayer = CAGradientLayer()
    private let textLabel = UILabel()
    /// 缓存一个可复用的「文字遮罩层」，避免每次 layout 新建图层
    private let maskLayer = CALayer()

    // MARK: - Init

    init(colors: [UIColor] = [MemberBannerTheme.Color.cardTitle, MemberBannerTheme.Color.cardTitleEnd]) {
        self.gradientColors = colors
        self.font = MemberBannerTheme.Font.serif(17)
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setup() {
        backgroundColor = .clear
        isUserInteractionEnabled = false

        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)   // 从左到右的金属渐变
        gradientLayer.endPoint   = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = gradientColors.map { $0.cgColor }
        layer.addSublayer(gradientLayer)

        // 文字驱动层：负责渲染笔画，本身不直接显示，仅作为遮罩
        textLabel.font = font
        textLabel.textColor = .black
        textLabel.numberOfLines = 1
        textLabel.textAlignment = textAlignment
        // 作为 mask 的内容，需要把它做成一张位图 —— 由 maskLayer 承载
    }

    // MARK: - 布局

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds

        // 让文字层按自身尺寸渲染，再把它绘制进 maskLayer
        textLabel.frame = bounds
        maskLayer.frame = bounds
        maskLayer.contents = renderTextImage()?.cgImage
        maskLayer.contentsScale = UIScreen.main.scale
        maskLayer.contentsGravity = .center
        gradientLayer.mask = maskLayer
    }

    override var intrinsicContentSize: CGSize {
        textLabel.sizeThatFits(.unlimited)
    }

    /// 把当前文字渲染成一张透明位图，供遮罩使用。
    private func renderTextImage() -> UIImage? {
        guard bounds.width > 0, bounds.height > 0, let text = self.text, !text.isEmpty else { return nil }
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        return renderer.image { _ in
            (text as NSString).draw(
                in: bounds,
                withAttributes: [
                    .font: font,
                    .foregroundColor: UIColor.black
                ]
            )
        }
    }

    // MARK: - 便捷构造

    @discardableResult
    func configure(text: String?, font: UIFont) -> Self {
        self.font = font
        self.text = text
        return self
    }
}
