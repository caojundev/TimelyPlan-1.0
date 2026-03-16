//
//  HabitStatusPieChartSectionController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/16.
//

import Foundation

class HabitStatusPieChartSectionController: PieChartSectionController {
    
    let periodTask: HabitPeriodTask
    
    init(periodTask: HabitPeriodTask) {
        self.periodTask = periodTask
        super.init()
        var recordDays: Int = 0
        let pieVisual = periodTask.statusDayCountPieVisual(&recordDays)
        self.visual = pieVisual

        self.cellItem.headerTitle = resGetString("Status Days")
        if recordDays == 0 {
            self.cellItem.innerTitleConfig.font = .boldSystemFont(ofSize: 18.0)
            self.cellItem.innerTitle = resGetString("No Data")
            self.cellItem.innerSubtitle = nil
        } else {
            self.cellItem.innerTitleConfig.font = .boldSystemFont(ofSize: 26.0)
            self.cellItem.innerTitle = "\(recordDays)"
            self.cellItem.innerSubtitle = resGetString("Record Days")
        }
    }
}
