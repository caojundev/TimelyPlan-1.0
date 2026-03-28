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
        let periodDate = self.date.startOfYear()
        let period = HabitDatePeriod(date: periodDate,
                                     mode: .year,
                                     firstWeekday: self.firstWeekday)
        let includeArchived = HabitSetting.shared.isReportShowArchived
        habit.fetchReportPeriodItems(in: period,
                                     includeArchived: includeArchived) { periodItems in
            let sectionController = HabitReportYearlySectionController(periodItems: periodItems, firstWeekday: self.firstWeekday)
            sectionController.imageCacher = self.imageCacher
            completion([sectionController])
        }
    }
    
}
