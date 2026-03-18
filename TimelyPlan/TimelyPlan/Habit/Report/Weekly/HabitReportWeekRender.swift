//
//  HabitReportWeekRender.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/18.
//

import Foundation

class HabitReportWeekRender: HabitReportChartRender {

    var contentSize: CGSize = .zero
    
    override func datesOfThisRange() -> [Date] {
        return self.date.thisWeekDays(firstWeekday: self.firstWeekday)
    }
    
    override func canvasSize() -> CGSize {
        return contentSize
    }
    
    override func dayFrame(at index: Int) -> CGRect {
        let size = canvasSize()
        let dayWidth = size.width / CGFloat(DAYS_PER_WEEK)
        let x = CGFloat(index) * dayWidth + dayWidth / 2.0 - itemSize.halfWidth
        let y = (size.height - itemSize.height) / 2.0
        return CGRect(x: x, y: y, size: itemSize)
    }
}
