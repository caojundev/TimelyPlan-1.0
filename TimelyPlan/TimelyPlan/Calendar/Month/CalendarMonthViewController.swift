//
//  CalendarMonthViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/27.
//

import Foundation

class CalendarMonthViewController: CalendarBaseViewController,
                                   CalendarMonthViewDelegate,
                                    SettingAgentObserver {

    private lazy var monthView: CalendarMonthView = {
        let firstWeekday = CalendarSetting.shared.firstWeekday
        let view = CalendarMonthView(frame: view.bounds, monthDate: .now, firstWeekday: firstWeekday)
        view.weeksInMonth = CalendarSetting.shared.getWeeksInMonth()
        view.showLunar = CalendarSetting.shared.showLunar
        view.showChineseHolidays = CalendarSetting.shared.showChineseHolidays
        view.showWeekNumber = CalendarSetting.shared.showWeekNumber
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(monthView, at: 0)
        monthView.reloadData()
        updateTitle(with: monthView.visibleMonthDate)
        CalendarSetting.shared.addObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        monthView.frame = view.safeLayoutFrame()
    }
    
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = CalendarSetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .firstWeekday:
            monthView.firstWeekday = CalendarSetting.shared.firstWeekday
            monthView.reloadData()
        case .showWeekNumber:
            monthView.showWeekNumber = CalendarSetting.shared.showWeekNumber
            monthView.reloadWeekNumber()
        case .showLunar:
            monthView.showLunar = CalendarSetting.shared.showLunar
            monthView.reloadWeekDays()
        case .showChineseHolidays:
            monthView.showChineseHolidays = CalendarSetting.shared.showChineseHolidays
            monthView.reloadWeekDays()
        case .weeksInMonth:
            monthView.weeksInMonth = CalendarSetting.shared.getWeeksInMonth()
        default:
            break
        }
    }
    
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
    }
    
    override func quickAddTaskDate() -> Date {
        let now = Date()
        var date = monthView.topWeekStartDate ?? now
        if date.isPreviousDay(of: now) {
            date = now
        }
        
        return date
    }
    
    override func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = monthView.visibleMonthDate
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        let date = date.startOfMonth()
        if date.isInSameMonthAs(monthView.visibleMonthDate) {
            return
        }
        
        monthView.setVisibleDate(date)
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
    
    func calendarMonthView(_ monthView: CalendarMonthView, didTapEvent event: CalendarEvent) {
        TPImpactFeedback.impactWithLightStyle()
        eventProcessor.editEvent(event)
    }
    
    func calendarMonthView(_ monthView: CalendarMonthView, didTapMoreOnDate date: Date) {
        TPImpactFeedback.impactWithLightStyle()
        showEventSheet()
    }
    
    func calendarMonthView(_ monthView: CalendarMonthView, didTapDate date: Date) {
        showEventSheet()
    }
}
