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
    
    func pageTimelineView(_ view: CalendarPageTimelineView, didTapEvent event: CalendarEvent)
    
    func pageTimelineView(_ view: CalendarPageTimelineView, didTapLocation location: CGPoint, onDate date: Date)
    
    /// 单击全天更多
    func pageTimelineView(_ view: CalendarPageTimelineView, didTapAllDayMoreOnDate date: Date)
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
    private let eventsViewModel = CalendarEventsViewModel()
    
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
        eventsViewModel.onEventsChanged = { [weak self] in
            self?.eventsChanged()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        eventsView.frame = bounds
    }
    
    private func eventsChanged() {
        guard let firstDate = firstDate, eventsViewModel.range == .range(with: firstDate, mode: mode) else {
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
        eventsView.firstDate = firstDate
        eventsViewModel.loadEvents(in: .range(with: firstDate, mode: mode))
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        eventsView.didChangeVisibleOffset(offset)
    }
    
    func maxRowForAllDayView(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return eventsView.maxRowForAllDayView(in: dateRange)
    }
    
    // MARK: - CalendarPageEventsViewDelegate
    func allDayEventsForPageEventsView(_ view: CalendarPageEventsView) -> [CalendarEvent]? {
        return eventsViewModel.events?.allDayEvents
    }
    
    func pageEventsView(_ view: CalendarPageEventsView, timedEventsOnDate date: Date) -> [CalendarEvent]? {
        return eventsViewModel.events?.timedEvents
    }
    
    func pageEventsView(_ view: CalendarPageEventsView, longPressEvent event: CalendarEvent) {
        delegate?.pageTimelineView(self, longPressEvent: event)
    }
    
    func pageEventsView(_ view: CalendarPageEventsView, didTapEvent event: CalendarEvent) {
        delegate?.pageTimelineView(self, didTapEvent: event)
    }
    
    func pageEventsView(_ view: CalendarPageEventsView, didTapLocation location: CGPoint, onDate date: Date) {
        delegate?.pageTimelineView(self, didTapLocation: location, onDate: date)
    }
    
    func pageEventsView(_ view: CalendarPageEventsView, didTapAllDayMoreOnDate date: Date) {
        delegate?.pageTimelineView(self, didTapAllDayMoreOnDate: date)
    }
}
