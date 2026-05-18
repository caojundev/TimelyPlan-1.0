//
//  CalendarDayPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

class CalendarDayPageView: CalendarPageView {

    override init(frame: CGRect, visibleDate: Date = .now) {
        super.init(frame: frame, visibleDate: visibleDate)
        self.displayDays = 1
        self.pageDaysCount = 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 事项显示区域
    override func eventsFrame() -> CGRect {
        return CGRect(x: hoursViewWidth,
                      y: 0.0,
                      width: bounds.width - hoursViewWidth,
                      height: bounds.height)
    }
    
    override func getPageStartDates() -> [Date] {
        var dates: [Date] = [visibleDate]
        for i in 1...nearItemsCount {
            let leftDate = visibleDate.dateByAddingDays(-i)!
            dates.insert(leftDate, at: 0)
            let rightDate = visibleDate.dateByAddingDays(i)!
            dates.append(rightDate)
        }

        return dates
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarDayPageTimelineCell.self
    }
}
