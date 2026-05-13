//
//  CalendarDayWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/12.
//

import Foundation
import UIKit

class CalendarDayWeekView: UIView {
    
    var showWeekNumber: Bool = true {
        didSet {
            if showWeekNumber != oldValue {
                setupWeekNumberView()
            }
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
    
    private let weekNumberSize = CGSize.size(8)
    private let weekNumberHeight = 20.0
    private var weekNumberView: CalendarWeekNumberView?
    
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
        setupWeekNumberView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutWeekNumberView()
        
        if let weekNumberView = weekNumberView {
            weekView.width = width - weekNumberView.width
            weekView.height = height
            weekView.left = weekNumberView.right
        } else {
            weekView.frame = bounds
        }
    }
    
    private func layoutWeekNumberView() {
        if let weekNumberView = weekNumberView {
            let paddingVertical = (height - weekNumberSize.height) / 2.0
            let padding = UIEdgeInsets(vertical: paddingVertical)
            weekNumberView.padding = padding
            weekNumberView.separatorEdgeInset = padding
            weekNumberView.frame = CGRect(x: 0.0, y: 0.0, width: weekNumberSize.width, height: height)
        }
    }
    
    private func setupWeekNumberView() {
        guard showWeekNumber else {
            weekNumberView?.removeFromSuperview()
            weekNumberView = nil
            return
        }
        
        let weekNumberView = CalendarWeekNumberView()
        weekNumberView.numberHeight = weekNumberHeight
        weekNumberView.addSeparator(position: .right)
        self.weekNumberView = weekNumberView
        updateWeekNumber()
        addSubview(weekNumberView)
        setNeedsLayout()
    }
    
    private func updateWeekNumber() {
        guard let weekNumberView = weekNumberView,
                let date = Date.dateFromComponents(weekView.visibleDateComponents) else {
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

