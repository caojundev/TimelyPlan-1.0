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
