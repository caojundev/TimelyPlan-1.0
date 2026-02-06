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
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backLayer.frame = bounds
        backLayer.updateColors()
        CATransaction.commit()
        
        stackView.frame = bounds
    }
    
    private func reloadData() {
        let dayViews = stackView.arrangedSubviews as! [CalendarWeekSingleDayView]
        for dayView in dayViews {
            let days = dayView.tag
            
            if let date = weekStartDate?.dateByAddingDays(days) {
                let config = CalendarMonthDayConfig(date: date)
                dayView.update(with: config)
            } else {
                dayView.reset()
            }
        }
    }
}
