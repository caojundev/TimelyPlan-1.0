//
//  PreviousNextMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/12.
//

import Foundation

class TPPreviousNextMonthView: TPPreviousNextDateView {
    
    override var dateRange: DateRange {
        return self.date.rangeOfThisMonth()
    }
    
    override func validDate(for date: Date) -> Date {
        if let date = date.yearMonthDate {
            return date
        }
        
        return date
    }
    
    override func title(for date: Date) -> String? {
        let format: String = resGetString("MMMM yyyy")
        return date.stringWithFormat(format)
    }
    
    override func canChange(fromDate: Date, toDate: Date) -> Bool {
        guard super.canChange(fromDate: fromDate, toDate: toDate) else {
            return false
        }
        
        /// 非同一个月的日期可切换
        return !fromDate.isInSameMonthAs(toDate)
    }
    
    override func previousDate() -> Date? {
        return date.dateByAddingMonths(-1)
    }
    
    override func nextDate() -> Date? {
        return date.dateByAddingMonths(1)
    }
    
    override func didClickCurrent(_ button: UIButton) {
        super.didClickCurrent(button)
        
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = date
        datePickerVC.didPickDate = { date in
            self.didSelectDate(date)
        }
        
        datePickerVC.popoverShow(from: self, preferredPosition: .bottomCenter)
    }
}
