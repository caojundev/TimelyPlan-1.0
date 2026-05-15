//
//  HabitRecordsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class HabitRecordsViewController: StatsMainViewController {
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: TPMoreBarButtonItem = {
        let item = TPMoreBarButtonItem()
        item.didClickMore = { [weak self] in
            self?.showMoreMenu()
        }
        
        return item
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = moreBarButtonItem
    }
    
    init(type: StatsType = .week,
         date: Date = .now) {
        super.init(type: type, allowTypes: [.day, .week, .month], date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func dailyStatsViewController() -> UIViewController! {
        let vc = HabitRecordListViewController(type: .day, date: self.date)
        return vc
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let firstWeekday = HabitSetting.shared.firstWeekday
        let vc = HabitRecordListViewController(type: .week, date: self.date, firstWeekday: firstWeekday)
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = HabitRecordListViewController(type: .month, date: self.date)
        return vc
    }
    
    private func showMoreMenu() {
        let sortOrder = HabitSetting.shared.recordSortOrder
        let sortMenuItem = TPMenuItem.item(with: TPSortOrder.allCases) { order, action in
            action.handleBeforeDismiss = true
            switch order {
            case .ascending:
                action.isChecked = sortOrder == .ascending
            case .descending:
                action.isChecked = sortOrder == .descending
            }
            
            action.handler = { [weak self] _ in
                self?.selectSortOrder(order)
            }
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = 180.0
        menuList.menuItems = [sortMenuItem]
        let sourceView = moreBarButtonItem.moreButton
        menuList.popoverShow(from: sourceView,
                             sourceRect: sourceView.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .bottomLeft)
    }
    
    
    private func selectSortOrder(_ sortOrder: TPSortOrder) {
        guard HabitSetting.shared.recordSortOrder != sortOrder else {
            return
        }
        
        HabitSetting.shared.recordSortOrder = sortOrder
    }
}
