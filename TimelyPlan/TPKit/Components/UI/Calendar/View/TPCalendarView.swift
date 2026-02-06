//
//  TPCalendarView.swift
//  TimelyPlan
//
//  Created by caojun on 2023/8/11.
//

import Foundation
import UIKit

class TPCalendarView: UIView, TPPreviousNextDateViewDelegate {
    
    /// 月视图代理对象
    weak var monthViewDelegate: TPCalendarMonthViewDelegate? {
        get {
            return monthView.delegate
        }
        
        set {
            monthView.delegate = newValue
        }
    }
    
    /// 可见月改变回调
    var visibleDateDidChange: ((DateComponents) -> Void)?
    
    /// 上/下月份视图高度
    let kPreviousNextMonthHeight = 60.0
    
    /// 周符号视图高度
    let kWeekdaySymbolHeight = 20.0

    /// 当前月份日期组件
    private(set) var visibleDateComponents: DateComponents = Date().yearMonthComponents

    /// 日期选择管理器
    var selection: TPCalendarDateSelection? {
        get { return monthView.selection }
        set { monthView.selection = newValue }
    }
    
    /// 上下月选择视图
    private var previousNextView: TPPreviousNextMonthView!

    /// 周符号视图
    private var weekdaySymbolsView: TPWeekdaySymbolView!
    
    /// 月份视图
    private var monthView: TPCalendarScrollableMonthView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.tintColor = Color(0x0066FF)
        
        previousNextView = TPPreviousNextMonthView()
        previousNextView.delegate = self
        addSubview(previousNextView)
        
        weekdaySymbolsView = TPWeekdaySymbolView(frame: .zero)
        addSubview(weekdaySymbolsView)
        
        monthView = TPCalendarScrollableMonthView(frame: .zero)
        monthView.didChangeVisibleDateComponents = { [weak self] (current, previous) in
            self?.visibleDateComponents = current
            self?.didChangeVisibleDateComponents(currentDateComponents: current,
                                                 previousDateComponents: previous)
        }
        
        addSubview(monthView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        previousNextView.width = self.width
        previousNextView.height = kPreviousNextMonthHeight
        
        weekdaySymbolsView.width = self.width
        weekdaySymbolsView.height = kWeekdaySymbolHeight
        weekdaySymbolsView.top = previousNextView.bottom
        
        monthView.width = self.width
        monthView.height = self.height - kPreviousNextMonthHeight - kWeekdaySymbolHeight
        monthView.top = weekdaySymbolsView.bottom
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: kPopoverPreferredContentWidth, height: 420.0)
    }
    
    private func didChangeVisibleDateComponents(currentDateComponents: DateComponents,
                                                previousDateComponents: DateComponents) {
        if let toDate = Date.dateFromComponents(currentDateComponents) {
            previousNextView.setDate(toDate, animated: true)
        }
        
        visibleDateDidChange?(currentDateComponents)
    }

    // MARK: - TPPreviousNextDateViewDelegate
    func prviousNextDateView(_ view: TPPreviousNextDateView, didSelectDate date: Date) {
        let currentDateComponents = date.yearMonthComponents
        visibleDateComponents = currentDateComponents
        
        let previousDateComponents = monthView.visibleDateComponents
        monthView.visibleDateComponents = currentDateComponents
        
        let animateStyle = SlideStyle.horizontalStyle(fromValue: previousDateComponents,
                                                      toValue: currentDateComponents)
        monthView.reloadData(animateStyle: animateStyle)
        visibleDateDidChange?(currentDateComponents)
    }
    
    // MARK: - Public Methods
    func reloadData() {
        let date = Date.dateFromComponents(visibleDateComponents) ?? Date()
        previousNextView.date = date
        monthView.visibleDateComponents = visibleDateComponents
        monthView.reloadData()
    }
    
    func setVisibleDateComponents(_ dateComponents: DateComponents, animated: Bool = false) {
        if visibleDateComponents.isInSameMonth(as: dateComponents) {
            return
        }
        
        visibleDateComponents = dateComponents
        monthView.setVisibleDateComponents(dateComponents, animated: animated)
        if let date = Date.dateFromComponents(dateComponents) {
            previousNextView.setDate(date, animated: animated)
        }
    }
}
