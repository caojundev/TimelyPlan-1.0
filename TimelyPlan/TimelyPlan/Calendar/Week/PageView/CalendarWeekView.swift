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
    
    func calendarWeekView(_ view: CalendarWeekView, longPressEvent event: CalendarEvent)
    
    func calendarWeekView(_ view: CalendarWeekView, didTapLocation location: CGPoint, onDate date: Date)
}

class CalendarWeekView: UIView, CalendarWeekEventsViewDelegate {
    
    /// 周天视图高度
    static var weekDaysViewHeight = 80.0

    /// 代理对象
    weak var delegate: CalendarWeekViewDelegate?
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true
    
    /// 周开始日
    var weekStartDate: Date?
    
    /// 周天日期视图
    private lazy var weekDaysView: CalendarWeekDaysView = {
        return CalendarWeekDaysView()
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
        guard let weekStartDate = weekStartDate, eventsProvider.contains(date: weekStartDate) else {
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
    
    func reloadWeekDays() {
        weekDaysView.weekStartDate = weekStartDate
        weekDaysView.showLunar = showLunar
        weekDaysView.showChineseHolidays = showChineseHolidays
        weekDaysView.reloadData()
    }
    
    func loadEvents(with weekStartDate: Date) {
        self.weekStartDate = weekStartDate
        reloadWeekDays()
        if eventsView.weekStartDate != weekStartDate {
            eventsView.weekStartDate = weekStartDate
            eventsView.reset()
        }
        
        eventsProvider.loadEvents(weekStartDate: weekStartDate)
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        eventsView.didChangeVisibleOffset(offset)
    }
    
    func maxRowForAllDayView(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return eventsView.maxRowForAllDayView(in: dateRange)
    }
    
    // MARK: - CalendarWeekEventsViewDelegate
    func allDayEventsForWeekEventsView(_ view: CalendarWeekEventsView) -> [CalendarEvent]? {
        return nil
    }
    
    func weekEventsView(_ view: CalendarWeekEventsView, timedEventsOnDate date: Date) -> [CalendarEvent]? {
        print(date)
        return eventsProvider.events
    }

    func weekEventsView(_ view: CalendarWeekEventsView, longPressEvent event: CalendarEvent) {
        delegate?.calendarWeekView(self, longPressEvent: event)
    }
    
    func weekEventsView(_ view: CalendarWeekEventsView, didTapLocation location: CGPoint, onDate date: Date) {
        delegate?.calendarWeekView(self, didTapLocation: location, onDate: date)
    }
    
}
