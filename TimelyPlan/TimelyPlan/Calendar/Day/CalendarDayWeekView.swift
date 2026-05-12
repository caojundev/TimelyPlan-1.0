//
//  CalendarDayWeekView.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/12.
//

import Foundation
import UIKit

class CalendarDayWeekView: UIView {
    
    var firstWeekday: Weekday {
        get {
            return weekView.firstWeekday
        }
        
        set {
            weekView.firstWeekday = newValue
        }
    }
    
    var selection: TPCalendarDateSelection? {
        get {
            return weekView.selection
        }
        
        set {
            weekView.selection = newValue
        }
    }
    
    var showWeekNumber: Bool = true {
        didSet {
            if showWeekNumber != oldValue {
                setupWeekNumberView()
            }
        }
    }
    
    private let weekNumberWidth = 32.0
    private let weekNumberHeight = 24.0
    private var weekNumberView: CalendarWeekNumberView?
    
    private lazy var weekView: TPCalendarScrollableWeekView = {
        let view = TPCalendarScrollableWeekView(frame: .zero)
        view.firstWeekday
        view.didChangeVisibleDateComponents = { [weak self] _, _ in
            self?.updateWeekNumber()
        }
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(weekView)
        setupWeekNumberView()
        addSeparator(position: .right)
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
            let padding = UIEdgeInsets(top: 30.0, left: 5.0, bottom: 10.0, right: 5.0)
            weekNumberView.padding = padding
            weekNumberView.separatorEdgeInset = UIEdgeInsets(top: padding.top, bottom: padding.bottom)
            weekNumberView.frame = CGRect(x: 0.0, y: 0.0, width: weekNumberWidth, height: height)
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
        weekNumberView.backgroundColor = .systemBackground
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

