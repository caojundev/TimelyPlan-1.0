//
//  TodoStatsMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class TodoStatsMainViewController: StatsMainViewController {

    init(type: StatsType = .week, date: Date = .now) {
        let allowTypes: [StatsType] = [.week, .month, .year]
        super.init(type: type, allowTypes: allowTypes, date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let firstWeekday = Weekday.monday
        let vc = TodoStatsWeeklyViewController(date: date, firstWeekday: firstWeekday)
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = TodoStatsMonthlyViewController(date: date)
        return vc
    }
    
    override func yearlyStatsViewController() -> UIViewController! {
        let vc = TodoStatsYearlyViewController(date: date)
        return vc
    }

}
