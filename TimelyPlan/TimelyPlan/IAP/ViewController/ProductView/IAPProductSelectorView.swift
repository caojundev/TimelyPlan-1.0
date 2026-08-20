//
//  IAPProductSelectorView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit

final class IAPProductSelectorView: UIView {

    static let contentPadding = UIEdgeInsets(value: 4.0)
    
    // MARK: 可配置属性
    /// 商品卡片最小宽度；等宽分配不足时启用横向滚动
    var minItemWidth: CGFloat = 240 {
        didSet { setNeedsLayout() }
    }
    var interItemSpacing: CGFloat = 12 {
        didSet { setNeedsLayout() }
    }
    var cardCornerRadius: CGFloat = 16 {
        didSet { indicatorView.layer.cornerRadius = cardCornerRadius; setNeedsLayout() }
    }
    var indicatorBorderWidth: CGFloat = 2.5 {
        didSet { indicatorView.layer.borderWidth = indicatorBorderWidth; setNeedsLayout() }
    }
    var indicatorColor: UIColor = IAPColor.indicatorBlue {
        didSet { indicatorView.layer.borderColor = indicatorColor.cgColor }
    }
    var animationDuration: TimeInterval = 0.35
    /// 是否显示横向滚动指示器
    var showsHorizontalScrollIndicator: Bool = false {
        didSet { scrollView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator }
    }

    // MARK: 回调
    /// 选中商品变更时回调（index, 商品配置）
    var onProductSelected: ((Int, IAPProduct) -> Void)?
    
    // MARK: 私有
    private(set) var products: [IAPProduct] = []
    private var cardViews: [IAPProductCardView] = []
    private let scrollView = UIScrollView()
    private let contentView = UIView()   // scrollView 的内容容器，卡片和指示器都在里面
    private let indicatorView = UIView()
    private(set) var selectedIndex: Int = 0

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupIndicator()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.bounces = true
        addSubview(scrollView)
        scrollView.addSubview(contentView)
    }

    private func setupIndicator() {
        indicatorView.isUserInteractionEnabled = false
        indicatorView.backgroundColor = .clear
        indicatorView.layer.borderColor = indicatorColor.cgColor
        indicatorView.layer.borderWidth = indicatorBorderWidth
        indicatorView.layer.cornerRadius = cardCornerRadius
        indicatorView.isUserInteractionEnabled = false
        contentView.addSubview(indicatorView)
    }

    // MARK: 配置入口 —— 传入商品数组自动创建布局
    func configure(products: [IAPProduct], defaultSelectedIndex: Int = 0) {
        guard !products.isEmpty else { return }

        self.products = products
        self.selectedIndex = min(max(0, defaultSelectedIndex), products.count - 1)

        // 清理旧卡片
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()

        // 创建新卡片，放入 contentView
        for (index, product) in products.enumerated() {
            let card = IAPProductCardView()
            card.configure(with: product)
            card.tag = index
            card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
            contentView.addSubview(card)
            cardViews.append(card)
        }

        // 指示器保持在最上层
        contentView.bringSubviewToFront(indicatorView)

        setNeedsLayout()
    }

    // MARK: 编程式选中
    func selectProduct(at index: Int, animated: Bool) {
        guard index >= 0, index < products.count else { return }
        selectedIndex = index
        updateIndicatorFrame(animated: animated)
        scrollCardToVisible(index: index, animated: animated)
        onProductSelected?(index, products[index])
    }

    @objc private func cardTapped(_ sender: IAPProductCardView) {
        selectProduct(at: sender.tag, animated: true)
    }

    private func updateIndicatorFrame(animated: Bool) {
        let card = cardViews[selectedIndex]
        // 指示器比卡片略大一圈，边框完全在卡片外侧
        let frame = card.frame.insetBy(dx: -indicatorBorderWidth, dy: -indicatorBorderWidth)

        if animated {
            UIView.animate(withDuration: animationDuration,
                           delay: 0,
                           usingSpringWithDamping: 0.78,
                           initialSpringVelocity: 0.4,
                           options: [.curveEaseInOut, .allowUserInteraction]) {
                self.indicatorView.frame = frame
            }
        } else {
            indicatorView.frame = frame
        }
    }

    /// 选中卡片不在可视区域时，自动滚动使其完整可见
    private func scrollCardToVisible(index: Int, animated: Bool) {
        let cardFrame = cardViews[index].frame
        scrollView.scrollRectToVisibleCenter(cardFrame, animated: animated)
    }

    // MARK: 手动布局
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !cardViews.isEmpty else { return }

        scrollView.frame = bounds
        let count = cardViews.count
        
        let contentPadding = Self.contentPadding
        
        // 1. 先按等宽分配计算
        let equalWidth = (bounds.width - contentPadding.horizontalLength - interItemSpacing * CGFloat(count - 1)) / CGFloat(count)
        // 2. 不满足最小宽度则用最小宽度，此时 contentWidth > bounds.width，启用横向滚动
        let cardWidth = max(equalWidth, minItemWidth)
        let contentWidth = contentPadding.horizontalLength + cardWidth * CGFloat(count) + interItemSpacing * CGFloat(count - 1)
        scrollView.contentSize = CGSize(width: contentWidth, height: bounds.height)
        contentView.frame = CGRect(x: 0,
                                   y: 0,
                                   width: contentWidth,
                                   height: bounds.height)
        
        for (index, card) in cardViews.enumerated() {
            let x = contentPadding.left + CGFloat(index) * (cardWidth + interItemSpacing)
            card.frame = CGRect(x: x,
                                y: contentPadding.top,
                                width: cardWidth,
                                height: bounds.height - contentPadding.verticalLength)
        }

        // 布局阶段直接设置指示器，无动画
        updateIndicatorFrame(animated: false)
    }

    func recommendedHeight() -> CGFloat {
        return Self.recommendedHeight(for: products)
    }
    
    // MARK: 计算推荐高度（取所有卡片中最高的）
    static func recommendedHeight(for products: [IAPProduct]) -> CGFloat {
        guard !products.isEmpty else { return 0 }
        return products.map { IAPProductCardView.desiredHeight(for: $0) + contentPadding.verticalLength }.max() ?? 0
    }
}

// MARK: - ========== 7. 测试数据 ==========

enum IAPTestData {

    /// 和设计图一致的 3 个商品
    static let standardProducts: [IAPProduct] = [
        IAPProduct(
            id: "annual.subscription",
            title: "Annual",
            discountText: "23% OFF",
            features: [
                IAPFeature(icon: .checkmark, text: "7-Days Free Trial", highlighted: true),
                IAPFeature(icon: .family, text: "Support family sharing", highlighted: false)
            ],
            priceText: "¥98/yr",
            originalPriceText: "Original ¥128/yr",
            priceNote: nil
        ),
        IAPProduct(
            id: "monthly.subscription",
            title: "Monthly",
            discountText: nil,
            features: [
                IAPFeature(icon: .family, text: "Support family sharing", highlighted: false)
            ],
            priceText: "¥16/mo",
            originalPriceText: nil,
            priceNote: "Billed monthly"
        ),
        IAPProduct(
            id: "lifetime.purchase",
            title: "Lifetime",
            discountText: "43% OFF",
            features: [
                IAPFeature(icon: .none, text: "One-time purchase, no subscription", highlighted: false)
            ],
            priceText: "¥168",
            originalPriceText: "Original ¥298",
            priceNote: nil
        )
    ]

    /// 2 个商品的测试数据
    static let twoProducts: [IAPProduct] = [
        IAPProduct(
            id: "pro.monthly",
            title: "Monthly",
            discountText: nil,
            features: [
                IAPFeature(icon: .checkmark, text: "All features unlocked", highlighted: true)
            ],
            priceText: "¥12/mo",
            originalPriceText: nil,
            priceNote: "Billed monthly"
        ),
        IAPProduct(
            id: "pro.yearly",
            title: "Yearly",
            discountText: "40% OFF",
            features: [
                IAPFeature(icon: .checkmark, text: "All features unlocked", highlighted: true),
                IAPFeature(icon: .checkmark, text: "3-Days Free Trial", highlighted: true)
            ],
            priceText: "¥88/yr",
            originalPriceText: "Original ¥144/yr",
            priceNote: nil
        )
    ]

    /// 4 个商品的测试数据
    static let fourProducts: [IAPProduct] = [
        IAPProduct(id: "p1", title: "Weekly", discountText: nil,
                   features: [IAPFeature(icon: .checkmark, text: "Basic access", highlighted: false)],
                   priceText: "¥5/wk", originalPriceText: nil, priceNote: "Billed weekly"),
        IAPProduct(id: "p2", title: "Monthly", discountText: "10% OFF",
                   features: [IAPFeature(icon: .checkmark, text: "All features", highlighted: true)],
                   priceText: "¥18/mo", originalPriceText: "Original ¥20/mo", priceNote: nil),
        IAPProduct(id: "p3", title: "Quarterly", discountText: "25% OFF",
                   features: [IAPFeature(icon: .checkmark, text: "All features", highlighted: true),
                              IAPFeature(icon: .family, text: "Family sharing", highlighted: false)],
                   priceText: "¥45/3mo", originalPriceText: "Original ¥60/3mo", priceNote: nil),
        IAPProduct(id: "p4", title: "Lifetime", discountText: "50% OFF",
                   features: [IAPFeature(icon: .none, text: "Pay once, own forever", highlighted: true)],
                   priceText: "¥199", originalPriceText: "Original ¥398", priceNote: nil)
    ]
}
