//
//  SettingsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/7/21.
//

import Foundation
import UIKit

class AppSettingsViewController: BaseSettingViewController,
                                 TPSidebarContent {
    
    /// 侧边栏管理器
    var sidebarController: SidebarController?
    
    lazy var imageConfig: TPImageAccessoryConfig = {
        var config = TPImageAccessoryConfig()
        config.shouldRenderImageWithColor = false
        config.size = .size(8)
        return config
    }()
    
    // MARK: - 高级会员横幅
    let bannerPadding = UIEdgeInsets(top: 8.0, left: 20.0, bottom: 5.0, right: 20.0)
    
    /// 当前显示的横幅（未开通会员显示升级横幅，已开通显示会员横幅）
    private var bannerView: AppBannerRepresentable?
    
    /// 横幅作为表头时的尺寸（避免重复设置引起布局循环）
    private var bannerHeaderSize: CGSize = .zero
    
    /// 会员权益订阅
    private var entitlementToken: IAPObservationToken?
    
    /// 会员横幅
    private lazy var memberBannerView: MemberBannerView = {
        let bannerView = MemberBannerView()
        bannerView.contentPadding = bannerPadding
        bannerView.status = .sample()
        bannerView.cardView.delegate = self
        return bannerView
    }()
    
    /// 升级横幅
    private lazy var upgradeBannerView: AppProUpgradeBannerView = {
        let bannerView = AppProUpgradeBannerView()
        bannerView.contentPadding = bannerPadding
        bannerView.configure(title: resGetString("Go Premium"),
                             badgeText: resGetString("Limited Time Offer"),
                             badgeEmoji: "🔥",
                             badgeColor: UIColor(red: 0.96, green: 0.58, blue: 0.22, alpha: 1.0),
                             subtitle: resGetString("Unlock all premium features, enjoy an enhanced experience, and exclusive perks"))
        /// 点击横幅弹出会员购买页
        bannerView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                              action: #selector(clickUnlockPremium)))
        return bannerView
    }()
   
    /// 侧边栏菜单
    lazy var sideMenuCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_sideMenu_32"
        cellItem.title = resGetString("Side Menu")
        cellItem.didSelectHandler = { [weak self] in
            self?.clickSideMenu()
        }
        
        return cellItem
    }()
    
    /// 震动反馈
    lazy var hapticFeedbackCellItem: TPSwitchTableCellItem = { [weak self] in
        let cellItem = TPSwitchTableCellItem()
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_hapticFeedback_32"
        cellItem.title = resGetString("Haptic Feedback")
        cellItem.updater = {
            let isOn = AppSetting.shared.isHapiticFeedbackOn
            self?.hapticFeedbackCellItem.isOn = isOn
        }

        cellItem.valueChanged = { isOn in
            AppSetting.shared.isHapiticFeedbackOn = isOn
            TPImpactFeedback.feedback.enabled = isOn
        }
        
        return cellItem
    }()
    
    
    // 语言
    lazy var languageCellItem: TPImageInfoTextValueTableCellItem = {
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_language_32"
        cellItem.title = resGetString("Language")
        cellItem.valueConfig = .valueText(AppSettingUtil.currentLanguageDisplayName)
        cellItem.didSelectHandler = { [weak self] in
            self?.clickLanguage()
        }
        
        return cellItem
    }()
    
    lazy var generalSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [sideMenuCellItem,
                                       hapticFeedbackCellItem,
                                       languageCellItem]
        return sectionController
    }()
    
    // MARK: - 会员
    /// 解锁高级会员
    lazy var unlockPremiumCellItem: TPImageInfoTextValueTableCellItem = {
        let cellItem = TPImageInfoTextValueTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_unlockPro_32"
        cellItem.title = resGetString("Unlock Premium")
        cellItem.valueConfig = .valueText(resGetString("Free Plan"))
        cellItem.didSelectHandler = { [weak self] in
            self?.clickUnlockPremium()
        }
        
        return cellItem
    }()
    
    /// 恢复购买
    lazy var restorePurchasesCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_restorePurchases_32"
        cellItem.title = resGetString("Restore Purchases")
        cellItem.didSelectHandler = { [weak self] in
            self?.restorePurchases()
        }
        
        return cellItem
    }()
    
    lazy var membershipSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.title = resGetString("Membership")
        sectionController.headerItem.height = titleHeaderHeight
        sectionController.headerItem.padding = titleHeaderPadding
        sectionController.cellItems = [unlockPremiumCellItem,
                                       restorePurchasesCellItem]
        return sectionController
    }()
    
    // MARK: - 数据
    // iCloud 数据同步
    lazy var cloudCellItem: TPImageInfoTextValueTableCellItem = {
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_iCloud_32"
        cellItem.title = resGetString("iCloud Sync")
        cellItem.selectionStyle = .none
        cellItem.updater = { [weak self] in
            self?.updateCloudCellItem()
        }

        return cellItem
    }()
    
    lazy var dataSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [cloudCellItem]
        return sectionController
    }()
    
    // 模块设置区块
    lazy var moduleSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        
        let menuTypes: [SideMenuType] = [.myDay,
                                         .calendar,
                                         .todo,
                                         .goal,
                                         .focus,
                                         .habit,
                                         .countdown]
        var cellItems = [TPImageInfoTableCellItem]()
        for menuType in menuTypes {
            let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
            cellItem.imageConfig = imageConfig
            cellItem.imageName = menuType.iconName
            cellItem.title = menuType.title
            cellItem.didSelectHandler = { [weak self] in
                self?.showSettings(for: menuType)
            }
            
            cellItems.append(cellItem)
        }
        
        sectionController.cellItems = cellItems
        return sectionController
    }()
    
    lazy var rateCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_rate_32"
        cellItem.title = resGetString("Rate Us")
        cellItem.didSelectHandler = { [weak self] in
            self?.writeReview()
        }
        
        return cellItem
    }()
    
    lazy var shareCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem(accessoryType: .disclosureIndicator)
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_share_32"
        cellItem.title = resGetString("Share with Friends")
        cellItem.didSelectHandler = { [weak self] in
            self?.shareApp()
        }
        
        return cellItem
    }()
    
    lazy var supportUsSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = titleHeaderHeight
        sectionController.headerItem.padding = titleHeaderPadding
        sectionController.headerItem.title = resGetString("Support Us")
        sectionController.cellItems = [rateCellItem, shareCellItem]
        return sectionController
    }()
    
    // MARK: - 关于
    lazy var aboutCellItem: TPImageInfoTextValueTableCellItem = {
        let cellItem = TPImageInfoTextValueTableCellItem()
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_abount_32"
        cellItem.title = resGetString("About")
        
        var valueConfig: TPTextAccessoryConfig = .valueText("V\(Bundle.main.releaseVersion)")
        valueConfig.valueMargins = UIEdgeInsets(right: 16.0)
        cellItem.valueConfig = valueConfig
        cellItem.didSelectHandler = { [weak self] in
            self?.clickAbount()
        }
        
        return cellItem
    }()
    
    lazy var aboutSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [aboutCellItem]
        return sectionController
    }()
    
    private let cloudStatusViewModel = iCloudStatusViewModel()
    
    // MARK: - 翻页时钟
    lazy var flipClockCellItem: TPImageInfoTableCellItem = {
        let cellItem = TPImageInfoTableCellItem()
        cellItem.imageConfig = imageConfig
        cellItem.imageName = "setting_flipClock_32"
        cellItem.title = resGetString("Flip Clock")
        cellItem.didSelectHandler = { [weak self] in
            self?.clickFlipClock()
        }
        
        return cellItem
    }()

    lazy var flipClockSectionController: TPTableItemSectionController = {
        let sectionController = TPTableItemSectionController()
        sectionController.headerItem.height = normalHeaderHeight
        sectionController.cellItems = [flipClockCellItem]
        return sectionController
    }()
    
    deinit {
        cloudStatusViewModel.stopObserving()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Settings")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
    
        setupSectionControllers()
        reloadData()
        
        /// 添加会员横幅（根据会员状态动态切换）
        setupBannerView()
        
        cloudStatusViewModel.startObserving()
        cloudStatusViewModel.onStatusChanged = { [weak self] _ in
            self?.reloadCloudCell()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateBannerLayout()
    }
    
    private func setupSectionControllers() {
        var sectionControllers = [flipClockSectionController,
                                  generalSectionController,
                                  dataSectionController,
                                  moduleSectionController,
                                  supportUsSectionController,
                                  aboutSectionController]
        let entitlement = IAPManager.shared.entitlement
        if !entitlement.isActive {
            sectionControllers.insert(membershipSectionController, at: 0)
        }

        self.sectionControllers = sectionControllers
    }
    
    // MARK: - 会员横幅
    /// 监听会员权益变化，动态更新表头横幅
    private func setupBannerView() {
        entitlementToken = IAPManager.shared.observeEntitlement { [weak self] entitlement in
            self?.update(with: entitlement)
        }
    }
    
    private func update(with entitlement: IAPEntitlement) {
        TPLoadingIndicator.hideAllLoading() /// 防止升级视图控制器关闭，购买仍在进行中
        updateBannerView(isMember: entitlement.isActive)
        setupSectionControllers()
        adapter.performUpdate()
    }
    
    /// 更新表头横幅：未开通会员显示升级横幅，已开通显示会员横幅
    private func updateBannerView(isMember: Bool) {
        let bannerView: AppBannerRepresentable = isMember ? memberBannerView : upgradeBannerView
        guard self.bannerView !== bannerView else {
            return
        }
        
        self.bannerView = bannerView
        updateBannerLayout()
    }
    
    /// 更新横幅布局（作为列表头部视图，宽度变化后需要重新设置）
    private func updateBannerLayout() {
        guard let bannerView = bannerView else {
            return
        }
        
        let width = tableView.width
        guard width > 0 else {
            return
        }
        
        let headerSize = CGSize(width: width, height: bannerView.bannerHeight(forWidth: width))
        guard tableView.tableHeaderView !== bannerView || bannerHeaderSize != headerSize else {
            return
        }
        
        bannerView.frame = CGRect(origin: .zero, size: headerSize)
        tableView.tableHeaderView = bannerView
        bannerHeaderSize = headerSize
    }

    private func updateCloudCellItem() {
        let status = cloudStatusViewModel.cloudKitStatus
        if status.isAvailable {
            let syncDate = cloudStatusViewModel.lastSyncTime
            cloudCellItem.subtitle = syncDate?.yearMonthDayTimeString(omitYear: true,
                                                                      showRelativeDate: true,
                                                                      slashFormatted: false)
        } else {
            cloudCellItem.subtitle = status.description
        }
        
        let valueConfig = TPTextAccessoryConfig.valueText("•")
        valueConfig.textColor = status.color
        valueConfig.valueMargins = UIEdgeInsets(right: 16.0)
        valueConfig.valueFont = .boldSystemFont(ofSize: 36.0)
        cloudCellItem.valueConfig = valueConfig
    }
    
    private func reloadCloudCell() {
        DispatchQueue.main.async {
            self.adapter.reloadCell(forItem: self.cloudCellItem, with: .none)
        }
    }
    
    private func showSettings(for menuType: SideMenuType) {
        var vc: BaseSettingViewController?
        switch menuType {
        case .todo:
            vc = TodoSettingViewController()
        case .calendar:
            vc = CalendarSettingViewController()
        case .focus:
            vc = FocusSettingViewController()
        case .habit:
            vc = HabitSettingViewController()
        case .myDay:
            vc = MyDaySettingViewController()
        case .goal:
            vc = GoalSettingViewController()
        case .countdown:
            vc = CountdownSettingViewController()
        default:
            break
        }

        if let vc = vc {
            vc.isPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc private func clickUnlockPremium() {
        let vc = PaywallViewController()
        vc.showAsNavigationRoot()
    }
    
    private func restorePurchases() {
        TPLoadingIndicator.showLoading(resGetString("Processing..."))
        view.isUserInteractionEnabled = false
        Task {
            let entitlement = await IAPManager.shared.restore()
            TPLoadingIndicator.hideAllLoading()
            view.isUserInteractionEnabled = true
            update(with: entitlement)
            if entitlement.isActive {
                PaywallViewController.alertPurchasesRestored()
            } else {
                PaywallViewController.alertNoPurchasesFound()
            }
        }
    }
    
    private func clickSideMenu() {
        let vc = AppSideMenuSettingViewController(style: .insetGrouped)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func writeReview() {
        if let reviewURL = URL(string: AppConfig.reviewLink) {
            UIApplication.shared.open(reviewURL,
                                      options: [:],
                                      completionHandler: nil)
        }
    }
    
    private func shareApp() {
        guard let shareURL = URL(string: AppConfig.detailLink) else { return }
        let shareText = resGetString("Timely Plan: To-do · Matrix · Focus Timer — one app does it all 🚀")
        let activityItems: [Any] = [shareText, shareURL]
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        activityVC.excludedActivityTypes = [
            .saveToCameraRoll,
            .print,
            .addToReadingList
        ]
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            let sourceView = adapter.cellForItem(shareCellItem)
            activityVC.popoverPresentationController?.sourceView = sourceView
            activityVC.popoverPresentationController?.sourceRect = sourceView?.bounds ?? .zero
        }
        
        present(activityVC, animated: true)
    }

    private func clickLanguage() {
        AppSettingUtil.openSettings()
    }
    
    private func clickAbount() {
    #if DEBUG
        let previewVC = LocalNotificationPreviewViewController()
        navigationController?.pushViewController(previewVC, animated: true)
    #endif
    }
    
    private func clickFlipClock() {
        let vc = FlipClockMainViewController()
        vc.modalPresentationStyle = .fullScreen
        vc.show()
    }
    
}

// MARK: - MemberBannerCardDelegate
extension AppSettingsViewController: MemberBannerCardDelegate {
    
    func memberBannerCardDidTapDetail(_ card: MemberBannerCard) {
        /// 查看权益
        clickUnlockPremium()
    }
}
