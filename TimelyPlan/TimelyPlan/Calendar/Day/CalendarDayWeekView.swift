//
//  CalendarDayWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/12.
//

import Foundation
import UIKit

class CalendarDayWeekView: UIView {
    
    var eventsProvider: CalendarRangeEventsProvider? {
        didSet {
            weekView.eventsProvider = eventsProvider
        }
    }
    
    var showWeekNumber: Bool {
        get {
            return weekNumberView.showWeekNumber
        }
        
        set {
            weekNumberView.showWeekNumber = newValue
        }
    }
    
    var firstWeekday: Weekday = .sunday {
        didSet {
            weekView.firstWeekday = firstWeekday
        }
    }
    
    var selection: TPCalendarDateSelection? {
        didSet {
            weekView.selection = selection
        }
    }
    
    var showLunar: Bool = true {
        didSet {
            weekView.showLunar = showLunar
        }
    }
    
    var showChineseHolidays: Bool = true {
        didSet {
            weekView.showChineseHolidays = showChineseHolidays
        }
    }
    
    let weekNumberViewWidth = 50.0
    
    private var weekNumberView = CalendarWeekNumberContainerView()
    
    private lazy var weekView: TPCalendarScrollableWeekView = {
        let view = TPCalendarScrollableWeekView(frame: .zero)
        view.firstWeekday = firstWeekday
        view.showLunar = showLunar
        view.showChineseHolidays = showChineseHolidays
        view.didChangeVisibleDateComponents = { [weak self] _, _ in
            self?.updateWeekNumber()
        }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(weekView)
        var layoutStyle = weekNumberView.layoutStyle
        layoutStyle.rowsCount = 0
        weekNumberView.layoutStyle = layoutStyle
        addSubview(weekNumberView)
        addSeparator(position: .bottom)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        weekNumberView.width = weekNumberViewWidth
        weekNumberView.height = height
        weekNumberView.origin = .zero
        
        weekView.width = width - weekNumberViewWidth
        weekView.height = height
        weekView.left = weekNumberView.right
    }
    
    private func updateWeekNumber() {
        guard let date = Date.dateFromComponents(weekView.visibleDateComponents) else {
            return
        }

        let firstWeekday = weekView.firstWeekday
        weekNumberView.weekNumber = Calendar.weekNumber(for: date, firstWeekday: firstWeekday)
    }
    
    func reloadData() {
        weekView.reloadData()
        updateWeekNumber()
    }
    
    func setVisibleDateComponents(_ dateComponents: DateComponents, animated: Bool) {
        weekView.setVisibleDateComponents(dateComponents, animated: animated)
        updateWeekNumber()
    }
        
}

