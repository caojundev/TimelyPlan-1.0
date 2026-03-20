//
//  HabitRecordsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class HabitRecordsViewController: StatsMainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
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
    
    private func performMoreMenuAction(with actionType: FocusRecordMoreMenuType) {
        
    }
}
