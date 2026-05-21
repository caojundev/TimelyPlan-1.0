//
//  FocusTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/1.
//

import Foundation
import UIKit

class FocusTimelineView: UIView {

    private(set) var date: Date = .now
    
    /// 点击事件代理
    weak var tapDelegate: FocusTimelineEventListTapDelegate? {
        didSet {
            eventListView.tapDelegate = tapDelegate
        }
    }
    
    var hourHeight: CGFloat = 80.0 {
        didSet {
            backgroundLayer.hourHeight = hourHeight
            setNeedsLayout()
        }
    }
    
    var topPadding: CGFloat = 20.0 {
        didSet {
            backgroundLayer.topPadding = topPadding
            setNeedsLayout()
        }
    }
    
    var bottomPadding: CGFloat = 40.0 {
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
    
    private lazy var dateRange: DateInterval = {
        return .rangeOfDay(date)
    }()

    private let hoursViewWidth = 60.0
    private lazy var hoursView: CalendarDayTimelineHoursView = {
        let view = CalendarDayTimelineHoursView()
        return view
    }()
    
    private lazy var eventListView: FocusTimelineEventListView = {
        let view = FocusTimelineEventListView()
        return view
    }()
    
    /// 当前小时指示器
    private let indicatorViewHeight = 30.0
    private var indicatorView: CalendarTimelineLabelIndicator?

    /// 时间线背景图层
    private let backgroundLayer = FocusTimelineBackLayer()
    
    private let contentView = UIScrollView()
    
    private let timerUpdater = TPMinuteUpdater()
    
    private let viewModel = FocusTimelineViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupContentView()
        self.viewModel.eventsDidChange = { [weak self] in
            self?.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func reloadData() {
        guard let date = viewModel.date, date.isInSameDayAs(self.date) else {
            return
        }
        
        eventListView.events = viewModel.events
        eventListView.reloadData()
    }
    
    private func setupContentView() {
        contentView.showsVerticalScrollIndicator = false
        addSubview(contentView)
        backgroundLayer.hourHeight = hourHeight
        backgroundLayer.topPadding = topPadding
        backgroundLayer.bottomPadding = bottomPadding
        contentView.layer.addSublayer(backgroundLayer)
        contentView.addSubview(hoursView)
        contentView.addSubview(eventListView)
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
            let view = CalendarTimelineLabelIndicator()
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
        contentView.contentInset = UIEdgeInsets(bottom: hourHeight / 2.0)
        
        hoursView.width = hoursViewWidth
        hoursView.height = contentHeight
        
        eventListView.padding = UIEdgeInsets(top: topPadding,
                                          left: 4.0,
                                          bottom: bottomPadding,
                                          right: 4.0)
        eventListView.hourHeight = hourHeight
        eventListView.topPadding = topPadding
        eventListView.width = width - hoursViewWidth
        eventListView.height = contentHeight
        eventListView.left = hoursViewWidth

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = eventListView.frame
        backgroundLayer.updateColors()
        CATransaction.commit()
        updateIndicator()
    }
    
    private func updateIndicator() {
        guard let indicatorView = indicatorView else {
            return
        }

        let date = Date()
        let centerY = topPadding +  hourHeight * CGFloat(HOURS_PER_DAY) * (date.timeIntervalSince(dateRange.start) / dateRange.duration)
        indicatorView.frame = CGRect(x: 0.0,
                                     y: centerY - indicatorViewHeight / 2.0,
                                     width: width,
                                     height: indicatorViewHeight)
        indicatorView.title = date.timeString
    }
    
    func reset() {
        eventListView.clear()
        timerUpdater.stop()
    }
    
    func loadEvents(for date: Date) {
        self.date = date
        self.dateRange = .rangeOfDay(date)
        self.eventListView.date = date
        self.setupIndicatorView()
        self.viewModel.loadEvents(for: date)
    }
}
