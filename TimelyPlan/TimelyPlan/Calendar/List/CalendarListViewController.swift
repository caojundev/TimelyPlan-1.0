//
//  CalendarListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/7.
//

import Foundation
import UIKit

class CalendarListViewController: CalendarBaseViewController,
                                  CalendarWeekMonthExpandViewDelegate,
                                  SettingAgentObserver {

    private lazy var calendarView: CalendarWeekMonthExpandView = {
        let firstWeekday = CalendarSetting.shared.firstWeekday
        let showLunar = CalendarSetting.shared.showLunar
        let showChineseHolidays = CalendarSetting.shared.showChineseHolidays
        let eventsInfoFetcher = CalendarRangeEventsInfoFetcher()
        let view = CalendarWeekMonthExpandView(frame: .zero,
                                               mode: .month,
                                               firstWeekday: firstWeekday,
                                               visibleDateComponents: date.yearMonthDayComponents,
                                               showLunar: showLunar,
                                               showChineseHolidays: showChineseHolidays,
                                               eventsInfoFetcher: eventsInfoFetcher)
        view.delegate = self
        return view
    }()

    private lazy var eventListView: CalendarEventListView = {
        let view = CalendarEventListView(frame: view.bounds)
        return view
    }()
    
    private let contentView = UIView()
    
    private(set) var date: Date
    
    init(date: Date = .now) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.insertSubview(contentView, at: 0)
        contentView.addSubview(eventListView)
        contentView.addSubview(calendarView)
        updateTitle(with: date)
        eventListView.onEventSelected = { [weak self] event in
            self?.selectEvent(event)
        }
        
        reloadEvents(on: date, animated: false)
        CalendarSetting.shared.addObserver(self)
    }
     
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = view.bounds
        layoutContents()
    }

    private func layoutContents() {
        calendarView.width = view.bounds.width
        calendarView.height = calendarView.contentHeight
        
        eventListView.width = view.bounds.width
        eventListView.height = view.height - calendarView.height
        eventListView.top = calendarView.bottom
    }
    
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
        dateButton.sizeToFit()
    }
    
    override func clickAddTask() {
        super.clickAddTask()
        calendarView.switchMode(.week, animated: true)
    }
   
    override func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = date
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        updateTitle(with: date)
        calendarView.setVisibleDateComponents(date.yearMonthDayComponents, animated: true)
    }
    
    private func selectEvent(_ event: CalendarEvent) {
        TPImpactFeedback.impactWithSoftStyle()
        eventProcessor.clickEvent(event)
    }
    
    private func reloadEvents(on date: Date, animated: Bool) {
        let options = CalendarEventListOptions(date: date)
        eventListView.reloadEvents(options: options, animated: animated)
    }
    
    // MARK: -
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = CalendarSetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .firstWeekday:
            let firstWeekday = CalendarSetting.shared.firstWeekday
            calendarView.setFirstWeekday(firstWeekday)
        case .showLunar:
            let showLunar = CalendarSetting.shared.showLunar
            calendarView.setShowLunar(showLunar)
        case .showChineseHolidays:
            let showChineseHolidays = CalendarSetting.shared.showChineseHolidays
            calendarView.setShowChineseHolidays(showChineseHolidays)
        default:
            break
        }
    }

    // MARK: - CalendarWeekMonthExpandViewDelegate
    
    func calendarWeekMonthExpandView(_ view: CalendarWeekMonthExpandView, didChangeVisibleDate dateComponents: DateComponents) {
        guard let date = Date.dateFromComponents(dateComponents) else {
            return
        }
        
        self.date = date
        updateTitle(with: date)
    }
    
    func calendarWeekMonthExpandView(_ view: CalendarWeekMonthExpandView, didSelectDate dateComponents: DateComponents) {
        guard let date = Date.dateFromComponents(dateComponents),
                !self.date.isInSameDayAs(date) else {
            return
        }

        self.date = date
        updateTitle(with: date)
        reloadEvents(on: date, animated: true)
    }
    
    func calendarWeekMonthExpandViewFrameChanged(_ view: CalendarWeekMonthExpandView) {
        layoutContents()
    }
}
