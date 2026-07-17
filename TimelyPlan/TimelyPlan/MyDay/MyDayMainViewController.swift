//
//  MyDayMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/13.
//

import Foundation
import UIKit

class MyDayMainViewController: TPViewController,
                               TPSidebarContent {

    var sidebarController: SidebarController?
    
    /// 单行周视图高度
    private let calendarWeekHeight: CGFloat = 60.0

    private lazy var calendarView: CalendarWeekMonthExpandView = {
        let firstWeekday = MyDaySetting.shared.firstWeekday
        let showLunar = MyDaySetting.shared.showLunar
        let showChineseHolidays = MyDaySetting.shared.showChineseHolidays
        let eventsInfoFetcher = MyDayRangeEventsInfoFetcher()
        let view = CalendarWeekMonthExpandView(frame: .zero,
                                               firstWeekday: firstWeekday,
                                               visibleDateComponents: date.yearMonthDayComponents,
                                               showLunar: showLunar,
                                               showChineseHolidays: showChineseHolidays,
                                               eventsInfoFetcher: eventsInfoFetcher)
        view.delegate = self
        return view
    }()
    
    private lazy var timelineView: MyDayTimelineView = {
        return MyDayTimelineView(frame: view.bounds)
    }()
    
    /// 日期按钮
    lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var moreBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(image: resGetImage("ellipsis_24"),
                                   style: .done,
                                   target: self,
                                   action: #selector(clickMore))
        return item
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
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        
        navigationItem.rightBarButtonItems = [moreBarButtonItem]
        navigationItem.titleView = dateButton
        view.addSubview(contentView)
        contentView.addSubview(timelineView)
        contentView.addSubview(calendarView)
        updateTitle(with: date)
        MyDaySetting.shared.addObserver(self)
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        contentView.frame = view.bounds
        layoutContents()
    }

    private func layoutContents() {
        calendarView.width = view.bounds.width
        calendarView.height = calendarView.contentHeight
        
        timelineView.width = view.bounds.width
        timelineView.height = view.height - calendarView.height
        timelineView.top = calendarView.bottom
    }
    
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
        dateButton.sizeToFit()
    }
    
    // MARK: - Event Response
    @objc private func clickMore() {
        TPImpactFeedback.impactWithSoftStyle()
        MyDayPresenter.showSetting()
    }
    
    @objc func clickDate(_ button: UIButton) {
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
}

extension MyDayMainViewController: SettingAgentObserver {
    
    func settingAgentDidChangeValue(for keyName: String) {
        guard let key = MyDaySetting.Key(name: keyName) else {
            return
        }
        
        switch key {
        case .firstWeekday:
            let firstWeekday = MyDaySetting.shared.firstWeekday
            calendarView.setFirstWeekday(firstWeekday)
        case .showLunar:
            let showLunar = MyDaySetting.shared.showLunar
            calendarView.setShowLunar(showLunar)
        case .showChineseHolidays:
            let showChineseHolidays = MyDaySetting.shared.showChineseHolidays
            calendarView.setShowChineseHolidays(showChineseHolidays)
        default:
            break
        }
    }

}

extension MyDayMainViewController: CalendarWeekMonthExpandViewDelegate {
    
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
//        reloadEvents(on: date, animated: true)
    }
    
    func calendarWeekMonthExpandViewFrameChanged(_ view: CalendarWeekMonthExpandView) {
        layoutContents()
    }
}
