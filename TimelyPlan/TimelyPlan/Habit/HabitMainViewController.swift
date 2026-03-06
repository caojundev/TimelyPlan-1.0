//
//  HabitMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/2/26.
//

import Foundation
import UIKit

enum HabitMainMenuType: Int, TPMenuRepresentable {
    case day = 0  /// 按日
    case week     /// 按周
    
    static func titles() -> [String] {
        return ["By Day", "By Week"]
    }
}

class HabitMainViewController: TPContainerViewController, TFSidebarContent {

    var sidebarController: SidebarController?
    
    /// 菜单类型
    private var menuType: HabitMainMenuType = .week
    
    /// 选项菜单
    lazy var typeMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.padding = UIEdgeInsets(value: 3.0)
        view.buttonHeight = 30.0
        view.minButtonWidth = 64.0
        view.didSelectMenuItem = { [weak self] menuItem in
            let menuType = HabitMainMenuType(rawValue: menuItem.tag) ?? .day
            self?.didSelectMenuType(menuType)
        }
        
        view.menuItems = HabitMainMenuType.segmentedMenuItems()
        view.sizeToFit()
        return view
    }()
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: HabitMoreBarButtonItem = {
        let item = HabitMoreBarButtonItem()
        item.didSelectType = {[weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
    
        typeMenuView.selectMenu(withTag: menuType.rawValue)
        navigationItem.titleView = typeMenuView
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        updateContentViewController()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - Event Response
    
    private func didSelectMenuType(_ menuType: HabitMainMenuType) {
        if self.menuType == menuType {
            return
        }
        
        self.menuType = menuType
        
        /// 取消第一响应（计时器搜索栏可能正在输入）
        UIResponder.resignCurrentFirstResponder()
        updateContentViewController()
    }
    
    private func updateContentViewController() {
        let vc: UIViewController
        if menuType == .day {
            vc = HabitHomeDayViewController()
        } else {
            vc = HabitHomeWeekViewController()
        }
        
        self.contentViewController = vc
    }
    
    /// 执行菜单操作
    func performMoreMenuAction(_ type: HabitMoreMenuType) {
        switch type {
        case .manageHabits:
            HabitPresenter.manageHabits()
        case .settings:
            HabitPresenter.showSettings()
        }
    }
}
