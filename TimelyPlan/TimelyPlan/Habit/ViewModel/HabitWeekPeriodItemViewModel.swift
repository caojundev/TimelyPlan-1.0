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
        HabitRepository.fetchScheduledPeriodItems(in: period,
                                        includeSamples: false,
                                        completion: completion)
    }
}
