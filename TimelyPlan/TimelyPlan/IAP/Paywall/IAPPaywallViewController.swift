//
//  IAPPaywallViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/19.
//

import Foundation
import UIKit
import StoreKit

/// 付费页配色（全部支持明暗模式）
enum IAPColor {
    /// 页面背景
    static let background = Color(light: 0xF7F8FA, dark: 0x121214)
    /// 主色：Continue 按钮背景，也是整个页面的高亮色
    static let primary = Color(light: 0x2F6FDB, dark: 0x4C8CD9)
    /// 卡片背景
    static let cardBackground = Color(light: 0xFFFFFF, dark: 0x1C1C21)
    /// 卡片边框
    static let cardBorder = Color(light: 0xE5E6EB, dark: 0x2E2E36)
    /// 强调蓝：价格文案、选中边框
    static let indicatorBlue = Color(light: 0x2B6FE0, dark: 0x5999FA)
    /// 主文字
    static let title = Color(light: 0x1D2129, dark: 0xEBEBF0)
    /// 次要文字
    static let subtitleGray = Color(light: 0x86909C, dark: 0x80808C)
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
    
    private let benefitsHeaderLabel = TPLabel()
    private let benefitsTableView = IAPMembershipBenefitsListView()
    private let actionsView = IAPActionsView()
    private let reminderView = IAPReminderView()
    
    /// 商品区域高度（加载态固定 40，加载完成后为全部商品内容高度）
    private var productAreaHeight: CGFloat {
        productSelectorView.recommendedHeight()
    }
    
    // MARK: - 生命周期
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Upgrade to Premium")
        // 左上角关闭按钮（系统样式）
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close,
                                                           target: self,
                                                           action: #selector(didClickCancel))
        contentView.showsVerticalScrollIndicator = false
        view.addSubview(contentView)
        // 底部渐变过渡到页面背景色（明暗模式一致）
        continueView.backgroundColorValue = IAPColor.background
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
        // 选择器内部自带加载态（加载中只显示指示器，高度 40）
        productSelectorView.onProductSelected = { [weak self] _, product in
            self?.selectedProduct = product
            self?.refreshContinueState()
        }
        contentView.addSubview(productSelectorView)
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
        productSelectorView.setLoading(true)
        relayoutProductArea()
        loadProducts()
    }
    
    /// 商品就绪：结束加载态并创建卡片；选择器淡入显示，下方视图动画下移
    private func apply(storeProducts: [IAPStoreProduct]) {
        guard !storeProducts.isEmpty else { return }
        
        products = IAPPaywallProduct.convert(storeProducts)
        selectedProduct = products.first
        
        let wasLoading = productSelectorView.isLoading
        
        // configure 内部会结束加载态并创建卡片
        productSelectorView.configure(products: products, defaultSelectedIndex: 0)
        
        // 首次展示尚未完成（商品在弹出动画期间就绪），或非首次收到商品回调：
        // 直接完成布局、不做动画，避免与弹出动画叠加成「内容从 0 展开」
        guard wasLoading, !isFirstAppearance else {
            UIView.performWithoutAnimation {
                self.productSelectorView.alpha = 1
                self.relayoutProductArea()
            }
            refreshContinueState()
            return
        }
        
        // 先保持透明，并让选择器直接落到最终高度（尺寸不参与动画，避免看起来在「展开」）
        productSelectorView.alpha = 0
        productSelectorView.frame.size.height = productSelectorView.recommendedHeight()
        productSelectorView.layoutIfNeeded()
        
        // 选择器淡入，同时下方视图动画移动到新位置
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [.curveEaseOut, .beginFromCurrentState]) {
            self.productSelectorView.alpha = 1.0
            self.relayoutProductArea()
        }
        
        refreshContinueState()
    }
    
    /// 商品区域高度变化后重排整页（下方视图需跟随移动）
    private func relayoutProductArea() {
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    private func handleProductsLoadFailure() {
        // 已有商品（缓存）时不打扰用户
        guard products.isEmpty else { return }
        
        productSelectorView.setLoading(false)
        relayoutProductArea()
        let alert = UIAlertController(
            title: resGetString("Unable to Load Products"),
            message: resGetString("Please check your network connection and try again."),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: resGetString("Retry"), style: .default) { [weak self] _ in
            self?.retryLoadProducts()
        })
        alert.addAction(UIAlertAction(title: resGetString("Cancel"), style: .cancel))
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
        continueView.setLoading(false)
        continueView.onContinueTapped = { [weak self] in
            guard let self = self, let product = self.selectedProduct else { return }
            // 已拥有该商品时不做处理（按钮标题为「已开通」）
            guard !self.entitlement.hasAccess(to: product.id) else { return }
            self.purchase(product)
        }
    }
    
    /// 根据选中商品与当前权益刷新底部按钮状态与说明文案
    private func refreshContinueState() {
        guard let product = selectedProduct else {
            continueView.setLoading(false)
            continueView.setNoteText("")
            return
        }
        
        let owned = entitlement.hasAccess(to: product.id)
        // 购买/恢复进行中显示加载指示器（此状态下按钮不可点击）
        continueView.setLoading(isProcessing)
        continueView.setTitle(owned ? resGetString("Activated") : resGetString("Continue"))
        
        if owned {
            continueView.setNoteText(resGetString("You already own this item"))
            return
        }
        
        let isSubscription = product.storeProduct?.isSubscription == true
        
        // 价格 + 计费说明："¥98/yr Billed yearly" / "¥168 One-time Purchase"
        var note = product.priceText
        if let storeProduct = product.storeProduct,
           let priceNote = IAPPaywallProduct.priceNote(for: storeProduct) {
            note += " • " + priceNote
            
        }
        
        // 订阅换行提示可随时取消，买断提示无需订阅
        note += "\n"
        if isSubscription {
            note += resGetString("Cancel anytime")
        } else {
            note += resGetString("No subscription")
        }
        
        continueView.setNoteText(note)
    }
    
    // MARK: - 权益对比
    
    private func setupBenefitsView() {
        benefitsHeaderLabel.textAlignment = .center
        benefitsHeaderLabel.textColor = resGetColor(.title)
        benefitsHeaderLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        contentView.addSubview(benefitsHeaderLabel)
        
        let format = resGetString("Enjoy %@ Pro Features")
        let attributedString: ASAttributedString = .string(format: format,
                                                           stringParameters: ["10+"],
                                                           highlightedColor: MembershipColor.highlight)
        benefitsHeaderLabel.update(with: attributedString)
        
        benefitsTableView.rows = [
            IAPMembershipBenefitRow(title: "日历视图", freeValue: "基础", proValue: "月/周/日/3日"),
            IAPMembershipBenefitRow(title: "时间段",       freeValue: nil,      proValue: nil),
            IAPMembershipBenefitRow(title: "持续提醒",     freeValue: nil,      proValue: nil),
            IAPMembershipBenefitRow(title: "关联 Notion",  freeValue: nil,      proValue: nil),
            IAPMembershipBenefitRow(title: "关联微信",     freeValue: nil,      proValue: nil),
            IAPMembershipBenefitRow(title: "AI 语音添加",  freeValue: nil,      proValue: nil),
            IAPMembershipBenefitRow(title: "AI 录音总结",  freeValue: nil,      proValue: nil),
            IAPMembershipBenefitRow(title: "小组件",       freeValue: "基础",   proValue: "无限制"),
            IAPMembershipBenefitRow(title: "外观主题",     freeValue: "基础",   proValue: "无限制"),
            IAPMembershipBenefitRow(title: "数据统计",     freeValue: "基础",   proValue: "无限制"),
            IAPMembershipBenefitRow(title: "更多功能",     freeValue: nil,      proValue: nil),
        ]
        
        benefitsTableView.onContentHeightChanged = { [weak self] _ in
            guard let self = self else { return }
            // 与表格内部展开/收起的动画时长保持一致，
            // 让外层高度与下方视图和表格内容同步移动
            self.view.animateLayout(withDuration: IAPMembershipBenefitsListView.expansionDuration)
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
        reminderView.onTapPrivacy = {
            #warning("打开隐私政策")
        }
        reminderView.onTapTerms = {
            #warning("打开服务条款")
        }
        
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
                self.alert(resGetString("Purchases Restored")) { [weak self] in
                    self?.dismiss(animated: true)
                }
            } else {
                self.alert(resGetString("No purchases to restore were found."))
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
        alert.addAction(UIAlertAction(title: resGetString("OK"), style: .default) { _ in completion?() })
        present(alert, animated: true)
    }
    
    // MARK: - 布局
    
    /// 首次有效布局是否已完成
    private var hasFinishedInitialLayout = false
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // 弹窗期间 bounds 可能尚未确定，此时不布局，避免算出无效 frame
        guard view.width > 0, view.height > 0 else { return }
        
        if hasFinishedInitialLayout {
            layoutContent()
        } else {
            // 首次布局直接完成、不带任何动画：
            // 保证弹出时就是最终布局，而不是内容从零尺寸「展开」
            hasFinishedInitialLayout = true
            UIView.performWithoutAnimation { layoutContent() }
        }
    }
    
    /// 内容布局（动画与非动画共用）
    private func layoutContent() {
        contentView.frame = view.bounds
        
        continueView.width = view.width
        continueView.sizeToFit()
        continueView.bottom = view.height
        
        let margin = 16.0
        let layoutWidth = view.width - 2 * margin
        
        // 商品区域：加载完成后为全部商品内容高度
        let productAreaFrame = CGRect(
            x: margin,
            y: 0.0,
            width: layoutWidth,
            height: productAreaHeight
        )
        productSelectorView.frame = productAreaFrame
        
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
        return IAPColor.background
    }
    
    override func themeDidChange() {
        super.themeDidChange()
        // 部分颜色写在 CALayer 上（CGColor 不会自动跟随明暗外观），
        // 主动刷新这些视图，让它们按新的明暗外观重新取值
        continueView.backgroundColorValue = IAPColor.background
        continueView.setNeedsLayout()
        productSelectorView.refreshAppearance()
        benefitsTableView.setNeedsLayout()
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return themeBackgroundColor
    }

}
