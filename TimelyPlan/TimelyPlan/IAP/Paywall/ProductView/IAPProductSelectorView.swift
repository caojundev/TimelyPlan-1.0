//
//  IAPProductSelectorView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit

/// 商品选择器：垂直排列商品卡片（类似 tableView 的 cell），
/// 选中时仅改变选中卡片的边框样式（加粗 + 高亮）。
///
/// 内部自带加载态：加载中不展示任何卡片，只在控件中展示加载指示器，
/// 此时 `recommendedHeight()` 返回 `loadingHeight`（40）。
final class IAPProductSelectorView: UIView {

    static let contentPadding = UIEdgeInsets(value: 4.0)
    /// 加载态下控件的高度
    static let loadingHeight: CGFloat = 20.0
    
    // MARK: 可配置属性
    /// 卡片之间的垂直间距
    var interItemSpacing: CGFloat = 12 {
        didSet { setNeedsLayout() }
    }
    /// 选中卡片的边框宽度（比默认边框更宽）
    var selectedBorderWidth: CGFloat = 2.0 {
        didSet { updateSelection() }
    }
    /// 选中卡片的边框颜色（高亮）
    var selectedBorderColor: UIColor = IAPColor.indicatorBlue {
        didSet { updateSelection() }
    }
    /// 选中切换动画时长
    var animationDuration: TimeInterval = 0.2

    // MARK: 回调
    /// 选中商品变更时回调（index, 商品配置）
    var onProductSelected: ((Int, IAPPaywallProduct) -> Void)?
    
    // MARK: 私有
    private(set) var products: [IAPPaywallProduct] = []
    private var cardViews: [IAPProductCardView] = []
    private(set) var selectedIndex: Int = 0
    /// 是否处于加载态
    private(set) var isLoading: Bool = true

    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        // 卡片裁剪在自身范围内，避免任何溢出内容遮挡下方视图
        clipsToBounds = true
        setupLoadingIndicator()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = IAPColor.subtitleGray
        addSubview(loadingIndicator)
        // 默认进入加载态（外部拿到数据后调用 configure 结束加载）
        setLoading(true)
    }

    // MARK: - 加载态

    /// 切换加载态
    /// - 进入加载：移除全部卡片，仅展示加载指示器
    /// - 退出加载：移除加载指示器
    func setLoading(_ loading: Bool) {
        isLoading = loading
        if loading {
            removeAllCards()
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.stopAnimating()
        }
        setNeedsLayout()
    }

    private func removeAllCards() {
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()
        products.removeAll()
        selectedIndex = 0
    }

    // MARK: 配置入口 —— 传入商品数组自动创建卡片（并结束加载态）
    func configure(products: [IAPPaywallProduct], defaultSelectedIndex: Int = 0) {
        guard !products.isEmpty else { return }

        setLoading(false)

        self.products = products
        self.selectedIndex = min(max(0, defaultSelectedIndex), products.count - 1)

        // 清理旧卡片
        cardViews.forEach { $0.removeFromSuperview() }
        cardViews.removeAll()

        // 创建新卡片，纵向依次添加
        for (index, product) in products.enumerated() {
            let card = IAPProductCardView()
            card.configure(with: product)
            card.tag = index
            card.addTarget(self, action: #selector(cardTapped(_:)), for: .touchUpInside)
            addSubview(card)
            cardViews.append(card)
        }

        updateSelection()
        setNeedsLayout()
    }

    // MARK: 编程式选中
    func selectProduct(at index: Int) {
        guard index >= 0, index < products.count else { return }
        selectedIndex = index
        updateSelection()
        onProductSelected?(index, products[index])
    }

    @objc private func cardTapped(_ sender: IAPProductCardView) {
        selectProduct(at: sender.tag)
    }

    /// 刷新所有卡片的选中样式
    private func updateSelection() {
        for (index, card) in cardViews.enumerated() {
            card.setSelectedAppearance(
                index == selectedIndex,
                borderWidth: selectedBorderWidth,
                borderColor: selectedBorderColor
            )
        }
    }

    // MARK: 手动布局
    override func layoutSubviews() {
        super.layoutSubviews()

        // 加载指示器居中（加载态高度由外部按 recommendedHeight 给出）
        loadingIndicator.center = CGPoint(x: bounds.midX, y: bounds.midY)

        // 加载态下只展示指示器，无卡片
        guard !isLoading, !cardViews.isEmpty else { return }

        let padding = Self.contentPadding
        let cardWidth = bounds.width - padding.horizontalLength
        var y = padding.top

        for (index, card) in cardViews.enumerated() {
            let cardHeight = IAPProductCardView.desiredHeight(for: products[index])
            card.frame = CGRect(x: padding.left, y: y, width: cardWidth, height: cardHeight)
            y = card.frame.maxY
            if index != cardViews.count - 1 {
                y += interItemSpacing
            }
        }
    }

    // MARK: 推荐高度
    /// 加载态返回固定高度，加载完成后返回全部商品内容高度
    func recommendedHeight() -> CGFloat {
        guard !isLoading else { return Self.loadingHeight }
        return Self.recommendedHeight(for: products, interItemSpacing: interItemSpacing)
    }
    
    static func recommendedHeight(for products: [IAPPaywallProduct],
                                  interItemSpacing: CGFloat = 12) -> CGFloat {
        guard !products.isEmpty else { return 0 }
        let cardsHeight = products.reduce(0) { $0 + IAPProductCardView.desiredHeight(for: $1) }
        let spacing = interItemSpacing * CGFloat(products.count - 1)
        return contentPadding.verticalLength + cardsHeight + spacing
    }
}
