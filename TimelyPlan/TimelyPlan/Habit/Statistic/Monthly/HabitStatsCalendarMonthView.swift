//
//  HabitStatsCalendarMonthView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/10/2.
//

import Foundation
import UIKit

class HabitStatsCalendarMonthView: UIView {

    /// 周符号高度
    static let symbolsViewHeight: CGFloat = 40.0
    
    /// 日单元格高度
    static let dayCellHeight: CGFloat = 75.0

    weak var monthViewDelegate: TPCalendarMonthViewDelegate? {
        get {
            return monthView.delegate
        }
        
        set {
            monthView.delegate = newValue
        }
    }
    
    var date: Date = Date()
    
    /// 未来日是否可用
    var isFutureDayEnabled: Bool = true
    
    /// 周开始日
    var firstWeekday: Weekday = .sunday

    /// 周符号视图
    private lazy var symbolsView: TPWeekdaySymbolView = {
        let view = TPWeekdaySymbolView(frame: .zero)
        view.alpha = 0.8
        view.textColor = resGetColor(.title)
        view.style = .short
        return view
    }()

    /// 月视图
    private lazy var monthView: TPCalendarMonthView = {
        let view = TPCalendarMonthView(frame: bounds)
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
        addSubview(symbolsView)
        addSubview(monthView)
        reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        symbolsView.width = bounds.width
        symbolsView.height = Self.symbolsViewHeight
        
        monthView.width = bounds.width
        monthView.height = bounds.height - symbolsView.height
        monthView.top = symbolsView.bottom
    }
    
    func reloadData() {
        symbolsView.firstWeekday = firstWeekday
        symbolsView.reloadData()
        monthView.configure(firstWeekday: firstWeekday,
                            visibleDateComponents: date.yearMonthDayComponents)
    }
}
