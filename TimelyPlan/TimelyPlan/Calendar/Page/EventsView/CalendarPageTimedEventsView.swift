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

    /// 点击特定日期的特定位置
    func calendarPageTimedEventsView(_ view: CalendarPageTimedEventsView,
                                     didTapLocation location: CGPoint,
                                     onDate date: Date)
}

class CalendarPageTimedEventsView: UIView,
                                   CalendarDayTimedEventsViewDelegate {
    
    weak var delegate: CalendarPageTimedEventsViewDelegate?
    
    var firstDate: Date?
    
    var layout = CalendarAxisLayout() {
        didSet {
            setNeedsLayout()
        }
    }

    /// 天视图数组
    private(set) var dayViews: [CalendarDayTimedEventsView]!

    /// 时间线背景图层
    private let backgroundLayer: CalendarWeekTimelineBackLayer = {
        let backlayer = CalendarWeekTimelineBackLayer()
        backlayer.columnsCount = DAYS_PER_WEEK
        return backlayer
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
        contentView.scrollsToTop = false
        contentView.showsVerticalScrollIndicator = false
        addSubview(contentView)
        contentView.layer.addSublayer(backgroundLayer)
    }
    
    private func setupDayViews() {
        let daysCount: Int
        switch mode {
        case .day:
            daysCount = 1
        case .week:
            daysCount = DAYS_PER_WEEK
        }
        
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
        let dayHeight = layout.timelineHeight
        for (index, dayView) in dayViews.enumerated() {
            let x = CGFloat(index) * dayWidth
            dayView.frame = CGRect(x: x,
                                   y: layout.topMargin,
                                   width: dayWidth,
                                   height: dayHeight)
        }
        
        backgroundLayer.topPadding = layout.topMargin
        backgroundLayer.bottomPadding = layout.bottomMargin
        backgroundLayer.hourHeight = layout.hourHeight
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
    
    func reloadData() {
        guard let firstDate = firstDate else {
            reset()
            return
        }
        
        for dayView in dayViews {
            let date = firstDate.dateByAddingDays(dayView.tag)!
            dayView.date = date
            dayView.events = delegate?.calendarPageTimedEventsView(self, eventsOnDate: date)
            dayView.reloadData()
        }
    }

    // MARK: - CalendarDayTimedEventsViewDelegate
    func calendarDayTimedEventsView(_ view: CalendarDayTimedEventsView, longPressEvent event: CalendarEvent) {
        delegate?.calendarPageTimedEventsView(self, longPressEvent: event)
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
