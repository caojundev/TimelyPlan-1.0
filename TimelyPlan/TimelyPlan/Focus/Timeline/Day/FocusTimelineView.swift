//
//  FocusTimelineView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/1.
//

import Foundation
import UIKit

class FocusTimelineView: UIView {
    
    var date: Date = .now {
        didSet {
            /// 初始化指示器
            setupIndicatorView()
        }
    }
    
    var dateRange = CalendarTimelineDateRange(date: .now)
    
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
    
    private let hoursViewWidth = 60.0
    private let hoursView: CalendarDayTimelineHoursView = {
        let view = CalendarDayTimelineHoursView()
        return view
    }()
    
    private let eventListView: FocusTimelineEventListView = {
        let view = FocusTimelineEventListView()
        return view
    }()
    
    /// 当前小时指示器
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
        
        eventListView.padding = UIEdgeInsets(top: topPadding,
                                          left: 4.0,
                                          bottom: bottomPadding,
                                          right: 4.0)
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
        let centerY = topPadding +  hourHeight * CGFloat(HOURS_PER_DAY) * (date.timeIntervalSince(dateRange.start) / dateRange.interval)
        indicatorView.frame = CGRect(x: 0.0,
                                     y: centerY - indicatorViewHeight / 2.0,
                                     width: width,
                                     height: indicatorViewHeight)
        indicatorView.title = date.timeString
    }
    
    func reset() {
//        eventListView.reset()
//        timerUpdater.stop()
    }
}
