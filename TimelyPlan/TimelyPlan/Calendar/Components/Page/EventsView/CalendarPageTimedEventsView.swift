//
//  CalendarPageTimedEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/18.
//

import Foundation
import UIKit

protocol CalendarPageTimedEventsViewDelegate: AnyObject {
    
    /// 指定日期定时事项
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView, eventsOnDate date: Date) -> [CalendarEvent]?

    /// 长按事项
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView, longPressEvent event: CalendarEvent)
    
    /// 单击事项
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView, didTapEvent event: CalendarEvent)
    
    /// 点击特定日期的特定位置
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView,
                                     didTapLocation location: CGPoint,
                                     onDate date: Date)
}

class CalendarPageTimedEventsView: UIView,
                                   CalendarDayTimedEventsViewDelegate {
    
    weak var delegate: CalendarPageTimedEventsViewDelegate?
    
    var firstDate: Date? {
        didSet {
            updateDayViewDate()
        }
    }
    
    var layout = CalendarAxisLayout() {
        didSet {
            setNeedsLayout()
        }
    }

    /// 天视图数组
    private(set) var dayViews: [CalendarDayTimedEventsView]!

    /// 时间线背景图层
    private lazy var backgroundLayer: CalendarTimelineBackLayer = {
        let layer = CalendarTimelineBackLayer(mode: mode)
        return layer
    }()
    
    private let contentView = UIScrollView()
    
    let mode: CalendarPageMode
    
    init(frame: CGRect, mode: CalendarPageMode) {
        self.mode = mode
        super.init(frame: frame)
        setupContentView()
        setupDayViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContentView() {
        contentView.contentInsetAdjustmentBehavior = .never
        contentView.scrollsToTop = false
        contentView.showsVerticalScrollIndicator = false
        addSubview(contentView)
        contentView.layer.addSublayer(backgroundLayer)
    }
    
    private func setupDayViews() {
        let daysCount = mode.days
        /// 初始化日视图
        var dayViews = [CalendarDayTimedEventsView]()
        for index in 0..<daysCount {
            let view = CalendarDayTimedEventsView()
            view.delegate = self
            view.tag = index
            contentView.addSubview(view)
            dayViews.append(view)
        }
        
        self.dayViews = dayViews
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = bounds
        let contentSize = CGSize(width: width, height: layout.contentHeight)
        contentView.contentSize = contentSize
        
        let dayWidth = width / CGFloat(dayViews.count)
        let dayHeight = layout.contentHeight
        for (index, dayView) in dayViews.enumerated() {
            let x = CGFloat(index) * dayWidth
            dayView.frame = CGRect(x: x,
                                   y: 0.0,
                                   width: dayWidth,
                                   height: dayHeight)
        }
        
        backgroundLayer.layout = layout
        backgroundLayer.updateColors()
    
        executeWithoutAnimation {
            backgroundLayer.frame = CGRect(x: 0.0,
                                           y: 0.0,
                                           size: contentSize)
        }
    }
    
    // MARK: - Public Methods
    
    func reset() {
        dayViews.forEach { view in
            view.reset()
        }
    }
    
    private func updateDayViewDate() {
        guard let firstDate = firstDate else {
            return
        }
        
        for dayView in dayViews {
            let date = firstDate.dateByAddingDays(dayView.tag)!
            dayView.date = date
        }
    }
    
    func reloadData() {
        for dayView in dayViews {
            guard let date = dayView.date else {
                dayView.reset()
                continue
            }

            dayView.events = delegate?.calendarPageTimedEventsView(self, eventsOnDate: date)
            dayView.reloadData()
        }
    }

    // MARK: - CalendarDayTimedEventsViewDelegate
    func calendarDayTimedEventsView(_ view: CalendarDayTimedEventsView, longPressEvent event: CalendarEvent) {
        delegate?.calendarPageTimedEventsView(self, longPressEvent: event)
    }
    
    func calendarDayTimedEventsView(_ view: CalendarDayTimedEventsView, didTapEvent event: CalendarEvent) {
        delegate?.calendarPageTimedEventsView(self, didTapEvent: event)
    }
    
    func calendarDayTimedEventsView(_ view: CalendarDayTimedEventsView, didTapLocation location: CGPoint) {
        guard let date = view.date else {
            return
        }
        
        delegate?.calendarPageTimedEventsView(self, didTapLocation: location, onDate: date)
    }
    
    // MARK: - Helpers
    var contentOffset: CGPoint {
        get {
            return contentView.contentOffset
        }
        
        set {
            contentView.contentOffset = newValue
        }
    }

    var contentInset: UIEdgeInsets {
        get {
            return contentView.contentInset
        }
        
        set {
            contentView.contentInset = newValue
        }
    }

    /// 滚动视图代理
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return contentView.delegate
        }
        
        set {
            contentView.delegate = newValue
        }
    }
    
}
