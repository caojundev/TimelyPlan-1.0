//
//  HabitRecordsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

enum HabitRecordMoreType: Int, Codable, TPMenuRepresentable {
    
    case deleteRecords /// 删除记录
    
    var title: String {
        switch self {
        case .deleteRecords:
            return resGetString("Delete Records")
        }
    }
    
    var iconName: String? {
        switch self {
        case .deleteRecords:
            return "shred_24"
        }
    }
    
    var actionStyle: TPMenuActionStyle {
        switch self {
        case .deleteRecords:
            return .destructive
        }
    }
}

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
        
        let deleteMenuItem = TPMenuItem.item(with: HabitRecordMoreType.allCases) { type, action in
            action.handler = { [weak self] _ in
                self?.selectDeleteRecords()
            }
        }
        
        let menuList = TPMenuListViewController()
        menuList.menuContentWidth = 180.0
        menuList.menuItems = [sortMenuItem, deleteMenuItem]
        let sourceView = moreBarButtonItem.moreButton
        menuList.popoverShow(from: sourceView,
                             sourceRect: sourceView.bounds,
                             isSourceViewCovered: false,
                             preferredPosition: .bottomLeft)
    }
    
    private func selectDeleteRecords() {
        guard let contentVC = self.contentViewController as? HabitRecordListViewController else {
            return
        }
        
        let date = contentVC.date
        let completion: ((Bool) -> Void) = { confirmed in
            if confirmed {
                habit.deleteRecords(in: contentVC.dateRange)
            }
        }
        
        switch self.type {
        case .day:
            HabitPresenter.confirmDayRecordsDeletion(on: date, completion: completion)
        case .week:
            let firstWeekday = contentVC.firstWeekday
            HabitPresenter.confirmWeekRecordsDeletion(contains: date,
                                                      firstWeekday: firstWeekday,
                                                      completion: completion)
        case .month:
            HabitPresenter.confirmMonthRecordsDeletion(contains: date, completion: completion)
        default:
            break
        }
    }
    
    private func selectSortOrder(_ sortOrder: TPSortOrder) {
        guard HabitSetting.shared.recordSortOrder != sortOrder else {
            return
        }
        
        HabitSetting.shared.recordSortOrder = sortOrder
    }
}
