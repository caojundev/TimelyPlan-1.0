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
    private(set) var dayViews: [CalendarDayTimedEventsView] = []

    /// 时间线背景图层
    private lazy var backgroundLayer: CalendarTimelineBackLayer = {
        let layer = CalendarTimelineBackLayer(mode: mode)
        return layer
    }()
    
    private let contentView = UIScrollView()
    
    private var topIndicator: CalendarPageEventIndicatorView!
    
    private var bottomIndicator: CalendarPageEventIndicatorView!
    
    private let indicatorHeight = 12.0
    
    let mode: CalendarPageMode
    
    init(frame: CGRect, mode: CalendarPageMode) {
        self.mode = mode
        super.init(frame: frame)
        setupContentView()
        setupDayViews()
        setupIndicator()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupIndicator() {
        topIndicator = CalendarPageEventIndicatorView(mode: mode, position: .top)
        addSubview(topIndicator)
        
        bottomIndicator = CalendarPageEventIndicatorView(mode: mode, position: .bottom)
        addSubview(bottomIndicator)
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
            dayView.frame = CGRect(x: x, y: 0.0, width: dayWidth, height: dayHeight)
        }
        
        backgroundLayer.layout = layout
        backgroundLayer.updateColors()
    
        executeWithoutAnimation {
            backgroundLayer.frame = CGRect(x: 0.0, y: 0.0, size: contentSize)
        }
        
        layoutIndicators()
    }
    
    private func layoutIndicators() {
        topIndicator.frame = CGRect(x: 0.0,
                                    y: contentInset.top,
                                    width: bounds.width,
                                    height: indicatorHeight)
        bottomIndicator.frame = CGRect(x: 0.0,
                                       y: bounds.height - indicatorHeight,
                                       width: bounds.width,
                                       height: indicatorHeight)
        updateIndicators()
    }
    
    private func updateIndicators() {
        let visibleY = contentOffset.y + contentInset.top
        let visibleHeight = bounds.height - contentInset.top
        var aboveInfos = [(Int, Bool)]()
        var belowInfos = [(Int, Bool)]()
        for dayView in dayViews {
            let visibleFrame = CGRect(x: 0.0,
                                      y: visibleY - dayView.axisLayout.topMargin,
                                      width: bounds.width,
                                      height: visibleHeight)
            
            let index = dayView.tag
            let hasEventAbove = dayView.hasEventAbove(visibleFrame: visibleFrame)
            let hasEventBelow = dayView.hasEventBelow(visibleFrame: visibleFrame)
            aboveInfos.append((index, hasEventAbove))
            belowInfos.append((index, hasEventBelow))
        }
        
        topIndicator.update(with: aboveInfos)
        bottomIndicator.update(with: belowInfos)
    }
    
    // MARK: - Public Methods
    
    func reset() {
        dayViews.forEach { view in
            view.reset()
        }
        
        topIndicator.reset()
        bottomIndicator.reset()
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
        
        updateIndicators()
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
            updateIndicators()
        }
    }

    var contentInset: UIEdgeInsets {
        get {
            return contentView.contentInset
        }
        
        set {
            contentView.contentInset = newValue
            layoutIndicators()
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


class CalendarPageEventIndicatorView: UIView {
    
    let mode: CalendarPageMode
    
    let position: CalendarEventIndicatorPosition
    
    private(set) var indicatorBars: [UIView] = []
    
    init(mode: CalendarPageMode, position: CalendarEventIndicatorPosition) {
        self.mode = mode
        self.position = position
        super.init(frame: .zero)
        
        for index in 0..<mode.days {
            let view = CalendarEventIndicatorBar(position: position)
            view.backgroundColor = .clear
            view.tag = index
            view.isHidden = true
            addSubview(view)
            indicatorBars.append(view)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let dayWidth = width / CGFloat(mode.days)
        for indicatorBar in indicatorBars {
            indicatorBar.width = dayWidth
            indicatorBar.height = height
            indicatorBar.left = CGFloat(indicatorBar.tag) * dayWidth
        }
    }
    
    func reset() {
        for indicatorBar in indicatorBars {
            indicatorBar.isHidden = true
        }
    }
    
    func update(with infos: [(index: Int, isExist: Bool)]) {
        for info in infos {
            let view = indicatorBars[info.index]
            view.isHidden = !info.isExist
        }
    }
}

enum CalendarEventIndicatorPosition {
    case top
    case bottom
}

class CalendarEventIndicatorBar: UIView {
    
    let position: CalendarEventIndicatorPosition
    private let imageView = UIImageView()
    
    init(position: CalendarEventIndicatorPosition) {
        self.position = position
        super.init(frame: .zero)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        if position == .top {
            imageView.image = resGetImage("triangle_up_12")
        } else {
            imageView.image = resGetImage("triangle_down_12")
        }
        
        imageView.updateImage(withColor: .primary)
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize: CGFloat = 12
        imageView.frame = CGRect(
            x: (bounds.width - imageSize) / 2,
            y: (bounds.height - imageSize) / 2,
            width: imageSize,
            height: imageSize
        )
    }
}
