//
//  CalendarEventsContentView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

protocol CalendarPageEventsViewDelegate: AnyObject {
    
    /// 周全天事项
    func allDayEventsForPageEventsView(_ view: CalendarPageEventsView) -> [CalendarEvent]?

    /// 指定日期定时事项
    func pageEventsView(_ view: CalendarPageEventsView, timedEventsOnDate date: Date) -> [CalendarEvent]?

    func pageEventsView(_ view: CalendarPageEventsView, longPressEvent event: CalendarEvent)

    func pageEventsView(_ view: CalendarPageEventsView, didTapEvent event: CalendarEvent)
    
    func pageEventsView(_ view: CalendarPageEventsView, didTapLocation location: CGPoint, onDate date: Date)
    
    /// 单击全天更多
    func pageEventsView(_ view: CalendarPageEventsView, didTapAllDayMoreOnDate date: Date)
}

/// 页面模式
enum CalendarPageMode {
    case day
    case week
}

class CalendarPageEventsView: UIView,
                              CalendarScrollSynchronizable,
                              CalendarPageAllDayEventsViewDelegate,
                              CalendarPageTimedEventsViewDelegate {
    
    /// 代理对象
    weak var delegate: CalendarPageEventsViewDelegate?
    
    /// 开始日期
    var firstDate: Date?
    
    /// 全天高度
    var allDayHeight: CGFloat = 0.0 {
        didSet {
            guard allDayHeight != oldValue else {
                return
            }
            
            layoutAllDayEventsView()
            updateContentInset()
        }
    }
    
    var contentOffset: CGPoint {
        get {
            return timedEventsView.contentOffset
        }
        
        set {
            timedEventsView.contentOffset = newValue
        }
    }

    /// 滚动视图代理
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return timedEventsView.scrollViewDelegate
        }
        
        set {
            timedEventsView.scrollViewDelegate = newValue
        }
    }

    /// 全天事件视图
    private lazy var allDayEventsView: CalendarPageAllDayEventsView = {
        let frame = CGRect(x: 0.0, y: 0.0, width: bounds.width, height: 0.0)
        let view = CalendarPageAllDayEventsView(frame: frame, mode: self.mode)
        view.delegate = self
        return view
    }()
    
    /// 非全天事项视图
    private lazy var timedEventsView: CalendarPageTimedEventsView = {
        let view = CalendarPageTimedEventsView(frame: bounds, mode: self.mode)
        view.delegate = self
        return view
    }()
    
    let mode: CalendarPageMode
    
    init(frame: CGRect, mode: CalendarPageMode) {
        self.mode = mode
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(timedEventsView)
        addSubview(allDayEventsView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timedEventsView.frame = bounds
        layoutAllDayEventsView()
        updateContentInset()
    }
    
    private func updateContentInset() {
        timedEventsView.contentInset = UIEdgeInsets(top: allDayHeight)
    }
    
    private func layoutAllDayEventsView() {
        allDayEventsView.width = width
        allDayEventsView.height = allDayHeight
        allDayEventsView.origin = .zero
    }
    
    // MARK: - CalendarPageAllDayEventsViewDelegate
    func calendarPageAllDayEventsView(_ view: CalendarPageAllDayEventsView, didTapEvent event: CalendarEvent) {
        delegate?.pageEventsView(self, didTapEvent: event)
    }
    
    func calendarPageAllDayEventsView(_ view: CalendarPageAllDayEventsView, didTapMoreOnDate date: Date) {
        delegate?.pageEventsView(self, didTapAllDayMoreOnDate: date)
    }

    // MARK: - CalendarPageTimedEventsViewDelegate
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView, eventsOnDate date: Date) -> [CalendarEvent]? {
        return delegate?.pageEventsView(self, timedEventsOnDate: date)
    }
    
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView, longPressEvent event: CalendarEvent) {
        delegate?.pageEventsView(self, longPressEvent: event)
    }
    
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView, didTapEvent event: CalendarEvent) {
        delegate?.pageEventsView(self, didTapEvent: event)
    }
    
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView, didTapLocation location: CGPoint, onDate date: Date) {
        delegate?.pageEventsView(self, didTapLocation: location, onDate: date)
    }
    
    // MARK: - Public Methods
    func reset() {
        allDayEventsView.reset()
        timedEventsView.reset()
    }
    
    func reloadData() {
        guard let firstDate = firstDate else {
            reset()
            return
        }

        allDayEventsView.firstDate = firstDate
        allDayEventsView.events = delegate?.allDayEventsForPageEventsView(self)
        allDayEventsView.reloadData()
        
        timedEventsView.firstDate = firstDate
        timedEventsView.reloadData()
    }
    
    func maxRowForAllDayView(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return allDayEventsView.maxRow(in: dateRange)
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        allDayEventsView.didChangeVisibleOffset(offset)
    }
}
