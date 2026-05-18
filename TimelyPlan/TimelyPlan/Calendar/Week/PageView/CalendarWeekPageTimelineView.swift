//
//  CalendarWeekPageTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

class CalendarWeekPageTimelineView: CalendarPageTimelineView {
    
    /// 周天日期视图
    private lazy var weekDaysView: CalendarWeekDaysView = {
        return CalendarWeekDaysView()
    }()
    
    init(frame: CGRect) {
        super.init(frame: frame, mode: .week)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubviews() {
        super.setupSubviews()
        addSubview(weekDaysView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        weekDaysView.width = width
        weekDaysView.height = CalendarWeekDaysView.defaultHeight
        
        eventsView.width = width
        eventsView.height = height - weekDaysView.height
        eventsView.top = weekDaysView.bottom
    }
    
    override func loadEvents(with firstDate: Date) {
        super.loadEvents(with: firstDate)
        reloadWeekDays()
    }
    
    func reloadWeekDays() {
        weekDaysView.weekStartDate = firstDate
        weekDaysView.showLunar = showLunar
        weekDaysView.showChineseHolidays = showChineseHolidays
        weekDaysView.reloadData()
    }
    
}
