//
//  HabitStatsContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation

class HabitStatsContentViewController: StatsContentViewController {
    
    /// 任务
    var task: HabitTask
    
    init(task: HabitTask,
          type: StatsType,
          date: Date = .now,
          firstWeekday: Weekday = .firstWeekday) {
        self.task = task
        super.init(type: type, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.backViewMargins = UIEdgeInsets(top: 0.0, left: 16.0, bottom: 90.0, right: 16.0)
    }
}
