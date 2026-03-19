//
//  HabitRecordsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class HabitRecordsViewController: StatsMainViewController {

    /// 记录排列顺序
    private var sortOrder = FocusStateStore.shared.recordListOrder
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: FocusRecordMoreBarButtonItem = {
        let item = FocusRecordMoreBarButtonItem()
        item.sortOrder = sortOrder
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(with: type)
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
        let vc = FocusRecordListViewController(type: .day, date: self.date)
        return vc
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let firstWeekday = FocusSetting.shared.firstWeekday
        let vc = FocusRecordListViewController(type: .week, date: self.date, firstWeekday: firstWeekday)
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = FocusRecordListViewController(type: .month, date: self.date)
        return vc
    }
    
    private func performMoreMenuAction(with actionType: FocusRecordMoreMenuType) {
    }
    
    private func selectSortOrder(_ sortOrder: FocusRecordSortOrder) {
//        guard self.sortOrder != sortOrder else {
//            return
//        }
//        
//        self.sortOrder = sortOrder
//        self.moreBarButtonItem.sortOrder = sortOrder
//        
//        /// 重新加载列表数据
//        if let vc = self.contentViewController as? FocusRecordListViewController {
//            vc.sortOrder = sortOrder
//            vc.reloadData()
//        }
//        
//        /// 保存到本地设置项
//        FocusStateStore.shared.recordListOrder = sortOrder
    }
    
}
