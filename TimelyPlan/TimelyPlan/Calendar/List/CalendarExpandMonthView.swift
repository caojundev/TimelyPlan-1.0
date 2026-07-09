//
//  CalendarExpandMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/7.
//

import Foundation
import UIKit

class CalendarExpandMonthView: TPCalendarScrollableMonthView {
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarExpandMonthCell.self
    }

    override func adapter(_ adapter: TPCollectionViewAdapter, didDequeCell cell: UICollectionViewCell, at indexPath: IndexPath) {
        guard let cell = cell as? CalendarExpandMonthCell else {
            return
        }
        
        let dateComponents = adapter.item(at: indexPath) as! DateComponents
        let monthView = cell.monthView
        monthView.delegate = delegate
        monthView.selection = selection
        monthView.configure(firstWeekday: firstWeekday,
                            visibleDateComponents: dateComponents,
                            eventsProvider: eventsProvider)
    }
}

class CalendarExpandMonthCell: TPCollectionCell {
    
    private(set) lazy var  monthView: CalendarExpandSingleMonthView = {
        return CalendarExpandSingleMonthView(frame: bounds)
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(monthView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthView.frame = bounds
    }
}

class CalendarExpandSingleMonthView: TPCalendarMonthView {
    
    override func eventRange() -> DateInterval? {
        guard let allItems = adapter.allItems() as? [DateComponents],
              let from = allItems.first,
                let to = allItems.last else {
            return nil
        }
        
        guard let fromDate = Date.dateFromComponents(from),
              let toDate = Date.dateFromComponents(to) else {
                  return nil
              }
        
        return DateInterval(start: fromDate.startOfDay(),
                            end: toDate.endOfDay())
    }
    
    override func shouldHideCell(for dateComponents: DateComponents) -> Bool {
        return false
    }
    
    // MARK: - Data Source
    override func adapter(_ adapter: TPCollectionViewAdapter, itemsForSectionObject sectionObject: ListDiffable) -> [ListDiffable]? {
        
        /// 获取当前月份的日期
        let monthDate = Date.dateFromComponents(visibleDateComponents)!
        let monthDates = monthDate.calendarGridMonthDates(firstWeekday: firstWeekday)
        return monthDates.map {$0.yearMonthDayComponents} as [NSDateComponents]
    }
    
    // MARK: - Delegate    
    override func adapter(_ adapter: TPCollectionViewAdapter, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth = floor(bounds.width / CGFloat(DAYS_PER_WEEK))
        let itemHeight = 60.0
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        let components = adapter.item(at: indexPath) as! DateComponents
        let selectionsHighlight = selection?.shouldHighlightDate(components) ?? true
        return selectionsHighlight
    }
}
