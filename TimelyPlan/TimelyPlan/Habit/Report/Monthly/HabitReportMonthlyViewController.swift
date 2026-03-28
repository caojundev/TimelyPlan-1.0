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
        let periodDate = self.date.startOfMonth()
        let period = HabitDatePeriod(date: periodDate, mode: .month, firstWeekday: self.firstWeekday)
        let includeArchived = HabitSetting.shared.isReportShowArchived
        habit.fetchReportPeriodItems(in: period,
                                     includeArchived: includeArchived) { periodItems in
            let sectionController = HabitReportMonthlySectionController(periodItems: periodItems,
                                                                       firstWeekday: self.firstWeekday)
            sectionController.imageCacher = self.imageCacher
            completion([sectionController])
        }
    }
}
