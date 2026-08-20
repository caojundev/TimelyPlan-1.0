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
    private var featureRows: [FeatureRowView] = []
    private let priceLabel = UILabel()
    private let originalPriceLabel = UILabel()
    private let priceNoteLabel = UILabel()

    // MARK: 数据
    private(set) var product: IAPProduct?

    // MARK: 布局常量
    private struct Layout {
        static let padding: CGFloat = 16
        static let titleHeight: CGFloat = 28
        static let titleToFeatures: CGFloat = 14
        static let featureRowHeight: CGFloat = 22
        static let featureRowSpacing: CGFloat = 4
        static let featuresToPrice: CGFloat = 12
        static let priceHeight: CGFloat = 28
        static let secondLineHeight: CGFloat = 20
        static let priceLineSpacing: CGFloat = 4
        static let iconSize: CGFloat = 18
        static let iconToText: CGFloat = 6
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
    func configure(with product: IAPProduct) {
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

        // 重建特性行
        featureRows.forEach { $0.removeFromSuperview() }
        featureRows.removeAll()

        for feature in product.features {
            let row = FeatureRowView()
            let color = feature.highlighted ? IAPColor.indicatorBlue : IAPColor.subtitleGray

            row.iconView.tintColor = color
            switch feature.icon {
            case .checkmark:
                row.iconView.image = UIImage(systemName: "checkmark")?
                    .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
            case .family:
                row.iconView.image = UIImage(systemName: "person.2")?
                    .withConfiguration(UIImage.SymbolConfiguration(pointSize: 16, weight: .medium))
            case .custom(let img):
                row.iconView.image = img
            case .none:
                row.iconView.isHidden = true
            }

            row.label.text = feature.text
            row.label.textColor = color
            row.label.font = .systemFont(ofSize: 15, weight: feature.highlighted ? .medium : .regular)

            addSubview(row)
            featureRows.append(row)
        }

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

        // —— 中部：特性列表（从上往下） ——
        var currentY = Layout.padding + Layout.titleHeight + Layout.titleToFeatures

        for row in featureRows {
            row.frame = CGRect(x: Layout.padding, y: currentY, width: contentWidth, height: Layout.featureRowHeight)

            if !row.iconView.isHidden {
                row.iconView.frame = CGRect(x: 0, y: (Layout.featureRowHeight - Layout.iconSize) / 2,
                                            width: Layout.iconSize, height: Layout.iconSize)
                row.label.frame = CGRect(x: Layout.iconSize + Layout.iconToText, y: 0,
                                         width: contentWidth - Layout.iconSize - Layout.iconToText,
                                         height: Layout.featureRowHeight)
            } else {
                row.label.frame = CGRect(x: 0, y: 0, width: contentWidth, height: Layout.featureRowHeight)
            }

            currentY += Layout.featureRowHeight + Layout.featureRowSpacing
        }

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
    static func desiredHeight(for product: IAPProduct) -> CGFloat {
        var height: CGFloat = Layout.padding * 2  // 上下 padding
        height += Layout.titleHeight              // 标题
        height += Layout.titleToFeatures          // 标题到特性
        let count = product.features.count
        height += CGFloat(count) * Layout.featureRowHeight
        height += CGFloat(max(0, count - 1)) * Layout.featureRowSpacing
        height += Layout.featuresToPrice          // 特性到价格
        height += Layout.priceHeight              // 价格
        if product.originalPriceText != nil || product.priceNote != nil {
            height += Layout.priceLineSpacing + Layout.secondLineHeight  // 第二行
        }
        return height
    }
}

private final class FeatureRowView: UIView {
    let iconView = UIImageView()
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        iconView.contentMode = .scaleAspectFit
        addSubview(iconView)
        addSubview(label)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
