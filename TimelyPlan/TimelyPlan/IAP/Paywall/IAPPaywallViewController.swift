//
//  IAPPaywallViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit
import StoreKit

enum IAPColor {
    static let primary = UIColor(red: 0.30, green: 0.55, blue: 0.85, alpha: 1.0)
    
    static let cardBackground = UIColor(red: 0.11, green: 0.11, blue: 0.13, alpha: 1)
    static let cardBorder     = UIColor(red: 0.18, green: 0.18, blue: 0.21, alpha: 1)
    static let indicatorBlue  = UIColor(red: 0.35, green: 0.60, blue: 0.98, alpha: 1)
    static let titleWhite     = UIColor(red: 0.92, green: 0.92, blue: 0.94, alpha: 1)
    static let subtitleGray   = UIColor(red: 0.50, green: 0.50, blue: 0.55, alpha: 1)
}

class PaywallViewController: TPViewController {
    
    // MARK: - 内购
    
    /// 商品/权益来源
    private let manager = IAPManager.shared
    /// 商品与权益订阅器（随 VC 释放自动退订）
    private let store = IAPStorefront()
    
    /// 已加载并转换好的商品（Store 数据）
    private var products: [IAPPaywallProduct] = []
    /// 当前选中的商品
    private var selectedProduct: IAPPaywallProduct?
    /// 当前权益快照
    private var entitlement: IAPEntitlement = .empty
    /// 是否正在处理购买/恢复
    private var isProcessing = false
    
    // MARK: - 子视图
    
    private let contentView = UIScrollView()
    private let continueView = IAPContinueView()
    
    private let productSelectorView = IAPProductSelectorView()
    /// 商品加载指示器：加载期间占据 productSelectorView 的位置
    private let productLoadingIndicator = UIActivityIndicatorView(style: .medium)
    
    private let benefitsHeaderLabel = UILabel()
    private let benefitsTableView = IAPMembershipBenefitsTableView()
    private let actionsView = IAPActionsView()
    private let reminderView = IAPReminderView()
    
    /// 商品加载完成前的占位高度，避免布局在数据未就绪时抖动
    private static let productAreaPlaceholderHeight: CGFloat = 170.0
    /// 商品区域高度：有数据时按卡片实际高度，否则使用占位高度
    private var productAreaHeight: CGFloat {
        let height = IAPProductSelectorView.recommendedHeight(for: products)
        return height > 0 ? height : Self.productAreaPlaceholderHeight
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Upgrade to Premium")
        view.addSubview(contentView)
        view.addSubview(continueView)
        
        setupProductSelectorView()
        setupBenefitsView()
        setupActionsView()
        setupReminderView()
        setupContinueView()
        
        setupBinding()
        loadProducts()
    }
    
    // MARK: - 商品
    
    private func setupProductSelectorView() {
        // 商品未就绪前不展示选择器，改由指示器占位
        productSelectorView.isHidden = true
        productSelectorView.onProductSelected = { [weak self] _, product in
            self?.selectedProduct = product
            self?.refreshContinueState()
        }
        contentView.addSubview(productSelectorView)
        
        productLoadingIndicator.hidesWhenStopped = true
        productLoadingIndicator.color = IAPColor.subtitleGray
        contentView.addSubview(productLoadingIndicator)
        productLoadingIndicator.startAnimating()
    }
    
    private func loadProducts() {
        Task {
            await manager.loadProducts()
            // 商品为空说明加载失败（网络等原因），给出重试入口；
            // 成功时由 store.onProducts 回调驱动 UI 刷新。
            if manager.products.isEmpty {
                self.handleProductsLoadFailure()
            }
        }
    }
    
    private func retryLoadProducts() {
        guard !manager.isLoadingProducts else { return }
        productSelectorView.isHidden = true
        productLoadingIndicator.startAnimating()
        loadProducts()
    }
    
    /// 商品就绪：隐藏指示器，展示选择器
    private func apply(storeProducts: [IAPStoreProduct]) {
        guard !storeProducts.isEmpty else { return }
        
        products = IAPPaywallProduct.convert(storeProducts)
        selectedProduct = products.first
        
        productSelectorView.configure(products: products, defaultSelectedIndex: 0)
        // 先在隐藏状态下完成布局，再显示选择器，
        // 避免卡片/选择器出现时产生从左上角展开的动画观感
        view.layoutIfNeeded()
        
        productLoadingIndicator.stopAnimating()
        productSelectorView.isHidden = false
        
        refreshContinueState()
    }
    
    private func handleProductsLoadFailure() {
        // 已有商品（缓存）时不打扰用户
        guard products.isEmpty, productSelectorView.isHidden else { return }
        
        productLoadingIndicator.stopAnimating()
        let alert = UIAlertController(
            title: "无法加载商品",
            message: "请检查网络连接后重试。",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "重试", style: .default) { [weak self] _ in
            self?.retryLoadProducts()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    // MARK: - 数据绑定
    
    private func setupBinding() {
        // 先挂回调再订阅：bind() 会立即回放当前的商品/权益状态，
        // 若已有缓存商品，可省去一次等待。
        store.onProducts = { [weak self] storeProducts in
            self?.apply(storeProducts: storeProducts)
        }
        
        store.onEntitlement = { [weak self] entitlement in
            self?.entitlement = entitlement
            self?.refreshContinueState()
        }
        
        store.bind()
    }
    
    // MARK: - 继续按钮
    
    private func setupContinueView() {
        continueView.setEnabled(false)
        continueView.onContinueTapped = { [weak self] in
            guard let self = self, let product = self.selectedProduct else { return }
            self.purchase(product)
        }
    }
    
    /// 根据选中商品与当前权益刷新底部按钮状态与说明文案
    private func refreshContinueState() {
        guard let product = selectedProduct else {
            continueView.setEnabled(false)
            continueView.setNoteText("")
            return
        }
        
        let owned = entitlement.hasAccess(to: product.id)
        continueView.setEnabled(!owned && !isProcessing)
        continueView.setTitle(owned ? "已开通" : resGetString("Continue"))
        
        if owned {
            continueView.setNoteText("你已拥有该商品")
            return
        }
        
        var note = product.priceText
        if let priceNote = product.priceNote {
            note += " · \(priceNote)"
        }
        if product.storeProduct?.isSubscription == true {
            note += "\nCancel anytime"
        }
        continueView.setNoteText(note)
    }
    
    // MARK: - 权益对比
    
    private func setupBenefitsView() {
        // 分组小标题
        benefitsHeaderLabel.text = "功能畅享特权"
        benefitsHeaderLabel.textColor = MembershipColor.sectionOrange
        benefitsHeaderLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        contentView.addSubview(benefitsHeaderLabel)
        
        benefitsTableView.rows = [
            BenefitRow(title: "日历视图",     freeValue: "基础",   proValue: "月/周/日/3日"),
            BenefitRow(title: "时间段",       freeValue: nil,      proValue: nil),
            BenefitRow(title: "持续提醒",     freeValue: nil,      proValue: nil),
            BenefitRow(title: "关联 Notion",  freeValue: nil,      proValue: nil),
            BenefitRow(title: "关联微信",     freeValue: nil,      proValue: nil),
            BenefitRow(title: "AI 语音添加",  freeValue: nil,      proValue: nil),
            BenefitRow(title: "AI 录音总结",  freeValue: nil,      proValue: nil),
            BenefitRow(title: "小组件",       freeValue: "基础",   proValue: "无限制"),
            BenefitRow(title: "外观主题",     freeValue: "基础",   proValue: "无限制"),
            BenefitRow(title: "数据统计",     freeValue: "基础",   proValue: "无限制"),
            BenefitRow(title: "更多功能",     freeValue: nil,      proValue: nil),
        ]
        
        benefitsTableView.onContentHeightChanged = { [weak self] _ in
            guard let self = self else { return }
            self.view.animateLayout(withDuration: 0.4)
        }
        
        contentView.addSubview(benefitsTableView)
    }
    
    // MARK: - 操作区
    
    private func setupActionsView() {
        actionsView.onRestorePurchasesTapped = { [weak self] in
            self?.restorePurchases()
        }
        
        actionsView.onRedeemCodeTapped = { [weak self] in
            self?.redeemCode()
        }
        
        contentView.addSubview(actionsView)
    }
    
    private func setupReminderView() {
        reminderView.onTapPrivacy = { print("打开隐私政策") }
        reminderView.onTapTerms   = { print("打开服务条款") }
        contentView.addSubview(reminderView)
    }
    
    // MARK: - 购买 / 恢复 / 兑换
    
    private func purchase(_ product: IAPPaywallProduct) {
        guard let storeProduct = product.storeProduct else { return }
        
        setProcessing(true)
        Task {
            let result = await self.manager.purchase(storeProduct)
            self.setProcessing(false)
            self.handlePurchaseResult(result)
        }
    }
    
    private func handlePurchaseResult(_ result: IAPPurchaseResult) {
        switch result {
        case .success:
            // 权益已刷新，成功即关闭付费页
            dismiss(animated: true)
        case .userCancelled:
            break
        case .pending, .unverified, .failed:
            alert(result.message)
        }
    }
    
    private func restorePurchases() {
        setProcessing(true)
        Task {
            let snapshot = await self.manager.restore()
            self.entitlement = snapshot
            self.setProcessing(false)
            
            if snapshot.isActive {
                self.alert("已恢复购买") { [weak self] in
                    self?.dismiss(animated: true)
                }
            } else {
                self.alert("未找到可恢复的购买记录。")
            }
        }
    }
    
    private func redeemCode() {
        SKPaymentQueue.default().presentCodeRedemptionSheet()
    }
    
    /// 处理中禁止交互，避免重复下单
    private func setProcessing(_ processing: Bool) {
        isProcessing = processing
        view.isUserInteractionEnabled = !processing
        refreshContinueState()
    }
    
    private func alert(_ message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
    // MARK: - 布局
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = view.bounds
        
        continueView.width = view.width
        continueView.sizeToFit()
        continueView.bottom = view.height
        
        let margin = 16.0
        let layoutWidth = view.width - 2 * margin
        
        // 商品区域：加载中显示指示器，加载完成显示选择器（两者位置一致）
        let productAreaFrame = CGRect(
            x: margin,
            y: 20,
            width: layoutWidth,
            height: productAreaHeight
        )
        productSelectorView.frame = productAreaFrame
        productLoadingIndicator.center = CGPoint(x: productAreaFrame.midX,
                                                 y: productAreaFrame.midY)
        
        benefitsHeaderLabel.frame = CGRect(
            x: margin,
            y: productAreaFrame.maxY + 30.0,
            width: layoutWidth,
            height: 24.0
        )
        
        let benefitsHeight = benefitsTableView.contentHeight
        benefitsTableView.frame = CGRect(
            x: margin,
            y: benefitsHeaderLabel.bottom + 15.0,
            width: layoutWidth,
            height: benefitsHeight
        )
  
        let constraintSize = CGSize(width: layoutWidth, height: .greatestFiniteMagnitude)
        let actionsViewSize = actionsView.sizeThatFits(constraintSize)
        actionsView.frame = CGRect(
            x: margin,
            y: benefitsTableView.bottom + 10.0,
            width: layoutWidth,
            height: actionsViewSize.height
        )
        
        let reminderViewSize = reminderView.sizeThatFits(constraintSize)
        reminderView.frame = CGRect(
            x: margin,
            y: actionsView.bottom + 10.0,
            width: layoutWidth,
            height: reminderViewSize.height
        )
        
        contentView.contentSize = CGSize(width: view.bounds.width,
                                         height: reminderView.bottom)
        contentView.contentInset = UIEdgeInsets(bottom: continueView.height)
    }
    
    override var themeBackgroundColor: UIColor? {
        return UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1)
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return themeBackgroundColor
    }

}
