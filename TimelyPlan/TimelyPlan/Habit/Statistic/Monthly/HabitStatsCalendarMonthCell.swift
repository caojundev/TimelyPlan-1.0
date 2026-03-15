//
//  StatsMonthDaysCell.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/2.
//

import Foundation

class HabitStatsCalendarMonthCellItem: TPCollectionCellItem {
    
    weak var monthViewDelegate: TPCalendarMonthViewDelegate?
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday
    
    /// 周当中包含的日期
    var date: Date = Date()
    
    override var size: CGSize? {
        get {
            let count = date.calendarMonthDaysCount(firstWeekday: firstWeekday)
            var height = contentPadding.verticalLength
            height += HabitStatsCalendarMonthView.symbolsViewHeight
            height += CGFloat(count / DAYS_PER_WEEK) * HabitStatsCalendarMonthView.dayCellHeight
            return CGSize(width: .greatestFiniteMagnitude, height: height)
        }
        
        set {}
    }
    
    override init() {
        super.init()
        self.contentPadding = UIEdgeInsets(vertical: 15.0)
        self.registerClass = HabitStatsCalendarMonthCell.self
        self.canHighlight = false
    }
}

class HabitStatsCalendarMonthCell: TPCollectionCell {
    
    override var cellItem: TPCollectionCellItem? {
        didSet {
            reloadData()
        }
    }
    
    let monthView = HabitStatsCalendarMonthView()
    
    override func setupContentSubviews() {
        super.setupContentSubviews()
        contentView.addSubview(monthView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        monthView.frame = contentView.layoutFrame()
    }
    
    func reloadData() {
        let cellItem = cellItem as! HabitStatsCalendarMonthCellItem
        monthView.firstWeekday = cellItem.firstWeekday
        monthView.date = cellItem.date
        monthView.monthViewDelegate = cellItem.monthViewDelegate
        monthView.reloadData()
        setNeedsLayout()
    }
}
