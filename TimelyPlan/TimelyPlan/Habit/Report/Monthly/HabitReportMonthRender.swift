//
//  HabitReportMonthRender.swift
//  TimelyPlan
//
//  Created by caojun on 2026/3/17.
//

import Foundation

class HabitReportMonthRender: HabitReportChartRender {

    typealias ItemPosition = (row: Int, col: Int)
    
    var weeksCount: Int {
        return self.dates.count / DAYS_PER_WEEK
    }

    override func datesOfThisRange() -> [Date] {
        return self.date.calendarMonthDays(firstWeekday: firstWeekday)
    }

    override func canvasSize() -> CGSize {
        let width = CGFloat(DAYS_PER_WEEK) * (itemSize.width + itemMargin) + itemMargin
        let weeksCount = self.dates.count / DAYS_PER_WEEK
        let height = CGFloat(weeksCount) * (itemSize.height + lineSpacing) + lineSpacing
        return CGSize(width: width, height: height)
    }

    override func dayFrame(at index: Int) -> CGRect {
        let positon = position(at: index)
        return dayFrame(of: positon)
    }
    
    func position(at index: Int) -> ItemPosition {
        let row = index / DAYS_PER_WEEK
        let col = index % DAYS_PER_WEEK
        return (row, col)
    }

    private func dayFrame(of position: ItemPosition) -> CGRect {
        let x = CGFloat(position.col) * (itemMargin + itemSize.width) + itemMargin
        let y = CGFloat(position.row) * (lineSpacing + itemSize.height) + lineSpacing
        return CGRect(x: x, y: y, size: itemSize)
    }
    
    override func shouldDrawDate(_ date: Date) -> Bool {
        return date.isInSameMonthAs(self.date)
    }
}
