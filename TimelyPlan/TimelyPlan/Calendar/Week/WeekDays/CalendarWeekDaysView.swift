//
//  CalendarWeekDaysView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/11.
//

import UIKit

class CalendarWeekDaysView: UIView {
    
    /// 周开始日
    var weekStartDate: Date? {
        didSet {
            if weekStartDate != oldValue {
                reloadData()
            }
        }
    }
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let backLayer = CalendarWeekDaysBackLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.addSublayer(backLayer)
        for i in 0..<DAYS_PER_WEEK {
            let dayView = CalendarWeekSingleDayView()
            dayView.tag = i
            stackView.addArrangedSubview(dayView)
        }
    
        addSubview(stackView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.backLayer.frame = bounds
            self.backLayer.updateColors()
        }

        stackView.frame = bounds
    }
    
    private var dayViews: [CalendarWeekSingleDayView] {
        return stackView.arrangedSubviews as! [CalendarWeekSingleDayView]
    }
    
    private func reset() {
        dayViews.forEach { view in
            view.reset()
        }
    }
    
    private func reloadData() {
        guard let weekStartDate = weekStartDate else {
            reset()
            return
        }

        for dayView in dayViews {
            let date = weekStartDate.dateByAddingDays(dayView.tag)!
            let config = CalendarMonthDayConfig(date: date)
            dayView.update(with: config)
        }
    }
}
