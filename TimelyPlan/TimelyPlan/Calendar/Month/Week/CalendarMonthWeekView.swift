//
//  CalendarMonthWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation
import UIKit

protocol CalendarMonthWeekViewDelegate: AnyObject {
    
    func calendarMonthWeekView(_ weekView: CalendarMonthWeekView, longPressDidBeganOnDate date: Date)
}

class CalendarMonthWeekView: UIView {
    
    /// 代理对象
    weak var delegate: CalendarMonthWeekViewDelegate?
    
    var firstWeekday: Weekday = .sunday {
        didSet {
            if firstWeekday != oldValue {
                updateWeekNumber()
            }
        }
    }
    
    var showWeekNumber: Bool = true {
        didSet {
            if showWeekNumber != oldValue {
                setupWeekNumberView()
            }
        }
    }
    
    /// 周开始日期
    private(set) var weekStartDate: Date?
    
    /// 事件视图
    private let eventsView: CalendarStripView = {
        let view = CalendarStripView()
        return view
    }()
    
    /// 天视图数组
    private var dayViews: [CalendarMonthDayView]!
    
    private let weekNumberWidth = 16.0
    private let weekNumberHeight = 20.0
    private var weekNumberView: CalendarWeekNumberView?
    
    /// 背景分割线图层
    private lazy var backgroundLayer: CalendarMonthWeekBackgroundLayer = {
        let layer = CalendarMonthWeekBackgroundLayer()
        return layer
    }()

    /// 头视图高度
    private let headerHeight = 36.0
    
    /// 事件供应者
    private let eventsProvider = CalendarWeekEventsProvider()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDayViews()
        layer.addSublayer(backgroundLayer)
        addSubview(eventsView)
        setupWeekNumberView()
        
        setupLongPressGesture()
        eventsProvider.eventsDidChange = { [weak self] in
            self?.eventsChanged()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.backgroundLayer.frame = bounds
        }
        
        layoutDayViews()
        layoutWeekNumberView()
        let stripHeight = height - headerHeight
        eventsView.frame = CGRect(x: 0.0, y: headerHeight, width: width, height: stripHeight)
    }
    
    private func layoutWeekNumberView() {
        if let weekNumberView = weekNumberView {
            let weekNumberFrame = CGRect(x: 0.0, y: 0.0, width: weekNumberWidth, height: headerHeight)
            weekNumberView.padding = UIEdgeInsets(vertical: 2.0)
            weekNumberView.numberHeight = weekNumberHeight
            weekNumberView.frame = weekNumberFrame.insetBy(dx: 1.0, dy: 1.0)
        }
    }
    
    private func layoutDayViews() {
        let itemWidth = width / CGFloat(DAYS_PER_WEEK)
        let itemHeight = height
        for (index, dayView) in dayViews.enumerated() {
            let x = CGFloat(index) * itemWidth
            dayView.headerHeight = headerHeight
            dayView.frame = CGRect(x: x, y: 0.0, width: itemWidth, height: itemHeight)
        }
    }
    
    private func eventsChanged() {
        guard weekStartDate == eventsProvider.weekStartDate else {
            return
        }
        
        DispatchQueue.main.async {
            self.eventsView.events = self.eventsProvider.allDayEvents
            self.eventsView.reloadData()
        }
    }
    
    private func setupWeekNumberView() {
        guard showWeekNumber else {
            weekNumberView?.removeFromSuperview()
            weekNumberView = nil
            return
        }
        
        let weekNumberView = CalendarWeekNumberView()
        weekNumberView.backgroundColor = .systemGray6
        self.weekNumberView = weekNumberView
        updateWeekNumber()
        layer.insertSublayer(weekNumberView.layer, below: backgroundLayer)
        setNeedsLayout()
    }
    
    // MARK: - 长按手势
    
    /// 设置长按手势识别器
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(longPressGesture)
    }
    
    /// 处理长按手势
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: self)
            if let date = date(on: location) {
                delegate?.calendarMonthWeekView(self, longPressDidBeganOnDate: date)
            }
        }
    }
    
    private func setupDayViews() {
        var dayViews = [CalendarMonthDayView]()
        for _ in 1...DAYS_PER_WEEK {
            let view = CalendarMonthDayView()
            addSubview(view)
            dayViews.append(view)
        }
        
        self.dayViews = dayViews
    }

    private func updateWeekNumber() {
        guard let weekNumberView = weekNumberView, let date = weekStartDate else {
            return
        }
        
        weekNumberView.weekNumber = Calendar.weekNumber(for: date, firstWeekday: firstWeekday)
    }
    
    
    func loadEvents(weekStartDate: Date) {
        self.weekStartDate = weekStartDate
        updateWeekNumber()
        backgroundLayer.weekStartDate = weekStartDate
        updateDayConfigs()
        
        if eventsView.startDate != weekStartDate {
            eventsView.startDate = weekStartDate
            eventsView.reset()
        }
        
        eventsProvider.loadEvents(with: weekStartDate)
    }
    
    private func updateDayConfigs() {
        guard let weekStartDate = weekStartDate else {
            return
        }

        loadDayConfigs(weekStartDate: weekStartDate) { dayConfigs in
            guard self.weekStartDate == weekStartDate else {
                return
            }
            
            for i in 0..<DAYS_PER_WEEK {
                self.dayViews[i].update(with: dayConfigs[i])
            }
        }
    }
    
    private func loadDayConfigs(weekStartDate: Date, completion: @escaping ([CalendarMonthDayConfig]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var dayConfigs = [CalendarMonthDayConfig]()
            for i in 0..<DAYS_PER_WEEK {
                let date = i > 0 ? weekStartDate.dateByAddingDays(i)! : weekStartDate
                let config = CalendarMonthDayConfig(date: date)
                dayConfigs.append(config)
            }

            DispatchQueue.main.async {
                completion(dayConfigs)
            }
        }
    }
    
    // MARK: - Helpers
    private func date(on loacation: CGPoint) -> Date? {
        guard let weekStartDate = weekStartDate else {
            return nil
        }

        let dayWidth = bounds.width / CGFloat(DAYS_PER_WEEK)
        let index = Int(loacation.x / dayWidth)
        let date = weekStartDate.dateByAddingDays(index)!
        return date
    }
}
