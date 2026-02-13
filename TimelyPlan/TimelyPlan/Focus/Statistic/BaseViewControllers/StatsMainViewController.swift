//
//  StatsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/26.
//

import Foundation
import UIKit

/// 统计类型
enum StatsType: String, TPMenuRepresentable {
    case day   /// 日
    case week  /// 周
    case month /// 月
    case year  /// 年
}

class StatsMainViewController: TPContainerViewController {

    /// 菜单高度
    var menuHeight = 30.0
    
    /// 菜单宽度
    var minimumMenuWidth = 60.0
    
    /// 当前统计类型
    var type: StatsType
    
    /// 允许的统计类型
    var allowTypes: [StatsType]
    
    /// 当前日期
    private(set) var date: Date
    
    /// 统计类型菜单
    lazy var menuView: TPSegmentedMenuView = {
        let view = TPSegmentedMenuView()
        view.buttonHeight = menuHeight
        view.minButtonWidth = minimumMenuWidth
        view.padding = UIEdgeInsets(value: 4.0)
        view.cornerRadius = .greatestFiniteMagnitude
        view.menuItems = allowTypes.segmentedMenuItems()
        view.didSelectMenuItem = {[weak self] menuItem in
            guard let type = StatsType(rawValue: menuItem.identifier) else {
                return
            }
            
            self?.selectStatsType(type)
        }
        
        view.sizeToFit()
        return view
    }()

    /// 内容间距
    var contentInset: UIEdgeInsets = .zero {
        didSet {
            let vc = self.contentViewController as? StatsContentViewController
            vc?.contentInset = contentInset
        }
    }
    
    init(type: StatsType, allowTypes: [StatsType] = StatsType.allCases, date: Date = .now) {
        self.type = type
        self.allowTypes = allowTypes
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = menuView
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        
        /// 选中菜单
        let tag = allowTypes.firstIndex(of: type) ?? 0
        self.menuView.selectMenu(withTag: tag)
        self.contentViewController = viewController(for: type)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func viewController(for type: StatsType) -> UIViewController {
        let vc: UIViewController
        switch type {
        case .day:
            vc = dailyStatsViewController()
        case .week:
            vc = weeklyStatsViewController()
        case .month:
            vc = monthlyStatsViewController()
        case .year:
            vc = yearlyStatsViewController()
        }
        
        /// 设置统计内容视图的内边距
        if let vc = vc as? StatsContentViewController {
            vc.contentInset = contentInset
        }
        
        return vc
    }
    
    // MARK: - 选中统计类型
    func selectStatsType(_ type: StatsType) {
        let fromIndex = self.type.index ?? 0
        let toIndex = type.index ?? 0
        let style = SlideStyle.horizontalStyle(fromValue: fromIndex, toValue: toIndex)
        self.type = type
        let vc = viewController(for: type)
        self.setContentViewController(vc, withAnimationStyle: style)
    }
    
    // MARK: - 子类重写
    func dailyStatsViewController() -> UIViewController! {
        return UIViewController()
    }
    
    func weeklyStatsViewController() -> UIViewController! {
        return UIViewController()
    }
    
    func monthlyStatsViewController() -> UIViewController! {
        return UIViewController()
    }
    
    func yearlyStatsViewController() -> UIViewController! {
        return UIViewController()
    }
}

