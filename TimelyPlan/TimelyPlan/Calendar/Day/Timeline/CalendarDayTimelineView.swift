//
//  CalendarDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/1.
//

import Foundation
import UIKit

protocol CalendarDayTimelineViewDelegate: AnyObject {
    
    /// 全天事件加载完成
    func calendarDayTimelineViewDidLoadAllDayEvents(_ view: CalendarDayTimelineView)
}

class CalendarDayTimelineView: UIView {
    
    weak var delegate: CalendarDayTimelineViewDelegate?
    
    private(set) var date: Date = .now {
        didSet {
            self.dateRange = CalendarTimelineDateRange(date: date)
        }
    }
    
    private lazy var dateRange: CalendarTimelineDateRange = {
        return CalendarTimelineDateRange(date: date)
    }()
    
    var hourHeight: CGFloat = 80 {
        didSet {
            backgroundLayer.hourHeight = hourHeight
            setNeedsLayout()
        }
    }
    
    var topPadding: CGFloat = 20 {
        didSet {
            backgroundLayer.topPadding = topPadding
            setNeedsLayout()
        }
    }
    
    var bottomPadding: CGFloat = 40 {
        didSet {
            backgroundLayer.bottomPadding = bottomPadding
            setNeedsLayout()
        }
    }
    
    var scrollViewDelegate: UIScrollViewDelegate? {
        get {
            return contentView.delegate
        }
        
        set {
            contentView.delegate = newValue
        }
    }
    
    var contentOffset: CGPoint {
        get {
            return contentView.contentOffset
        }
        
        set {
            contentView.contentOffset = newValue
        }
    }
    
    var allDayHeight: CGFloat = 0.0 {
        didSet {
            if allDayHeight != oldValue {
                layoutAllDayView()
                updateContentInset()
            }
        }
    }
    
    /// 时间指示器
    private let indicatorViewHeight = 30.0
    private var indicatorView: CalendarDayTimelineIndicatorView?

    /// 小时视图
    private let hoursViewWidth = 60.0
    private lazy var hoursView: CalendarDayTimelineHoursView = {
        let view = CalendarDayTimelineHoursView()
        return view
    }()
    
    /// 事件视图
    private lazy var eventsView: CalendarDayEventsView = {
        let view = CalendarDayEventsView()
        return view
    }()
    
    /// 全天视图
    private lazy var allDayView: CalendarDayAllDayEventsView = {
        let view = CalendarDayAllDayEventsView()
        return view
    }()
    
    /// 内容视图
    private let contentView = UIScrollView()
    
    /// 时间线背景图层
    private let backgroundLayer = CalendarDayTimelineBackLayer()
    
    /// 指示器分钟更新器
    private let timerUpdater = TPMinuteUpdater()
    
    /// 事件供应者
    private let eventsProvider = CalendarDayEventsProvider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
        eventsProvider.eventsDidChange = { [weak self] in
            self?.eventsChanged()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func eventsChanged() {
        guard date.isInSameDayAs(eventsProvider.date) else {
            return
        }
        
        DispatchQueue.main.async {
            self.eventsView.dateRange = self.dateRange
            self.eventsView.events = self.eventsProvider.timedEvents
            self.eventsView.reloadData()
            
            self.allDayView.date = self.date
            self.allDayView.events = self.eventsProvider.allDayEvents
            self.allDayView.reloadData()
            self.allDayEventsDidLoaded()
        }
    }
    
    private func allDayEventsDidLoaded() {
        self.delegate?.calendarDayTimelineViewDidLoadAllDayEvents(self)
    }
    
    private func setupContentView() {
        backgroundLayer.hourHeight = hourHeight
        backgroundLayer.topPadding = topPadding
        backgroundLayer.bottomPadding = bottomPadding
        
        contentView.showsVerticalScrollIndicator = false
        addSubview(contentView)
        addSubview(allDayView)
        
        contentView.layer.addSublayer(backgroundLayer)
        contentView.addSubview(hoursView)
        contentView.addSubview(eventsView)
        setupIndicatorView()
    }
    
    private func setupIndicatorView() {
        guard date.isToday else {
            indicatorView?.removeFromSuperview()
            indicatorView = nil
            timerUpdater.stop()
            return
        }
        
        if self.indicatorView == nil {
            let view = CalendarDayTimelineIndicatorView()
            self.indicatorView = view
            contentView.addSubview(view)
        }
        
        /// 启动计时器
        timerUpdater.start { [weak self] in
            self?.updateIndicator()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let contentHeight = hourHeight * CGFloat(HOURS_PER_DAY) + topPadding + bottomPadding
        contentView.frame = bounds
        contentView.contentSize = CGSize(width: width, height: contentHeight)
        
        hoursView.hourHeight = hourHeight
        hoursView.width = hoursViewWidth
        hoursView.height = contentHeight
        
        eventsView.padding = UIEdgeInsets(top: topPadding,
                                          left: 4.0,
                                          bottom: bottomPadding,
                                          right: 4.0)
        eventsView.width = width - hoursViewWidth
        eventsView.height = contentHeight
        eventsView.left = hoursViewWidth

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = eventsView.frame
        backgroundLayer.updateColors()
        CATransaction.commit()
        updateIndicator()
        layoutAllDayView()
    }
    
    private func layoutAllDayView() {
        allDayView.width = width
        allDayView.height = allDayHeight
        allDayView.origin = .zero
    }
    
    private func updateContentInset() {
        self.contentView.contentInset = UIEdgeInsets(top: allDayHeight)
    }
    
    private func updateIndicator() {
        guard let indicatorView = indicatorView else {
            return
        }

        let date = Date()
        let centerY = topPadding +  hourHeight * CGFloat(HOURS_PER_DAY) * (date.timeIntervalSince(dateRange.start) / dateRange.interval)
        indicatorView.frame = CGRect(x: 0.0,
                                     y: centerY - indicatorViewHeight / 2.0,
                                     width: width,
                                     height: indicatorViewHeight)
        indicatorView.title = date.timeString
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        allDayView.didChangeVisibleOffset(offset)
    }
    
    func maxRowForAllDayView() -> Int {
        return allDayView.maxRow()
    }
    
    func reset() {
        allDayView.reset()
        eventsView.reset()
        timerUpdater.stop()
    }
    
    func loadEvents(for date: Date) {
        self.reset()
        self.date = date
        setupIndicatorView()
        eventsProvider.loadEvents(for: date)
    }
}
