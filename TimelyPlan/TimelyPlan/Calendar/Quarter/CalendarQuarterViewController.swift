//
//  CalendarQuarterViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/5.
//

import Foundation
import UIKit

class CalendarQuarterViewController: CalendarBaseViewController,
                                     CalendarMonthViewDelegate,
                                     SettingAgentObserver {

    private lazy var quarterView: CalendarQuarterView = {
        let firstWeekday = CalendarSetting.shared.firstWeekday
        let view = CalendarQuarterView(frame: view.bounds,
                                       monthDate: .now,
                                       firstWeekday: firstWeekday)
        view.preferredWeeksCount = CalendarSetting.shared.getWeeksInQuarter()
        view.showLunar = CalendarSetting.shared.showLunar
        view.showChineseHolidays = CalendarSetting.shared.showChineseHolidays
        view.showWeekNumber = CalendarSetting.shared.showWeekNumber
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(quarterView, at: 0)
        quarterView.reloadData()
        updateTitle(with: quarterView.visibleMonthDate)
        CalendarSetting.shared.addObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        quarterView.frame = view.safeLayoutFrame()
    }
    
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = CalendarSetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .firstWeekday:
            quarterView.firstWeekday = CalendarSetting.shared.firstWeekday
            quarterView.reloadData()
        case .showWeekNumber:
            quarterView.showWeekNumber = CalendarSetting.shared.showWeekNumber
            quarterView.reloadWeekNumber()
        case .showLunar:
            quarterView.showLunar = CalendarSetting.shared.showLunar
            quarterView.reloadWeekDays()
        case .showChineseHolidays:
            quarterView.showChineseHolidays = CalendarSetting.shared.showChineseHolidays
            quarterView.reloadWeekDays()
        case .weeksInQuarter:
            quarterView.preferredWeeksCount = CalendarSetting.shared.getWeeksInQuarter()
        default:
            break
        }
    }
    
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
    }
    
    override func quickAddTaskDate() -> Date {
        let now = Date()
        var date = quarterView.topWeekStartDate ?? now
        if date.isPreviousDay(of: now) {
            date = now
        }
        
        return date
    }
    
    override func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = quarterView.visibleMonthDate
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        let date = date.startOfMonth()
        if date.isInSameMonthAs(quarterView.visibleMonthDate) {
            return
        }
        
        quarterView.setVisibleDate(date)
        updateTitle(with: date)
    }
    
    // MARK: - CalendarMonthViewDelegate
    func calendarMonthView(_ monthView: CalendarMonthView, didScrollTo topWeekStartDate: Date) {
        let monthDate = monthView.visibleMonthDate(with: topWeekStartDate)
        updateTitle(with: monthDate)
    }
    
    func calendarMonthView(_ monthView: CalendarMonthView, didLongPressDate date: Date) {
        TPImpactFeedback.impactWithLightStyle()
        showQuickAddTask(on: date)
    }
    
    func calendarMonthView(_ monthView: CalendarMonthView, didTapDate date: Date) {
        TPImpactFeedback.impactWithLightStyle()
        showEventList(on: date)
    }
}
