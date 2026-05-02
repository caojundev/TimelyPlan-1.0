//
//  HabitManageMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/5.
//

import Foundation
import UIKit

enum HabitManageListType: Int, TPMenuRepresentable {
    case active = 0  /// 活动
    case archived    /// 归档
    
    static func titles() -> [String] {
        return ["Active", "Archived"]
    }
}

class HabitManageMainViewController: TPContainerViewController, TPSidebarContent {

    var sidebarController: SidebarController?
    
    /// 菜单类型
    private var menuType: HabitManageListType = .active
    
    /// 选项菜单
    lazy var typeMenuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.padding = UIEdgeInsets(value: 3.0)
        view.buttonHeight = 30.0
        view.minButtonWidth = 64.0
        view.didSelectMenuItem = { [weak self] menuItem in
            let menuType = HabitManageListType(rawValue: menuItem.tag) ?? .active
            self?.didSelectMenuType(menuType)
        }
        
        view.menuItems = HabitManageListType.segmentedMenuItems()
        view.sizeToFit()
        return view
    }()
    
    init(menuType: HabitManageListType) {
        self.menuType = menuType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        typeMenuView.selectMenu(withTag: menuType.rawValue)
        navigationItem.titleView = typeMenuView
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        updateContentViewController()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    // MARK: - Event Response
    
    private func didSelectMenuType(_ menuType: HabitManageListType) {
        if self.menuType == menuType {
            return
        }
        
        let style = SlideStyle.horizontalStyle(fromValue: self.menuType.rawValue,
                                               toValue: menuType.rawValue)
        self.menuType = menuType
        updateContentViewController(With: style)
    }
    
    private func updateContentViewController(With style: SlideStyle = .none) {
        let vc: UIViewController
        if menuType == .active {
            vc = HabitManageActiveListViewController()
        } else {
            vc = HabitManageArchivedListViewController()
        }
        
        self.setContentViewController(vc, withAnimationStyle: style)
    }
}
