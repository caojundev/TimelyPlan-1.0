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

class HabitMainViewController: TPContainerViewController, TPSidebarContent {

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
    
    /// 报告按钮
    lazy var reportBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("habit_report_24")
        let buttonItem = UIBarButtonItem(image: image,
                                         style: .plain,
                                         target: self,
                                         action: #selector(clickReport(_:)))
        return buttonItem
    }()
    
    /// 记录按钮
    lazy var recordBarButtonItem: UIBarButtonItem = {
        let image = resGetImage("habit_record_24")
        let item = UIBarButtonItem(image: image,
                                   style: .plain,
                                   target: self,
                                   action: #selector(clickRecord(_:)))
        return item
    }()
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: HabitMoreBarButtonItem = {
        let item = HabitMoreBarButtonItem()
        item.didSelectType = {[weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
    private let recordResultPopupController = HabitRecordResultPopupController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem,
                                                 self.reportBarButtonItem]
        }
    
        typeMenuView.selectMenu(withTag: menuType.rawValue)
        navigationItem.titleView = typeMenuView
        navigationItem.rightBarButtonItems = [moreBarButtonItem,
                                              recordBarButtonItem]
        updateContentViewController()
        habit.addUpdater(recordResultPopupController, for: [.record])
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
    @objc func clickReport(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithSoftStyle()
        HabitPresenter.showReport()
    }
    
    @objc func clickRecord(_ buttonItem: UIBarButtonItem) {
        TPImpactFeedback.impactWithSoftStyle()
        HabitPresenter.showRecords()
    }
    
    private func didSelectMenuType(_ menuType: HabitMainMenuType) {
        if self.menuType == menuType {
            return
        }
        
        let slideStyle = SlideStyle.horizontalStyle(fromValue: self.menuType.rawValue,
                                                    toValue: menuType.rawValue)
        self.menuType = menuType
    
        UIResponder.resignCurrentFirstResponder()
        updateContentViewController(withAnimationStyle: slideStyle)
    }
    
    private func updateContentViewController(withAnimationStyle style: SlideStyle = .none) {
        let vc: UIViewController
        if menuType == .day {
            vc = HabitHomeDayViewController()
        } else {
            vc = HabitHomeWeekViewController()
        }
        
        self.setContentViewController(vc, withAnimationStyle: style)
    }
    
    /// 执行菜单操作
    func performMoreMenuAction(_ type: HabitMoreMenuType) {
        switch type {
        case .manageHabits:
            HabitPresenter.manageHabits()
        case .archived:
            HabitPresenter.manageHabits(menuType: .archived)
        case .settings:
            HabitPresenter.showSettings()
        }
    }
}
