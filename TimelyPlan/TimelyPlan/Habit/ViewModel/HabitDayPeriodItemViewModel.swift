//
//  HabitDayPeriodItemViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/30.
//

import Foundation

class HabitDayPeriodItemViewModel: HabitPeriodItemViewModel {

    override init() {
        super.init()
        self.updatePlaceholder()
    }
    
    func setFilterType(_ filterType: HabitTaskFilterType) {
        guard self.filterType != filterType else {
            return
        }
        
        self.filterType = filterType
        self.updatePlaceholder()
        self.loadGroups()
    }
    
    /// 更新占位视图
    private func updatePlaceholder() {
        var title: String?
        switch filterType {
        case .all:
            title = resGetString("No Habit Today")
        case .todo:
            title = resGetString("No To-do Habit Today")
        case .completed:
            title = resGetString("No Completed Habit Today")
        case .skipped:
            title = resGetString("No Skipped Habit Today")
        case .failed:
            title = resGetString("No Failed Habit Today")
        }
        
        placeholderProvider.emptyTitle = title
        placeholderProvider.emptyImage = resGetImage("habit_plceholder_task_80")
    }

    override func fetchPeriodItems(in period: HabitDatePeriod, completion: @escaping ([HabitPeriodItem]?) -> Void) {
        habit.fetchScheduledPeriodItems(on: period.date,
                                        includeSamples: false,
                                        completion: completion)
    }
}


/*
extension HabitHomeDayViewController: HabitTaskProcessorDelegate,
                                        HabitRecordProcessorDelegate {
    
    // MARK: - HabitRecordProcessorDelegate
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        self.groupProvider.updateHabitRecord(record, for: task, on: date)
        self.updateCell(for: task, with: change)
        let status = task.status(with: record)
        if status != .inProgress {
            callback(after: 0.4) {
                self.listView.asyncPerformUpdate(forceRefresh: false)
            }
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        guard period.contains(self.date) else {
            return
        }
        
        self.groupProvider.deleteHabitRecords(for: task, in: period)
        self.updateCell(for: task, with: nil)
        callback(after: 0.4) {
            self.listView.asyncPerformUpdate(forceRefresh: false)
        }
    }
    
    private func updateCell(for task: HabitTask, with change: HabitRecordChange?) {
        guard let cell = listView.cell(for: task) as? HabitHomeDayListCell else {
            return
        }
        
        cell.updateRecord(with: change, animated: true)
    }
}
*/
