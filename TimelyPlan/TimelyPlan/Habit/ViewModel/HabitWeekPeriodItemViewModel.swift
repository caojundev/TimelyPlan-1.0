//
//  HabitWeekPeriodItemViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/30.
//

import Foundation

class HabitWeekPeriodItemViewModel: HabitPeriodItemViewModel {
    
    override init() {
        super.init()
        self.placeholderProvider.emptyImage = resGetImage("habit_plceholder_task_80")
        self.placeholderProvider.emptyTitle = resGetString("No Habit This Week")
    }
    
    override func fetchPeriodItems(in period: HabitDatePeriod, completion: @escaping ([HabitPeriodItem]?) -> Void) {
        habit.fetchScheduledPeriodItems(in: period,
                                        includeSamples: false,
                                        completion: completion)
    }

}


/*
extension HabitHomeWeekViewController: HabitRecordProcessorDelegate {
    
    // MARK: - HabitRecordProcessorDelegate
    func didUpdateHabitRecord(_ record: HabitRecord, for task: HabitTask, on date: Date, with change: HabitRecordChange) {
        self.groupProvider.updateHabitRecord(record, for: task, on: date)
        if let cell = listView.cell(for: task) as? HabitHomeWeekListCell {
            cell.updateRecord(on: date, with: change, animated: true)
        }
    }
    
    func didDeleteHabitRecords(for task: HabitTask, in period: HabitDatePeriod) {
        self.groupProvider.deleteHabitRecords(for: task, in: period)
        if let cell = listView.cell(for: task) as? HabitHomeWeekListCell {
            cell.updateRecords(in: period, animated: true)
        }
    }
}
*/

