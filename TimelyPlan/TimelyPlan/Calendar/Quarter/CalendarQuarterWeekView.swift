//
//  CalendarQuarterWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/5.
//

import Foundation
import UIKit

protocol CalendarQuarterWeekViewDelegate: AnyObject {
    
    func calendarQuarterWeekView(_ weekView: CalendarQuarterWeekView, didTapDate date: Date)
    
    func calendarQuarterWeekView(_ weekView: CalendarQuarterWeekView, didLongPressDate date: Date)
}

class CalendarQuarterWeekView: UIView {
    
    /// 代理对象
    weak var delegate: CalendarQuarterWeekViewDelegate?
    
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
                setupWeekNumberLabel()
            }
        }
    }
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true
    
    /// 周开始日期
    private(set) var weekStartDate: Date?
    
    /// 事件视图
    private lazy var eventsView: CalendarQuarterStripView = {
        let view = CalendarQuarterStripView()
        return view
    }()
    
    /// 天视图数组
    private var dayViews: [CalendarQuarterDayView]!
    
    private let weekNumberWidth = 16.0
    private let weekNumberHeight = 16.0
    private var weekNumberLabel: TPLabel?
    
    /// 背景分割线图层
    private lazy var backgroundLayer: CalendarMonthWeekBackgroundLayer = {
        let layer = CalendarMonthWeekBackgroundLayer()
        return layer
    }()

    /// 头视图高度
    private let headerHeight = CalendarQuarterDayView.headerHeight
    
    /// 事件供应者
    private let eventsViewModel = CalendarEventsViewModel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDayViews()
        layer.addSublayer(backgroundLayer)
        addSubview(eventsView)
        setupWeekNumberLabel()
        
        setupGesture()
        eventsViewModel.onEventsChanged = { [weak self] in
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
        layoutWeekNumberLabel()
        eventsView.frame = CGRect(x: 0.0,
                                  y: headerHeight,
                                  width: width,
                                  height: height - headerHeight)
    }
    
    private func layoutWeekNumberLabel() {
        if let weekNumberLabel = weekNumberLabel {
            let weekNumberFrame = CGRect(x: 0.0,
                                         y: (headerHeight - weekNumberHeight) / 2.0,
                                         width: weekNumberWidth,
                                         height: weekNumberHeight)
            weekNumberLabel.edgeInsets = UIEdgeInsets(value: 2.0)
            weekNumberLabel.frame = weekNumberFrame
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
        guard let weekStartDate = weekStartDate,
                eventsViewModel.range == .rangeOfWeek(weekStartDate: weekStartDate) else {
            return
        }
        
        DispatchQueue.main.async {
            self.eventsView.events = self.eventsViewModel.events
            self.eventsView.reloadData()
        }
    }
    
    private func setupWeekNumberLabel() {
        guard showWeekNumber else {
            weekNumberLabel?.removeFromSuperview()
            weekNumberLabel = nil
            return
        }
        
        if self.weekNumberLabel != nil {
            return
        }
        
        let weekNumberLabel = TPLabel()
        weekNumberLabel.textAlignment = .center
        weekNumberLabel.adjustsFontSizeToFitWidth = true
        weekNumberLabel.textColor = .secondaryLabel
        weekNumberLabel.font = .boldSystemFont(ofSize: 10.0)
        addSubview(weekNumberLabel)
        
        self.weekNumberLabel = weekNumberLabel
        updateWeekNumber()
        setNeedsLayout()
    }
    
    // MARK: - 长按手势
    
    /// 设置长按手势识别器
    private func setupGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.25
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.cancelsTouchesInView = false
        addGestureRecognizer(longPressGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        if let date = date(on: location) {
            delegate?.calendarQuarterWeekView(self, didTapDate: date)
        }
    }
    
    /// 处理长按手势
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: self)
            if let date = date(on: location) {
                delegate?.calendarQuarterWeekView(self, didLongPressDate: date)
            }
        }
    }
    
    private func setupDayViews() {
        var dayViews = [CalendarQuarterDayView]()
        for _ in 1...DAYS_PER_WEEK {
            let view = CalendarQuarterDayView()
            addSubview(view)
            dayViews.append(view)
        }
        
        self.dayViews = dayViews
    }

    private func updateWeekNumber() {
        guard let weekNumberLabel = weekNumberLabel, let date = weekStartDate else {
            return
        }
        
        let number = Calendar.weekNumber(for: date, firstWeekday: firstWeekday)
        weekNumberLabel.text = "\(number)"
    }
    
    func loadEvents(weekStartDate: Date) {
        self.weekStartDate = weekStartDate
        reloadWeekDays()
        updateWeekNumber()
        backgroundLayer.weekStartDate = weekStartDate
        
        if eventsView.startDate != weekStartDate {
            eventsView.startDate = weekStartDate
            eventsView.reset()
        }
        
        eventsViewModel.loadEvents(in: .rangeOfWeek(weekStartDate: weekStartDate))
    }
    
    func reloadWeekDays() {
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
                let config = CalendarMonthDayConfig(date: date,
                                                    showLunar: self.showLunar,
                                                    showChineseHolidays: self.showChineseHolidays)
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
