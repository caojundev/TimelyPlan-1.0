//
//  HabitReportYearlyMonthRender.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/18.
//

import Foundation

class HabitReportYearlyMonthRender: HabitReportMonthRender {
    
    override func canvasSize() -> CGSize {
        let size = super.canvasSize()
        return CGSize(width: size.height, height: size.width)
    }
    
    override func position(at index: Int) -> HabitReportMonthRender.ItemPosition {
        let col = index / DAYS_PER_WEEK
        let row = index % DAYS_PER_WEEK
        return (row, col)
    }
    
}
