//
//  FocusRecordsViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/10/6.
//

import Foundation

class FocusRecordsViewController: StatsMainViewController {

    /// 任务
    var task: TaskRepresentable?
    
    /// 计时器
    var timer: FocusTimer?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        self.navigationItem.rightBarButtonItem = addBarButtonItem
    }
    
    init(task: TaskRepresentable? = nil,
         timer: FocusTimer? = nil,
         type: StatsType = .week,
         date: Date = .now) {
        self.task = task
        self.timer = timer
        super.init(type: type, allowTypes: [.day, .week, .month], date: date)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func dailyStatsViewController() -> UIViewController! {
        let vc = FocusRecordListViewController(type: .day, date: self.date)
        vc.timer = self.timer
        vc.task = self.task
        return vc
    }
    
    override func weeklyStatsViewController() -> UIViewController! {
        let firstWeekday: Weekday = Weekday.firstWeekday
        let vc = FocusRecordListViewController(type: .week, date: self.date, firstWeekday: firstWeekday)
        vc.timer = self.timer
        vc.task = self.task
        return vc
    }
    
    override func monthlyStatsViewController() -> UIViewController! {
        let vc = FocusRecordListViewController(type: .month, date: self.date)
        vc.timer = self.timer
        vc.task = self.task
        return vc
    }
    
    override func clickAdd() {
        TPImpactFeedback.impactWithSoftStyle()
         
        let timerController = FocusUserTimerController()
        timerController.addRecordManually(forTimer: timer)
    }

    
}
