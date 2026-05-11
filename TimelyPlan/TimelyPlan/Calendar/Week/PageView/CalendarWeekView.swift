//
//  CalendarWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/11.
//

import Foundation
import UIKit

protocol CalendarWeekViewDelegate: AnyObject {
    
    func calendarWeekViewDidLoadAllDayEvents(_ view: CalendarWeekView)
}

class CalendarWeekView: UIView, CalendarWeekEventsViewDelegate {
    
    /// 周天视图高度
    static var weekDaysViewHeight = 80.0

    /// 代理对象
    weak var delegate: CalendarWeekViewDelegate?
    
    /// 周开始日
    private var weekStartDate: Date? {
        didSet {
            weekDaysView.weekStartDate = weekStartDate
        }
    }

    /// 周天日期视图
    private let weekDaysView: CalendarWeekDaysView = {
        let view = CalendarWeekDaysView()
        return view
    }()
    
    /// 事件视图
    private(set) lazy var eventsView: CalendarWeekEventsView = {
        let view = CalendarWeekEventsView()
        view.delegate = self
        return view
    }()
    
    /// 事件供应者
    private let eventsProvider = CalendarWeekEventsProvider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(weekDaysView)
        addSubview(eventsView)
        eventsProvider.eventsDidChange = { [weak self] in
            self?.eventsChanged()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        weekDaysView.width = width
        weekDaysView.height = Self.weekDaysViewHeight
        
        eventsView.width = width
        eventsView.height = height - Self.weekDaysViewHeight
        eventsView.top = weekDaysView.bottom
    }
    
    private func eventsChanged() {
        guard weekStartDate == eventsProvider.weekStartDate else {
            return
        }
        
        DispatchQueue.main.async {
            self.eventsView.reloadData()
            self.allDayEventsDidLoaded()
        }
    }
    
    private func allDayEventsDidLoaded() {
        self.delegate?.calendarWeekViewDidLoadAllDayEvents(self)
    }
    
    func reset() {
        eventsView.reset()
    }
    
    func loadEvents(with weekStartDate: Date) {
        self.weekStartDate = weekStartDate
        
        self.eventsView.reset()
        self.eventsView.weekStartDate = weekStartDate
        self.eventsProvider.loadEvents(with: weekStartDate)
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        eventsView.didChangeVisibleOffset(offset)
    }
    
    func maxRowForAllDayView(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return eventsView.maxRowForAllDayView(in: dateRange)
    }
    
    // MARK: - CalendarWeekEventsViewDelegate
    func allDayEventsForWeekEventsView(_ view: CalendarWeekEventsView) -> [CalendarEvent]? {
        return eventsProvider.allDayEvents
    }
    
    func weekEventsView(_ view: CalendarWeekEventsView, timedEventsOnDate date: Date) -> [CalendarEvent]? {
        let calendar = Calendar.current
        let now = date
        let events = [
            CalendarEvent(name: "晨会",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 0, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 9, minute: 15, second: 0, of: now)!),
            CalendarEvent(name: "产品评审",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 10, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 40, second: 0, of: now)!),
            
            CalendarEvent(name: "开发 Coding",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 9, minute: 40, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 30, second: 0, of: now)!),
            CalendarEvent(name: "阅读",
                          color: CalendarEventColor.random,
                          startDate: calendar.date(bySettingHour: 10, minute: 05, second: 0, of: now)!,
                          endDate: calendar.date(bySettingHour: 10, minute: 50, second: 0, of: now)!)
        ]
        
        return events
        return eventsProvider.timedEvents
    }
}
