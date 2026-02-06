//
//  TPPreviousNextWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/27.
//

import UIKit

class TPPreviousNextWeekView: TPPreviousNextDateView {
    
    var firstWeekday: Weekday = .firstWeekday {
        didSet {
            updateCurrentDateTitle()
        }
    }
    
    init(frame: CGRect = .zero, firstWeekday: Weekday = .firstWeekday) {
        self.firstWeekday = firstWeekday
        super.init(frame: frame)
        self.updateCurrentDateTitle()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var dateRange: DateRange {
        return self.date.rangeOfThisWeek(firstWeekday: firstWeekday)
    }
    
    override func title(for date: Date) -> String? {
        let range = date.rangeOfThisWeek(firstWeekday: firstWeekday)
        guard let startDate = range.startDate, let endDate = range.endDate else {
            return nil
        }
        
        return "\(startDate.monthDayShortWeekdaySymbolString) - \(endDate.monthDayShortWeekdaySymbolString)"
    }
    
    override func canChange(fromDate: Date, toDate: Date) -> Bool {
        guard super.canChange(fromDate: fromDate, toDate: toDate) else {
            return false
        }
        
        return !fromDate.isInSameDayAs(toDate)
    }
    
    override func previousDate() -> Date? {
        return date.dateByAddingWeeks(-1)
    }
    
    override func nextDate() -> Date? {
        return date.dateByAddingWeeks(1)
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
