//
//  TPPreviousNextDayView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/13.
//

import Foundation

class TPPreviousNextDayView: TPPreviousNextDateView {
    
    override var dateRange: DateRange {
        return self.date.rangeOfThisDay()
    }
    
    override func validDate(for date: Date) -> Date {
        if let date = date.yearMonthDayDate {
            return date
        }
        
        return date
    }
    
    override func title(for date: Date) -> String? {
        return self.date.yearMonthDayWeekdaySymbolString(omitYear: true)
    }
    
    override func canChange(fromDate: Date, toDate: Date) -> Bool {
        guard super.canChange(fromDate: fromDate, toDate: toDate) else {
            return false
        }
        
        /// 非同一个天的日期可切换
        return !fromDate.isInSameDayAs(toDate)
    }
    
    override func previousDate() -> Date? {
        return date.dateByAddingDays(-1)
    }
    
    override func nextDate() -> Date? {
        return date.dateByAddingDays(1)
    }
    
    override func didClickCurrent(_ button: UIButton) {
        super.didClickCurrent(button)
        
        let calendarVC = TPCalendarViewController(date: self.date)
        calendarVC.didSelectDate = { date in
            self.didSelectDate(date)
        }
        
        calendarVC.popoverShow(from: self, preferredPosition: .bottomCenter)
    }

}
