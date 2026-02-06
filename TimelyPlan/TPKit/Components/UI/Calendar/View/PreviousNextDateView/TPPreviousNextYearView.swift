//
//  TPPreviousNextYearView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/9/27.
//

import UIKit

class TPPreviousNextYearView: TPPreviousNextDateView {

    override var dateRange: DateRange {
        return self.date.rangeOfThisYear()
    }
    
    override func validDate(for date: Date) -> Date {
        if let date = date.yearDate {
            return date
        }
        
        return date
    }
    
    override func title(for date: Date) -> String? {
        return date.yearString
    }
    
    override func canChange(fromDate: Date, toDate: Date) -> Bool {
        guard super.canChange(fromDate: fromDate, toDate: toDate) else {
            return false
        }
        
        return !fromDate.isInSameYearAs(toDate)
    }
    
    override func previousDate() -> Date? {
        return date.dateByAddingYears(-1)
    }
    
    override func nextDate() -> Date? {
        return date.dateByAddingYears(1)
    }
    
    override func didClickCurrent(_ button: UIButton) {
        super.didClickCurrent(button)
        
        let vc = TPYearMonthDatePickerViewController(mode: .yearOnly)
        vc.date = date
        vc.didPickDate = { date in
            self.didSelectDate(date)
        }
        
        vc.popoverShow(from: self, preferredPosition: .bottomCenter)
    }

}
