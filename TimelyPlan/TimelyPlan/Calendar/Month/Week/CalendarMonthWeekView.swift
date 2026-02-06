//
//  CalendarMonthWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/22.
//

import Foundation
import UIKit

protocol CalendarMonthWeekViewDelegate: AnyObject {
    
    /// 获取指定周的事件
    /// - Parameters:
    ///   - weekView: 周视图实例
    ///   - weekStartDate: 周的起始日期
    ///   - completion: 异步回调，返回该周的事件数组
    func calendarMonthWeekView(_ weekView: CalendarMonthWeekView,
                               fetchEventsForWeek weekStartDate: Date,
                               completion: @escaping ([CalendarEvent]?) -> Void)
}

class CalendarMonthWeekView: UIView {
    
    /// 代理对象
    weak var delegate: CalendarMonthWeekViewDelegate?
    
    /// 周开始日期
    var weekStartDate: Date?
    
    /// 事件视图
    private let eventView: CalendarStripView = {
        let view = CalendarStripView()
        return view
    }()
    
    /// 天视图数组
    private var dayViews: [CalendarMonthDayView]!
    
    /// 背景分割线图层
    private lazy var backgroundLayer: CalendarMonthWeekBackgroundLayer = {
        let layer = CalendarMonthWeekBackgroundLayer()
        return layer
    }()

    /// 头视图高度
    private let headerHeight = 30.0
    
    /// 数据请求管理器
    private let requestManager = RequestManager()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDayViews()
        layer.addSublayer(backgroundLayer)
        addSubview(eventView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = bounds
        CATransaction.commit()
        layoutDayViews()
        
        let stripHeight = height - headerHeight
        eventView.frame = CGRect(x: 0.0, y: headerHeight, width: width, height: stripHeight)
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
    
    private func layoutDayViews() {
        let itemWidth = width / CGFloat(DAYS_PER_WEEK)
        let itemHeight = height
        for (index, dayView) in dayViews.enumerated() {
            let x = CGFloat(index) * itemWidth
            dayView.frame = CGRect(x: x, y: 0.0, width: itemWidth, height: itemHeight)
        }
    }
    
    func reset() {
        eventView.reset()
        dayViews.forEach { view in
            view.reset()
        }
    }
    
    func reloadData() {
        guard let weekStartDate = weekStartDate else {
            reset()
            return
        }
        
        backgroundLayer.weekStartDate = weekStartDate
        let requestID = requestManager.executeRequest()
        loadDayConfigsAsync(weekStartDate: weekStartDate) { dayConfigs in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            for i in 0..<DAYS_PER_WEEK {
                self.dayViews[i].update(with: dayConfigs[i])
            }
        }
        
        eventView.startDate = weekStartDate
        loadEventAsync(weekStartDate: weekStartDate) { events in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            self.eventView.events = events
            self.eventView.reloadData()
        }
    }
    
    func loadDayConfigsAsync(weekStartDate: Date, completion: @escaping ([CalendarMonthDayConfig]) -> Void) {
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
    
    func loadEventAsync(weekStartDate: Date, completion: @escaping ([CalendarEvent]?) -> Void) {
        guard let delegate = delegate else {
            completion(nil)
            return
        }

        delegate.calendarMonthWeekView(self, fetchEventsForWeek: weekStartDate, completion: completion)
    }
}
