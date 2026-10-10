//
//  IAPProductCardView.swift
//  TimelyPlan
//
//  单个商品卡片
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit

final class IAPProductCardView: UIControl {

    // MARK: 子视图
    private let titleLabel = UILabel()
    private let discountBadge = IAPDiscountBadge()
    /// 一行特性文案
    private let featureLabel = UILabel()
    private let priceLabel = UILabel()
    private let originalPriceLabel = UILabel()
    private let priceNoteLabel = UILabel()

    // MARK: 数据
    private(set) var product: IAPPaywallProduct?

    // MARK: 布局常量
    private struct Layout {
        static let padding: CGFloat = 12.0
        static let titleHeight: CGFloat = 28
        static let titleToFeatures: CGFloat = 4.0
        static let featureRowHeight: CGFloat = 36.0
        static let featuresToPrice: CGFloat = 8.0
        static let priceHeight: CGFloat = 28
        static let secondLineHeight: CGFloat = 20
        static let priceLineSpacing: CGFloat = 4
        static let cornerRadius: CGFloat = 16
        static let borderWidth: CGFloat = 1
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        backgroundColor = IAPColor.cardBackground
        layer.borderColor = IAPColor.cardBorder.cgColor
        layer.borderWidth = Layout.borderWidth
        layer.cornerRadius = Layout.cornerRadius

        titleLabel.font = .systemFont(ofSize: 22, weight: .semibold)
        titleLabel.textColor = IAPColor.titleWhite
        titleLabel.isUserInteractionEnabled = false
        addSubview(titleLabel)

        discountBadge.isUserInteractionEnabled = false
        addSubview(discountBadge)

        featureLabel.font = .systemFont(ofSize: 13, weight: .medium)
        featureLabel.numberOfLines = 2
        featureLabel.isUserInteractionEnabled = false
        addSubview(featureLabel)

        priceLabel.font = .systemFont(ofSize: 24, weight: .bold)
        priceLabel.textColor = IAPColor.indicatorBlue
        priceLabel.isUserInteractionEnabled = false
        addSubview(priceLabel)

        originalPriceLabel.font = .systemFont(ofSize: 15)
        originalPriceLabel.isUserInteractionEnabled = false
        addSubview(originalPriceLabel)

        priceNoteLabel.font = .systemFont(ofSize: 15)
        priceNoteLabel.isUserInteractionEnabled = false
        priceNoteLabel.textColor = IAPColor.subtitleGray
        addSubview(priceNoteLabel)
    }

    // MARK: 配置数据
    func configure(with product: IAPPaywallProduct) {
        self.product = product

        titleLabel.text = product.title
        discountBadge.text = product.discountText
        priceLabel.text = product.priceText

        // 原价带删除线
        if let orig = product.originalPriceText {
            let attr = NSAttributedString(
                string: orig,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: IAPColor.subtitleGray,
                    .foregroundColor: IAPColor.subtitleGray
                ]
            )
            originalPriceLabel.attributedText = attr
            originalPriceLabel.isHidden = false
        } else {
            originalPriceLabel.attributedText = nil
            originalPriceLabel.isHidden = true
        }

        priceNoteLabel.text = product.priceNote
        priceNoteLabel.isHidden = product.priceNote == nil

        // 配置特性文案
        let feature = product.feature
        featureLabel.text = feature.text
        featureLabel.textColor = feature.highlighted ? IAPColor.indicatorBlue : IAPColor.subtitleGray

        setNeedsLayout()
    }

    // MARK: 手动布局
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let contentWidth = bounds.width - Layout.padding * 2

        // —— 顶部：标题 + 折扣标签 ——
        titleLabel.frame = CGRect(x: Layout.padding, y: Layout.padding, width: contentWidth, height: Layout.titleHeight)

        if !discountBadge.isHidden {
            let badgeSize = discountBadge.fittingSize
            let badgeX = bounds.width - Layout.padding - badgeSize.width
            let badgeY = Layout.padding + (Layout.titleHeight - badgeSize.height) / 2
            discountBadge.frame = CGRect(origin: CGPoint(x: badgeX, y: badgeY), size: badgeSize)
        }

        // —— 中部：特性文案（一行） ——
        let featureY = Layout.padding + Layout.titleHeight + Layout.titleToFeatures
        featureLabel.frame = CGRect(x: Layout.padding, y: featureY,
                                    width: contentWidth, height: Layout.featureRowHeight)

        // —— 底部：价格区（从底往上对齐） ——
        var priceAreaHeight = Layout.priceHeight
        let hasSecondLine = !originalPriceLabel.isHidden || !priceNoteLabel.isHidden
        if hasSecondLine {
            priceAreaHeight += Layout.priceLineSpacing + Layout.secondLineHeight
        }

        let priceAreaY = bounds.height - Layout.padding - priceAreaHeight

        priceLabel.frame = CGRect(x: Layout.padding, y: priceAreaY, width: contentWidth, height: Layout.priceHeight)

        let secondY = priceAreaY + Layout.priceHeight + Layout.priceLineSpacing
        if !originalPriceLabel.isHidden {
            originalPriceLabel.frame = CGRect(x: Layout.padding, y: secondY, width: contentWidth, height: Layout.secondLineHeight)
        }
        if !priceNoteLabel.isHidden {
            priceNoteLabel.frame = CGRect(x: Layout.padding, y: secondY, width: contentWidth, height: Layout.secondLineHeight)
        }
    }

    // MARK: 点击缩放动画
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12, delay: 0,
                           options: [.allowUserInteraction, .curveEaseOut]) {
                self.transform = self.isHighlighted
                    ? CGAffineTransform(scaleX: 0.96, y: 0.96)
                    : .identity
            }
        }
    }

    // MARK: 计算卡片所需高度
    /// 所有卡片高度一致（只展示一行特性），`product` 参数保留以便后续按商品差异化
    static func desiredHeight(for product: IAPPaywallProduct) -> CGFloat {
        var height: CGFloat = Layout.padding * 2  // 上下 padding
        height += Layout.titleHeight              // 标题
        height += Layout.titleToFeatures          // 标题到特性
        height += Layout.featureRowHeight         // 一行特性
        height += Layout.featuresToPrice          // 特性到价格
        height += Layout.priceHeight              // 价格
        if product.originalPriceText != nil || product.priceNote != nil {
            height += Layout.priceLineSpacing + Layout.secondLineHeight  // 第二行
        }
        return height
    }
}
