//
//  HabitReportMonthlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitReportMonthlyViewController: HabitReportContentViewController {
  
    init(date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(type: .month, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        let period = HabitDatePeriod(date: self.date,
                                     mode: .month,
                                     firstWeekday: self.firstWeekday)
        habit.fetchPeriodTasks(in: period) { periodTasks in
            let sectionController = HabitReportMonthlySectionController(periodTasks: periodTasks,
                                                                       firstWeekday: self.firstWeekday)
            completion([sectionController])
        }
    }
}
