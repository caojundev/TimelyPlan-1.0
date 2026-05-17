//
//  CalendarWeekEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/13.
//

import Foundation
import UIKit

protocol CalendarWeekEventsViewDelegate: AnyObject {
    
    /// 周全天事项
    func allDayEventsForWeekEventsView(_ view: CalendarWeekEventsView) -> [CalendarEvent]?
    
    /// 指定日期定时事项
    func weekEventsView(_ view: CalendarWeekEventsView, timedEventsOnDate date: Date) -> [CalendarEvent]?
    
    func weekEventsView(_ view: CalendarWeekEventsView, longPressEvent event: CalendarEvent)
    
    func weekEventsView(_ view: CalendarWeekEventsView, didTapLocation location: CGPoint, onDate date: Date)
}

class CalendarWeekEventsView: UIView,
                              CalendarWeekTimelineEventsViewDelegate,
                              CalendarScrollSynchronizable {
    
    weak var delegate: CalendarWeekEventsViewDelegate?
    
    var weekStartDate: Date?
    
    var allDayHeight: CGFloat = 0.0 {
        didSet {
            if allDayHeight != oldValue {
                layoutAllDayView()
                updateContentInset()
            }
        }
    }
    
    var contentOffset: CGPoint {
        get {
            return timelineView.contentOffset
        }
        
        set {
            timelineView.contentOffset = newValue
        }
    }
    
    /// 滚动视图代理
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return timelineView.delegate
        }
        
        set {
            timelineView.delegate = newValue
        }
    }
    
    /// 全天事件视图
    private lazy var allDayView: CalendarWeekAllDayEventsView = {
        let view = CalendarWeekAllDayEventsView()
        return view
    }()
    
    /// 时间线视图
    private lazy var timelineView: CalendarWeekTimelineEventsView = {
        let view = CalendarWeekTimelineEventsView()
        view.eventDelegate = self
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(timelineView)
        addSubview(allDayView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timelineView.frame = bounds
        layoutAllDayView()
        updateContentInset()
    }
    
    private func layoutAllDayView() {
        allDayView.width = width
        allDayView.height = allDayHeight
        allDayView.origin = .zero
    }
    
    private func updateContentInset() {
        timelineView.contentInset = UIEdgeInsets(top: allDayHeight)
    }
    
    // MARK: - CalendarWeekTimelineEventsViewDelegate
    func weekTimelineEventsView(_ view: CalendarWeekTimelineEventsView, timedEventsOnDate date: Date) -> [CalendarEvent]? {
        return delegate?.weekEventsView(self, timedEventsOnDate: date)
    }
    
    func weekTimelineEventsView(_ view: CalendarWeekTimelineEventsView, longPressEvent event: CalendarEvent) {
        delegate?.weekEventsView(self, longPressEvent: event)
    }
    
    func weekTimelineEventsView(_ view: CalendarWeekTimelineEventsView, didTapLocation location: CGPoint, onDate date: Date) {
        delegate?.weekEventsView(self, didTapLocation: location, onDate: date)
    }
    
    // MARK: - Public Methods
    func reset() {
        allDayView.reset()
        timelineView.reset()
    }
    
    func reloadData() {
        guard let weekStartDate = weekStartDate else {
            reset()
            return
        }

        allDayView.weekStartDate = weekStartDate
        allDayView.events = delegate?.allDayEventsForWeekEventsView(self)
        allDayView.reloadData()
        
        timelineView.weekStartDate = weekStartDate
        timelineView.reloadData()
    }
    
    func maxRowForAllDayView(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return allDayView.maxRow(in: dateRange)
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        allDayView.didChangeVisibleOffset(offset)
    }
    
    func eventView(at point: CGPoint) -> CalendarEventView? {
        let convertedPoint = self.convert(point, toViewOrWindow: timelineView)
        return timelineView.eventView(at: convertedPoint)
    }
    
}

