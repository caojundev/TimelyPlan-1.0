//
//  CalendarWeekEventsView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/13.
//

import Foundation
import UIKit

protocol CalendarWeekEventsViewDelegate: AnyObject {
    
}

class CalendarWeekEventsView: UIView {
    
    var weekStartDate: Date?
    
    var allDayHeight: CGFloat = 0.0 {
        didSet {
            if allDayHeight != oldValue {
                layoutAllDayView()
                updateContentInset()
            }
        }
    }
    
    var contentOffset: CGPoint {
        get {
            return timelineView.contentOffset
        }
        
        set {
            timelineView.contentOffset = newValue
        }
    }
    
    /// 滚动视图代理
    weak var scrollViewDelegate: UIScrollViewDelegate? {
        didSet {
            timelineView.delegate = scrollViewDelegate
        }
    }
    
    /// 时间线视图
    private let timelineView: CalendarWeekTimelineEventsView = {
        let view = CalendarWeekTimelineEventsView()
        return view
    }()
    
    /// 全天事件视图
    private let allDayView: CalendarWeekAllDayEventsView = {
        let view = CalendarWeekAllDayEventsView()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubviews()
    }
    
    private func setupSubviews() {
        addSubview(timelineView)
        addSubview(allDayView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        timelineView.frame = bounds
        layoutAllDayView()
        updateContentInset()
    }
    
    private func layoutAllDayView() {
        allDayView.width = width
        allDayView.height = allDayHeight
        allDayView.origin = .zero
    }
    
    private func updateContentInset() {
        timelineView.contentInset = UIEdgeInsets(top: allDayHeight)
    }
    
    func maxRowForAllDayView(in dateRange: (firstDate: Date, lastDate: Date)) -> Int {
        return allDayView.maxRow(in: dateRange)
    }
    
    func reloadData() {
        allDayView.weekStartDate = weekStartDate
        allDayView.reloadData()
        timelineView.weekStartDate = weekStartDate
        timelineView.reloadData()
    }
    
    func didChangeVisibleOffset(_ offset: CGPoint) {
        allDayView.didChangeVisibleOffset(offset)
    }
    
    
    func eventView(at point: CGPoint) -> CalendarEventView? {
        let convertedPoint = self.convert(point, toViewOrWindow: timelineView)
        return timelineView.eventView(at: convertedPoint)
    }
    
}

