//
//  FocusStatsMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/4/9.
//

import Foundation
import UIKit

class FocusStatsBaseViewController: StatsMainViewController {

    /// 任务
    var task: TaskRepresentable?
    
    /// 计时器
    var timer: FocusTimer?

    /// 是否可选分组类型
    var canSelectDetailGroupType: Bool = true

    /// 分组类型
    var detailGroupType: FocusStatsDetailGroupType = .timer
    
    /// 允许的分组类型
    var allowDetailGroupTypes = FocusStatsDetailGroupType.allCases
    
    init(task: TaskRepresentable? = nil, timer: FocusTimer? = nil, type: StatsType = .week, allowTypes: [StatsType] = StatsType.allCases, date: Date = .now) {
        self.task = task
        self.timer = timer
        super.init(type: type, allowTypes: allowTypes, date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func dailyStatsViewController() -> UIViewController! {
        let vc = FocusStatsDailyViewController(date: date)
        self.configureStatsContentViewController(vc)
        return vc
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let firstWeekday: Weekday = Weekday.firstWeekday
        let vc = FocusStatsWeeklyViewController(date: date, firstWeekday: firstWeekday)
        self.configureStatsContentViewController(vc)
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = FocusStatsMonthlyViewController(date: date)
        self.configureStatsContentViewController(vc)
        return vc
    }
    
    override func yearlyStatsViewController() -> UIViewController! {
        let vc = FocusStatsYearlyViewController(date: date)
        self.configureStatsContentViewController(vc)
        return vc
    }

    /// 配置视图控制器配置变量
    func configureStatsContentViewController(_ vc: FocusStatsContentViewController) {
        vc.task = task
        vc.timer = timer
        vc.canSelectGroupType = canSelectDetailGroupType
        vc.didSelectGroupType = {[weak self] groupType in
            self?.detailGroupType = groupType
        }
        
        var detailGroupType = detailGroupType
        if !allowDetailGroupTypes.contains(detailGroupType) {
            detailGroupType = allowDetailGroupTypes[0]
        }
        
        vc.groupType = detailGroupType
    }
}
