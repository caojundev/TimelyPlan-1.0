//
//  HabitReportWeeklyViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/14.
//

import Foundation
import UIKit

class HabitReportWeeklyViewController: HabitReportContentViewController {
  
    init(date: Date = .now, firstWeekday: Weekday = .firstWeekday) {
        super.init(type: .week, date: date, firstWeekday: firstWeekday)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func fetchSectionControllers(completion: @escaping([TPCollectionBaseSectionController]) -> Void) {
        let period = HabitDatePeriod(date: self.date, mode: .week, firstWeekday: self.firstWeekday)
        let includeArchived = HabitSetting.shared.isReportShowArchived
        habit.fetchReportPeriodTasks(in: period,
                                     includeArchived: includeArchived) { periodTasks in
            let sectionController = HabitReportWeeklySectionController(periodTasks: periodTasks,
                                                                       firstWeekday: self.firstWeekday)
            completion([sectionController])
        }
    }
}
