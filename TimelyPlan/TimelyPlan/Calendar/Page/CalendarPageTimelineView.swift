//
//  CalendarPageTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

protocol CalendarPageTimelineViewDelegate: AnyObject {
    
    func pageTimelineViewDidLoadAllDayEvents(_ view: CalendarPageTimelineView)
    
    func pageTimelineView(_ view: CalendarPageTimelineView, longPressEvent event: CalendarEvent)
    
    func pageTimelineView(_ view: CalendarPageTimelineView, didTapLocation location: CGPoint, onDate date: Date)
}

class CalendarPageTimelineView: UIView, CalendarPageEventsViewDelegate {
    
    /// 代理对象
    weak var delegate: CalendarPageTimelineViewDelegate?
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true
    
    /// 开始日
    var firstDate: Date?
    
    /// 事件视图
    private(set) lazy var eventsView: CalendarPageEventsView = {
        let view = CalendarPageEventsView(frame: bounds, mode: mode)
        view.delegate = self
        return view
    }()
    
    /// 事件供应者
    private let eventsProvider = CalendarWeekEventsProvider()
    
    let mode: CalendarPageMode
    
    init(frame: CGRect, mode: CalendarPageMode) {
        self.mode = mode
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        addSubview(eventsView)
        eventsProvider.eventsDidChange = { [weak self] in
            self?.eventsChanged()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventsView.frame = bounds
    }
    
    private func eventsChanged() {
        guard let firstDate = firstDate, eventsProvider.contains(date: firstDate) else {
            return
        }
        
        DispatchQueue.main.async {
            self.eventsView.reloadData()
            self.allDayEventsDidLoaded()
        }
    }
    
    private func allDayEventsDidLoaded() {
        delegate?.pageTimelineViewDidLoadAllDayEvents(self)
    }
    
    func reset() {
        eventsView.reset()
    }
    
    func loadEvents(with firstDate: Date) {
        self.firstDate = firstDate
        if eventsView.firstDate != firstDate {
            eventsView.firstDate = firstDate
            eventsView.reset()
        }
        
        eventsProvider.loadEvents(weekStartDate: firstDate)
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        eventsView.didChangeVisibleOffset(offset)
    }
    
    func maxRowForAllDayView(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return eventsView.maxRowForAllDayView(in: dateRange)
    }
    
    // MARK: - CalendarPageEventsViewDelegate
    func allDayEventsForPageEventsView(_ view: CalendarPageEventsView) -> [CalendarEvent]? {
        guard let date = view.firstDate else {
            return nil
        }
        
        var events = [CalendarEvent]()
        var event = CalendarEvent(name: "事件名称1",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(2)!)
        events.append(event)

        event = CalendarEvent(name: "事件名称2",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(2)!,
                                  endDate: date.dateByAddingDays(4)!)
        events.append(event)

        event = CalendarEvent(name: "事件名称3",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(3)!,
                                  endDate: date.dateByAddingDays(3)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称4",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(4)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称5",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称6",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(4)!,
                                  endDate: date.dateByAddingDays(5)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称7",
                              color: CalendarEventColor.random,
                              startDate: date,
                              endDate: date.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称8",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称9",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称10",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(1)!,
                                  endDate: date.dateByAddingDays(2)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称11",
                                  color: CalendarEventColor.random,
                                    startDate: date.dateByAddingDays(2)!,
                                  endDate: date.dateByAddingDays(2)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称12",
                              color: CalendarEventColor.random,
                              startDate: date,
                              endDate: date.dateByAddingDays(1)!)
        events.append(event)
        
        event = CalendarEvent(name: "事件名称13",
                              color: CalendarEventColor.random,
                              startDate: date,
                              endDate: date.dateByAddingDays(1)!)
        events.append(event)
        
        return events
    }
    
    func pageEventsView(_ view: CalendarPageEventsView, timedEventsOnDate date: Date) -> [CalendarEvent]? {
        return eventsProvider.events
    }
    
    func pageEventsView(_ view: CalendarPageEventsView, longPressEvent event: CalendarEvent) {
        delegate?.pageTimelineView(self, longPressEvent: event)
    }
    
    func pageEventsView(_ view: CalendarPageEventsView, didTapLocation location: CGPoint, onDate date: Date) {
        delegate?.pageTimelineView(self, didTapLocation: location, onDate: date)
    }
}
