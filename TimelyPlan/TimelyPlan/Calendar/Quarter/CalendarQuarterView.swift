//
//  CalendarQuarterView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/5.
//

import Foundation
import UIKit

class CalendarQuarterView: CalendarMonthView,
                           CalendarQuarterWeekViewDelegate {
    
    override var nearWeeksCount: Int {
        return 40
    }
    
    override var minimumItemHeight: CGFloat {
        return 50.0
    }
    
    override func reloadWeekNumber() {
        let visibleCells = adapter.visibleCells as! [CalendarQuarterWeekCell]
        for cell in visibleCells {
            let weekView = cell.weekView
            weekView.showWeekNumber = showWeekNumber
        }
    }
    
    override func reloadWeekDays() {
        let visibleCells = adapter.visibleCells as! [CalendarQuarterWeekCell]
        for cell in visibleCells {
            let weekView = cell.weekView
            weekView.showLunar = showLunar
            weekView.showChineseHolidays = showChineseHolidays
            weekView.reloadWeekDays()
        }
    }
    
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarQuarterWeekCell.self
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarQuarterWeekCell,
              let date = adapter.item(at: indexPath) as? Date else {
            return
        }
        
        let weekView = cell.weekView
        weekView.showWeekNumber = showWeekNumber
        weekView.firstWeekday = firstWeekday
        weekView.showLunar = showLunar
        weekView.showChineseHolidays = showChineseHolidays
        weekView.delegate = self
        
        if weekView.weekStartDate != date {
            weekView.loadEvents(weekStartDate: date)
        }
    }
    
    
    // MARK: - CalendarQuarterWeekViewDelegate
    
    func calendarQuarterWeekView(_ weekView: CalendarQuarterWeekView, didTapDate date: Date) {
        delegate?.calendarMonthView(self, didTapDate: date)
    }
    
    func calendarQuarterWeekView(_ weekView: CalendarQuarterWeekView, didLongPressDate date: Date) {
        delegate?.calendarMonthView(self, didLongPressDate: date)
    }
}
