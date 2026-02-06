//
//  CalendarWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/11.
//

import Foundation
import UIKit

class CalendarWeekView: UIView {
    
    /// 周开始日
    var weekStartDate: Date?
    
    static var weekDaysViewHeight = 80.0

    /// 周天日期视图
    private let weekDaysView: CalendarWeekDaysView = {
        let view = CalendarWeekDaysView()
        return view
    }()
    
    /// 事件视图
    let eventsView: CalendarWeekEventsView = {
        let view = CalendarWeekEventsView()
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
        addSubview(weekDaysView)
        addSubview(eventsView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        weekDaysView.width = width
        weekDaysView.height = Self.weekDaysViewHeight
        
        eventsView.width = width
        eventsView.height = height - Self.weekDaysViewHeight
        eventsView.top = weekDaysView.bottom
    }
    
    func reloadData() {
        weekDaysView.weekStartDate = weekStartDate
        eventsView.weekStartDate = weekStartDate
        eventsView.reloadData()
    }
    
    func reset() {
        
    }
}
