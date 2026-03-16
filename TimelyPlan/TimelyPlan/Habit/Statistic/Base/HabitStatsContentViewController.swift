//
//  HabitStatsContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation

class HabitStatsContentViewController: StatsContentViewController,
                                       HabitRecordProcessorDelegate {
    
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
        habit.addUpdater(self, for: [.record])
    }
    
    // MARK: - HabitRecordProcessorDelegate
    /// 通知习惯记录已更新
    func didUpdateHabitRecord(_ record: HabitRecord,
                              for task: HabitTask,
                              on date: Date,
                              with change: HabitRecordChange) {
        
    }
    
    /// 通知习惯记录删除
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        
    }
}
