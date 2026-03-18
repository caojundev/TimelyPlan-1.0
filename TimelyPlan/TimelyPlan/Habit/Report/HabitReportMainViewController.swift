//
//  HabitReportMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitReportMainViewController: StatsMainViewController {

    /// 更多菜单按钮
    private lazy var moreBarButtonItem: HabitReportMoreBarButtonItem = {
        let item = HabitReportMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.didSelectMoreMenuType(type)
        }
        
        return item
    }()
    
    let firstWeekday: Weekday
    
    init(type: StatsType = .month, date: Date = .now) {
        self.firstWeekday = HabitSetting.shared.firstWeekday
        let allowTypes: [StatsType] = [.week, .month, .year]
        super.init(type: type, allowTypes: allowTypes, date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = moreBarButtonItem
    }
    
    private func didSelectMoreMenuType(_ type: HabitReportMoreMenuType) {
        switch type {
        case .showArchived:
            let isReportShowArchived = !HabitSetting.shared.isReportShowArchived
            HabitSetting.shared.isReportShowArchived = isReportShowArchived
        }
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let vc = HabitReportWeeklyViewController(date: self.date,
                                                 firstWeekday: self.firstWeekday)
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = HabitReportMonthlyViewController(date: self.date,
                                                  firstWeekday: self.firstWeekday)
        return vc
    }
    
    override func yearlyStatsViewController() -> UIViewController! {
        let vc = HabitReportYearlyViewController(date: self.date,
                                                 firstWeekday: self.firstWeekday)
        return vc
    }
}
