//
//  HabitReportYearlyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitReportYearlyViewController: HabitReportContentViewController {
    
    init(date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(type: .year, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        let period = HabitDatePeriod(date: self.date,
                                     mode: .year,
                                     firstWeekday: self.firstWeekday)
        habit.fetchPeriodTasks(in: period) { periodTasks in
            let sectionController = HabitReportYearlySectionController(periodTasks: periodTasks, firstWeekday: self.firstWeekday)
            completion([sectionController])
        }
    }
    
}
