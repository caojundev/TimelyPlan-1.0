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
    
    // MARK: - 会员升级横幅
    /// 会员升级横幅
    private lazy var promoCard: AppProUpgradeBannerView = {
        let promoCard = AppProUpgradeBannerView()
        /// 内容内间距，用于制造卡片四周的空白
        promoCard.contentPadding = UIEdgeInsets(top: 8.0, left: 20.0, bottom: 5.0, right: 20.0)
        promoCard.configure(title: resGetString("Go Premium"),
                            badgeText: resGetString("Limited Time Offer"),
                            badgeEmoji: "🔥",
                            badgeColor: UIColor(red: 0.96, green: 0.58, blue: 0.22, alpha: 1.0),
                            subtitle: resGetString("Unlock all premium features, enjoy an enhanced experience, and exclusive perks"))
        /// 点击横幅弹出会员购买页
        promoCard.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                             action: #selector(clickUnlockPremium)))
        return promoCard
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
        /// 显示会员状态（每次展示单元格时刷新）
        cellItem.updater = { [weak self] in
            self?.updateUnlockPremiumCellItem()
        }
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
    
        sectionControllers = [membershipSectionController,
                              flipClockSectionController,
                              generalSectionController,
                              dataSectionController,
                              moduleSectionController,
                              supportUsSectionController,
                              aboutSectionController]
        reloadData()
        
        /// 添加会员升级横幅
        updatePromoCardLayout()
        
        cloudStatusViewModel.startObserving()
        cloudStatusViewModel.onStatusChanged = { [weak self] _ in
            self?.reloadCloudCell()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePromoCardLayout()
    }
    
    /// 更新会员升级横幅布局（作为列表头部视图，宽度变化后需要重新设置）
    private func updatePromoCardLayout() {
        let width = tableView.width
        guard width > 0 else {
            return
        }
        
        let headerSize = CGSize(width: width, height: promoCard.intrinsicContentSize.height)
        guard promoCard.size != headerSize else {
            return
        }
        
        promoCard.frame = CGRect(origin: .zero, size: headerSize)
        tableView.tableHeaderView = promoCard
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
        /// 弹出内置付费页（IAPUIKit 中的 UIViewController 扩展），
        /// 商品加载、购买、恢复购买与错误提示都由付费页内部处理
        presentPaywall { [weak self] _ in
            /// 购买/恢复流程结束，刷新会员状态（回调不保证在主线程）
            DispatchQueue.main.async {
                self?.reloadUnlockPremiumCell()
            }
        }
    }
    
    /// 会员状态文案：未开通显示 Free Plan；订阅显示到期日期；买断制显示已开通
    private func updateUnlockPremiumCellItem() {
        let entitlement = IAPManager.shared.entitlement
        let text: String
        if !entitlement.isActive {
            text = resGetString("Free Plan")
        } else if let expiry = entitlement.subscriptionExpiryDate {
            text = expiry.yearMonthDayString
        } else {
            text = "✓"
        }
        
        var valueConfig: TPTextAccessoryConfig = .valueText(text)
        valueConfig.valueMargins = UIEdgeInsets(right: 16.0)
        unlockPremiumCellItem.valueConfig = valueConfig
    }
    
    /// 刷新会员单元格
    private func reloadUnlockPremiumCell() {
        updateUnlockPremiumCellItem()
        adapter.reloadCell(forItem: unlockPremiumCellItem, with: .none)
    }
    
    private func restorePurchases() {
        /// TODO: 对接内购管理器，恢复购买
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
