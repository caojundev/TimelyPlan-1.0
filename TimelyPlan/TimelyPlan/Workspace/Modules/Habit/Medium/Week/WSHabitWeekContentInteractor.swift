//
//  WSHabitWeekContentInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/27.
//

import Foundation

// MARK: - 内容交互器

/// 习惯·中·周进度的内容交互器。展示本周七天的状态与进度。
class WSHabitWeekContentInteractor: WSHabitPeriodContentInteractor {
    
    override func fetchPeriods(containing date: Date) -> [HabitDatePeriod] {
        return [weekPeriod(containing: date)]
    }
    
    override func displayDates(containing date: Date) -> [Date] {
        return weekPeriod(containing: date).weekDaysPeriods().map { $0.date }
    }
}
