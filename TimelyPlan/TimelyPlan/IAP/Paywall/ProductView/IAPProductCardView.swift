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

final class IAPProductCardView: TPBaseButton {

    // MARK: 子视图
    private let productTitleLabel = UILabel()
    private let productSubtitleLabel = UILabel()
    private let priceLabel = UILabel()
    private let discountBadge = IAPDiscountBadge()

    // MARK: 数据
    private(set) var product: IAPPaywallProduct?

    // MARK: 布局常量
    private struct Layout {
        /// 卡片固定高度
        static let height: CGFloat = 70.0
        static let padding = UIEdgeInsets(horizontal: 16.0, vertical: 8.0)
        static let cornerRadius: CGFloat = 16.0

        static let titleHeight: CGFloat = 24.0
        static let titleToSubtitle: CGFloat = 2.0
        static let subtitleHeight: CGFloat = 18.0

        static let priceHeight: CGFloat = 28.0
        /// 左右内容之间的最小间距
        static let contentGap: CGFloat = 10.0
        /// 折扣标签与标题之间的间距
        static let badgeGap: CGFloat = 6.0

        static let borderWidth: CGFloat = 1.2
    }

    // MARK: - 搭建

    override func setupContentSubviews() {
        super.setupContentSubviews()

        // 卡片外观：背景 / 圆角 / 边框交给 TPBaseButton 的背景层统一绘制
        cornerRadius = Layout.cornerRadius
        borderWidth = Layout.borderWidth
        normalBackgroundColor = IAPColor.cardBackground
        normalBorderColor = IAPColor.cardBorder
        selectedBackgroundColor = IAPColor.cardBackground
        selectedBorderColor = IAPColor.indicatorBlue
        preferredTappedScale = 0.97

        // 标题
        productTitleLabel.font = .systemFont(ofSize: 14.0, weight: .bold)
        productTitleLabel.textColor = IAPColor.titleWhite
        productTitleLabel.lineBreakMode = .byTruncatingTail
        productTitleLabel.isUserInteractionEnabled = false
        contentView.addSubview(productTitleLabel)

        // 副标题（商品描述）
        productSubtitleLabel.font = .systemFont(ofSize: 12.0, weight: .medium)
        productSubtitleLabel.textColor = IAPColor.subtitleGray
        productSubtitleLabel.numberOfLines = 1
        productSubtitleLabel.lineBreakMode = .byTruncatingTail
        productSubtitleLabel.isUserInteractionEnabled = false
        contentView.addSubview(productSubtitleLabel)

        // 价格（最右侧）
        priceLabel.font = .systemFont(ofSize: 16.0, weight: .bold)
        priceLabel.textColor = IAPColor.indicatorBlue
        priceLabel.textAlignment = .right
        priceLabel.isUserInteractionEnabled = false
        contentView.addSubview(priceLabel)

        // 折扣标签（右上角）
        discountBadge.isUserInteractionEnabled = false
        contentView.addSubview(discountBadge)
    }

    // MARK: - 选中样式

    /// 设置选中外观：仅改变边框宽度与颜色，不影响内部布局
    /// - Parameters:
    ///   - selected: 是否选中
    ///   - borderWidth: 选中时的边框宽度（比普通态更宽）
    ///   - borderColor: 选中时的边框颜色（高亮）
    func setSelectedAppearance(_ selected: Bool,
                               borderWidth: CGFloat,
                               borderColor: UIColor) {
        isSelected = selected
        self.borderWidth = selected ? borderWidth : Layout.borderWidth
        selectedBorderColor = borderColor
        setNeedsLayout()
    }

    // MARK: - 配置数据

    func configure(with product: IAPPaywallProduct) {
        self.product = product

        productTitleLabel.text = product.title
        productSubtitleLabel.text = product.subtitle
        priceLabel.text = product.priceText
        discountBadge.text = product.discountText
        setNeedsLayout()
    }

    // MARK: - 手动布局

    override func layoutSubviews() {
        super.layoutSubviews()

        let layoutFrame = bounds.inset(by: Layout.padding)
        
        // —— 最右侧：价格 ——
        let priceSize = priceLabel.sizeThatFits(
            CGSize(width: layoutFrame.width, height: .greatestFiniteMagnitude)
        )
        let priceWidth = min(ceil(priceSize.width), layoutFrame.width * 0.5)
        priceLabel.frame = CGRect(x: layoutFrame.maxX - priceWidth,
                                  y: layoutFrame.minY + (layoutFrame.height - Layout.priceHeight) / 2.0,
                                  width: priceWidth,
                                  height: Layout.priceHeight)

        // 左侧内容可用宽度（避开价格）
        let leftMaxWidth = max(0, priceLabel.frame.minX - layoutFrame.minX - Layout.contentGap)

        // —— 折扣标签尺寸 ——
        let badgeSize = discountBadge.isHidden ? CGSize.zero : discountBadge.fittingSize

        // —— 标题：按文本实际宽度布局，并为折扣标签预留空间 ——
        let badgeOccupied = badgeSize.width > 0 ? badgeSize.width + Layout.badgeGap : 0
        let titleMaxWidth = max(0, leftMaxWidth - badgeOccupied)
        let titleSize = productTitleLabel.sizeThatFits(
            CGSize(width: titleMaxWidth, height: .greatestFiniteMagnitude)
        )
        let titleWidth = min(ceil(titleSize.width), titleMaxWidth)

        let textBlockHeight = Layout.titleHeight + Layout.titleToSubtitle + Layout.subtitleHeight
        let textTop = layoutFrame.minY + (layoutFrame.height - textBlockHeight) / 2

        productTitleLabel.frame = CGRect(x: layoutFrame.minX,
                                         y: textTop,
                                         width: titleWidth,
                                         height: Layout.titleHeight)

        // —— 折扣标签：紧随标题之后，与标题垂直中心对齐 ——
        if badgeSize.width > 0 {
            discountBadge.frame = CGRect(x: productTitleLabel.frame.maxX + Layout.badgeGap,
                                         y: productTitleLabel.frame.midY - badgeSize.height / 2,
                                         width: badgeSize.width,
                                         height: badgeSize.height)
        }

        // —— 副标题（描述） ——
        productSubtitleLabel.frame = CGRect(x: layoutFrame.minX,
                                            y: productTitleLabel.frame.maxY + Layout.titleToSubtitle,
                                            width: leftMaxWidth,
                                            height: Layout.subtitleHeight)
    }

    override func contentSizeThatFits(_ size: CGSize) -> CGSize {
        // 高度固定，宽度由外部给定（选择器直接赋值 frame）
        let width = size.width.isFinite ? size.width : bounds.width
        return CGSize(width: width, height: Layout.height)
    }

    // MARK: - 固定高度
    static func desiredHeight(for product: IAPPaywallProduct) -> CGFloat {
        return Layout.height
    }
}
