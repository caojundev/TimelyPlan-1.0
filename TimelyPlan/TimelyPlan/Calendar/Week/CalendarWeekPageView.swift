//
//  CalendarWeekPageView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/8.
//

import Foundation
import UIKit

class CalendarWeekPageView: CalendarPageView {
    
    /// 显示周数
    var showWeekNumber: Bool = true {
        didSet {
            weekNumberView.showWeekNumber = showWeekNumber
        }
    }
    
    private let weekNumberView = CalendarWeekNumberContainerView()
    
    override func setupSubviews() {
        super.setupSubviews()
        weekNumberView.showWeekNumber = showWeekNumber
        addSubview(weekNumberView)
        addSeparator(position: .top)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let eventsFrame = eventsFrame()
        weekNumberView.width = eventsFrame.minX
        weekNumberView.height = eventsFrame.minY
    }
    
    /// 事项显示区域
    override func eventsFrame() -> CGRect {
        let weekDaysViewHeight = CalendarWeekDaysView.defaultHeight
        return CGRect(x: hoursViewWidth,
                      y: weekDaysViewHeight,
                      width: bounds.width - hoursViewWidth,
                      height: bounds.height - weekDaysViewHeight)
    }
    
    override func getPageStartDates() -> [Date] {
        let currentDate = visibleDate.startOfWeek(firstWeekday: firstWeekday)
        var dates: [Date] = [currentDate]
        for i in 1...nearItemsCount {
            let leftDate = currentDate.dateByAddingWeeks(-i)!
            dates.insert(leftDate, at: 0)
            let rightDate = currentDate.dateByAddingWeeks(i)!
            dates.append(rightDate)
        }
        
        return dates
    }
    
    override func adapter(_ adapter: TPCollectionViewAdapter, classForCellAt indexPath: IndexPath) -> AnyClass? {
        return CalendarWeekPageTimelineCell.self
    }
    
    // MARK: - Update
    private func updateWeekNumber() {
        guard let date = self.visibleDate else {
            return
        }
        
        weekNumberView.weekNumber = Calendar.weekNumber(for: date, firstWeekday: firstWeekday)
    }
    
    // MARK: - Public Methods
    override func reloadData() {
        super.reloadData()
        updateWeekNumber()
    }
    
    override func reloadData(animateStyle: SlideStyle) {
        super.reloadData(animateStyle: animateStyle)
        updateWeekNumber()
    }
    
    func reloadWeekDays() {
        let visibleCells = adapter.visibleCells as! [CalendarWeekPageTimelineCell]
        for cell in visibleCells {
            let timelineView = cell.weekPageTimelineView
            timelineView.showLunar = showLunar
            timelineView.showChineseHolidays = showChineseHolidays
            timelineView.reloadWeekDays()
        }
    }
    
    override func setVisibleDate(_ date: Date, animated: Bool) {
        super.setVisibleDate(date, animated: animated)
        updateWeekNumber()
    }
    
    override func goPreviousDay() {
        super.goPreviousDay()
        updateWeekNumber()
    }
    
    override func goNextDay() {
        super.goNextDay()
        updateWeekNumber()
    }
    
    // MARK: - Private Metehods
    private let preloadWeekOffset = 2
    
    override func shouldPerformUpdate() -> Bool {
        let currentWeekStartDate = visibleDate.startOfWeek(firstWeekday: firstWeekday)
        guard let indexPath = adapter.indexPath(of: currentWeekStartDate as NSDate) else {
            return true
        }
        
        let weekIndex = indexPath.item
        let visibleWeeksCount = collectionView.visibleCells.count
        if weekIndex >= preloadWeekOffset && weekIndex + visibleWeeksCount <= adapter.allItems().count - preloadWeekOffset {
            return false
        }

        return true
    }
}
