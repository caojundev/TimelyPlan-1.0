//
//  CalendarDayTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/1.
//

import Foundation
import UIKit

class CalendarDayTimelineView: UIView {
    
    var date: Date = .now
    
    var dateRange = CalendarTimelineDateRange(date: .now)
    
    var hourHeight: CGFloat = 40 {
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
    
    private let hoursViewWidth = 60.0
    private let hoursView: CalendarDayTimelineHoursView = {
        let view = CalendarDayTimelineHoursView()
        return view
    }()
    
    private let eventsView: CalendarDayEventsView = {
        let view = CalendarDayEventsView()
        return view
    }()
    
    private let indicatorViewHeight = 30.0
    private var indicatorView: CalendarDayTimelineIndicatorView?

    /// 时间线背景图层
    private let backgroundLayer = CalendarDayTimelineBackLayer()
    
    private let contentView = UIScrollView()
    
    private let timerUpdater = TPMinuteUpdater()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupContentView() {
        contentView.showsVerticalScrollIndicator = false
        addSubview(contentView)
        backgroundLayer.hourHeight = hourHeight
        backgroundLayer.topPadding = topPadding
        backgroundLayer.bottomPadding = bottomPadding
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
        
        let indicatorView = CalendarDayTimelineIndicatorView()
        self.indicatorView = indicatorView
        contentView.addSubview(indicatorView)
        
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
    
    func reset() {
//        eventsView.reset()
//        timerUpdater.stop()
    }
}
