//
//  FocusMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/23.
//

import Foundation
import UIKit

/// 主菜单类型
enum FocusMainMenuType: Int, TPMenuRepresentable {
    case focus = 0 /// 专注
    case timer     /// 计时器
    
    static func titles() -> [String] {
        return ["Focus", "Timer"]
    }
}

class FocusMainViewController: TPPageController, TFSidebarContent {
 
    var sidebarController: SidebarController?
    
    /// 选项菜单
    lazy var segmentedMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.padding = UIEdgeInsets(value: 3.0)
        view.buttonHeight = 30.0
        view.minButtonWidth = 64.0
        view.didSelectMenuItem = { [weak self] menuItem in
            /// 取消第一响应（计时器搜索栏可能正在输入）
            UIResponder.resignCurrentFirstResponder()
            
            /// 选中页面
            self?.selectPage(at: menuItem.tag, animated: true)
        }
        
        view.menuItems = FocusMainMenuType.segmentedMenuItems()
        view.sizeToFit()
        return view
    }()
    
    /// 统计按钮
    lazy var statisticsBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("chart_pie_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(clickStatistics(_:)))
        return buttonItem
    }()
  
    /// 记录按钮
    lazy var recordsBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("focus_record_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickTimeline(_:)))
        return item
    }()

    /// 更多菜单按钮
    lazy var moreBarButtonItem: FocusMoreBarButtonItem = {
        let item = FocusMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
    /// 开始专注视图控制器
    lazy var startViewController: FocusStartViewController = {
        let vc = FocusStartViewController()
        return vc
    }()
    
    /// 用户计时器视图控制器
    lazy var timersViewController: FocusHomeViewController = {
        let vc = FocusHomeViewController()
        vc.pageController = self
        return vc
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.menuView = segmentedMenuView
        self.navigationItem.titleView = menuView
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            self.navigationItem.leftBarButtonItems = [sidebarButtonItem,
                                                      statisticsBarButtonItem]
        }
    
        self.navigationItem.rightBarButtonItems = [moreBarButtonItem,
                                                   recordsBarButtonItem]
        self.bounces = false
        self.trackingProgress = false
        self.selectPage(at: FocusMainMenuType.focus.rawValue)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateBackgroundTheme()
        updateNavigationBarTheme()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - TFPageContollerDataSource
    override func numberOfViewControllers(in pageController: TPPageController) -> Int {
        return FocusMainMenuType.allCases.count
    }
    
    override func pageController(_ pageController: TPPageController, viewControllerAt index: Int) -> UIViewController! {
        let menuType = FocusMainMenuType(rawValue: index) ?? .timer
        switch menuType {
        case .focus:
            return startViewController
        case .timer:
            return timersViewController
        }
    }

    // MARK: - Event Response
    @objc func clickRecords(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        FocusPresenter.showRecords()
    }
    
    @objc func clickTimeline(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        FocusPresenter.showTimeline()
    }
    
    /// 点击统计
    @objc func clickStatistics(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithLightStyle()
        FocusPresenter.showOverallStatistics()
    }

    /// 执行菜单操作
    func performMoreMenuAction(_ type: FocusMoreMenuType) {
        switch type {
        case .addRecord:
            let timerController = FocusUserTimerController()
            timerController.addRecordManually()
        case .archived:
            FocusPresenter.showArchivedTimers()
        case .settings:
            FocusPresenter.showSettings()
        }
    }
}
