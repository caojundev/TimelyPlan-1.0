//
//  CalendarWeekDaysView.swift
//  TimelyPlan
//
//  Created by caojun on 2025/5/11.
//

import UIKit

class CalendarWeekDaysView: UIView {
    
    static var defaultHeight = 80.0

    /// 周开始日
    var weekStartDate: Date?
    
    /// 显示农历
    var showLunar: Bool = true
    
    /// 显示中国节假日
    var showChineseHolidays: Bool = true
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    /// 时间线背景图层
    private lazy var backgroundLayer: CalendarTimelineBackLayer = {
        let layer = CalendarTimelineBackLayer(mode: .week)
        layer.showHorizontalLines = false
        layer.leftDividerBottomMargin = 0.0
        return layer
    }()
    
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
        layer.addSublayer(backgroundLayer)
        for i in 0..<DAYS_PER_WEEK {
            let dayView = CalendarWeekDayInfoView()
            dayView.tag = i
            stackView.addArrangedSubview(dayView)
        }
    
        addSubview(stackView)
        addSeparator(position: .bottom)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        executeWithoutAnimation {
            self.backgroundLayer.frame = bounds
            self.backgroundLayer.updateColors()
        }

        stackView.frame = bounds
    }
    
    private var dayViews: [CalendarWeekDayInfoView] {
        return stackView.arrangedSubviews as! [CalendarWeekDayInfoView]
    }
    
    private func reset() {
        dayViews.forEach { view in
            view.reset()
        }
    }
    
    func reloadData() {
        guard let weekStartDate = weekStartDate else {
            reset()
            return
        }

        for dayView in dayViews {
            let date = weekStartDate.dateByAddingDays(dayView.tag)!
            let config = CalendarMonthDayConfig(date: date,
                                                showLunar: showLunar,
                                                showChineseHolidays: showChineseHolidays)
            dayView.update(with: config)
        }
    }
}
