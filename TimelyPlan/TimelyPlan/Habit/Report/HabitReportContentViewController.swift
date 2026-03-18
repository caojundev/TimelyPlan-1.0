//
//  HabitReportContentViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation

class HabitReportContentViewController: StatsContentViewController,
                                        HabitRecordProcessorDelegate,
                                        SettingAgentObserver {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        habit.addUpdater(self, for: [.record])
        HabitSetting.shared.addObserver(self, forKey: .isReportShowArchived)
    }

    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for key: String) {
        if key == HabitSetting.Key.isReportShowArchived.name, habit.hasArchivedTask {
            /// 有已归档任务，重新加载数据
            reloadData()
        }
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
