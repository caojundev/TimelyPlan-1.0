//
//  CalendarWeekViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/30.
//

import Foundation

class CalendarWeekViewController: CalendarBaseViewController,
                                  CalendarWeekPageViewDelegate,
                                  SettingAgentObserver {

    /// 周视图
    private lazy var pageView: CalendarWeekPageView = {
        let view = CalendarWeekPageView(frame: .zero, visibleDate: .now)
        view.daysInWeekView = CalendarSetting.shared.getDaysInWeek()
        view.firstWeekday = CalendarSetting.shared.firstWeekday
        view.showLunar = CalendarSetting.shared.showLunar
        view.showChineseHolidays = CalendarSetting.shared.showChineseHolidays
        view.showWeekNumber = CalendarSetting.shared.showWeekNumber
        view.delegate = self
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(pageView, at: 0)
        pageView.reloadData()
        updateTitle(with: pageView.visibleDate)
        CalendarSetting.shared.addObserver(self)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageView.frame = view.safeLayoutFrame()
    }
    
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = CalendarSetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .firstWeekday:
            pageView.firstWeekday = CalendarSetting.shared.firstWeekday
            pageView.reloadData()
        case .showWeekNumber:
            pageView.showWeekNumber = CalendarSetting.shared.showWeekNumber
        case .showLunar:
            pageView.showLunar = CalendarSetting.shared.showLunar
            pageView.reloadWeekDays()
        case .showChineseHolidays:
            pageView.showChineseHolidays = CalendarSetting.shared.showChineseHolidays
            pageView.reloadWeekDays()
        case .daysInWeek:
            pageView.daysInWeekView = CalendarSetting.shared.getDaysInWeek()
        default:
            break
        }
    }
    
    
    override func quickAddTaskDate() -> Date {
        let now = Date()
        var date = pageView.visibleDate ?? now
        if date.isPreviousDay(of: now) {
            date = now
        }
        
        return date
    }
        
    // MARK: - Update
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
    }
    
    // MARK: - Event Response
    override func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = pageView.visibleDate
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }

        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        let date = date.startOfMonth() /// 月开始日
        if date.isInSameMonthAs(pageView.visibleDate) {
            return
        }
        
        pageView.setVisibleDate(date, animated: true)
        updateTitle(with: date)
    }
    
    // MARK: - CalendarWeekPageViewDelegate
    func calendarWeekPageView(_ weekPageView: CalendarWeekPageView, didScrollTo date: Date) {
        updateTitle(with: date)
    }
}
