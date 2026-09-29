//
//  CalendarPanelViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/28.
//

import Foundation
import UIKit

class CalendarPanelViewController: CalendarBaseViewController,
                                   TPDayPageViewDelegate,
                                   SettingAgentObserver {
    
    private lazy var pageView: CalendarPanelPageView = {
        let firstWeekday = CalendarSetting.shared.firstWeekday
        let view = CalendarPanelPageView(firstWeekday: firstWeekday)
        view.showLunar = CalendarSetting.shared.showLunar
        view.showChineseHolidays = CalendarSetting.shared.showChineseHolidays
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
        
//        switch key {
//        case .firstWeekday:
//            pageView.firstWeekday = CalendarSetting.shared.firstWeekday
//            pageView.reloadData()
//        case .showWeekNumber:
//            pageView.showWeekNumber = CalendarSetting.shared.showWeekNumber
//        case .showLunar:
//            pageView.showLunar = CalendarSetting.shared.showLunar
//            pageView.reloadWeekDays()
//        case .showChineseHolidays:
//            pageView.showChineseHolidays = CalendarSetting.shared.showChineseHolidays
//            pageView.reloadWeekDays()
//        case .daysInWeek:
//            pageView.displayDays = CalendarSetting.shared.getDaysInWeek()
//        default:
//            break
//        }
    }
    
    override func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = pageView.visibleDate
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }

        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        let date = pageView.validatedDate(date.startOfMonth())
        if date.isInSameMonthAs(pageView.visibleDate) {
            return
        }
        
        pageView.setVisibleDate(date, animated: true)
        updateTitle(with: date)
    }
    
    // MARK: - Update
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
    }

    // MARK: - TPDayPageViewDelegate
    func dayPageView(_ pageView: TPDayPageView, didChangeVisibleDateFromDate fromDate: Date, toDate: Date) {
    }
    
    func dayPageViewWillEndDragging(_ pageView: TPDayPageView, withTargetDate targetDate: Date) {
        updateTitle(with: targetDate)
        print(targetDate.yearMonthDayString)
    }

}
