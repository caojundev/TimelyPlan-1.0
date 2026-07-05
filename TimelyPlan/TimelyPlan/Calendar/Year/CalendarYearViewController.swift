//
//  CalendarYearViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/3.
//

import Foundation
import UIKit

class CalendarYearViewController: TPViewController,
                                  CalendarTitleViewProvider {
    
    /// 标题视图
    var titleView: UIView? {
        return dateButton
    }

    /// 日期按钮
    lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()

    private var calendarYearView: CalendarYearView!
    
    private var currentYearDate: Date {
        let year = calendarYearView.currentDisplayYear
        let date = Date()
        return date.dateByReplacingYear(year)
    }
    
    private let eventsProvider = CalendarYearEventsFetcher()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarYearView = CalendarYearView(frame: view.bounds)
        calendarYearView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        calendarYearView.delegate = self
        calendarYearView.eventsProvider = eventsProvider
        view.addSubview(calendarYearView)
        
        // 立即布局，确保 frame 正确
        calendarYearView.layoutIfNeeded()
        
        // 无动画滚动到今年
        calendarYearView.scrollToCurrentYear(animated: false)
        
        updateTitle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保在视图出现前再次确认位置
        if calendarYearView != nil {
            calendarYearView.scrollToCurrentYear(animated: false)
        }
    }
    
    private func updateTitle() {
        dateButton.title = "\(calendarYearView.currentDisplayYear)"
    }

    @objc private func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController(mode: .yearOnly)
        datePickerVC.date = currentYearDate
        datePickerVC.yearRange = CalendarYearConfig.yearRange
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        let year = date.year
        guard calendarYearView.currentDisplayYear != year else {
            return
        }
        
        calendarYearView.scrollToYear(year: year, animated: true)
        updateTitle()
    }
}

// MARK: - CalendarYearViewDelegate
extension CalendarYearViewController: CalendarYearViewDelegate {
    
    func calendarYearView(_ view: CalendarYearView, didChangeYearTo year: Int) {
        // 更新标题
        updateTitle()
    }
}
