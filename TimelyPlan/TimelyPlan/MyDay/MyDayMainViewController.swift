//
//  MyDayMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/13.
//

import Foundation
import UIKit

class MyDayMainViewController: MyDayTimelinePageViewController,
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
                                               mode: .week,
                                               firstWeekday: firstWeekday,
                                               visibleDateComponents: visibleDate.yearMonthDayComponents,
                                               showLunar: showLunar,
                                               showChineseHolidays: showChineseHolidays,
                                               eventsInfoFetcher: eventsInfoFetcher)
        view.autoSwitchToWeekOnSelectDate = true
        view.delegate = self
        return view
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
    
    private lazy var maskView: UIView = {
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMaskView))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        view.contentView.addGestureRecognizer(gesture)
        return view
    }()
    
    // MARK: - AddView
    /// 返回和添加按钮视图
    private let backViewMargin = 15.0
    lazy var backTodayView: TPFlipBackTodayView = {
        let view = TPFlipBackTodayView()
        view.showTodayButton()
        view.didClickBack = { [weak self] _ in
            self?.clickBackToday()
        }
        
        return view
    }()
    
    private var visibleDate: Date

    init(date: Date = .now) {
        self.visibleDate = date
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
        contentView.addSubview(backTodayView)
        contentView.addSubview(maskView)
        contentView.addSubview(calendarView)
        pageView.setVisibleDate(visibleDate, animated: false)
        updateTitle(with: visibleDate)
        updateBackTodayView()
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
        maskView.frame = view.bounds
        layoutContents()
    }
    
    private func layoutContents() {
        let layoutFrame = view.safeLayoutFrame()
        calendarView.width = layoutFrame.width
        calendarView.height = calendarView.contentHeight
        
        let pageTop = calendarView.weekContentHeight
        pageView.width = layoutFrame.width
        pageView.height = layoutFrame.height - pageTop
        pageView.top = pageTop
        
        backTodayView.size = addView.size
        backTodayView.right = addView.left - backViewMargin
        backTodayView.centerY = addView.centerY
        
        let progress = calendarView.progress
        maskView.alpha = progress
        maskView.isUserInteractionEnabled = progress > 0
    }
    
    // MARK: - MyDayTimelinePageViewController
    override func pageViewDidChangeVisibleDate(_ date: Date) {
        visibleDate = date
        updateTitle(with: date)
        calendarView.setSelectedDate(date)
        updateBackTodayView()
    }
    
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
        dateButton.sizeToFit()
    }
    
    private func updateBackTodayView() {
        guard let date = calendarView.selectedDate else {
            return
        }
        
        if date.isToday {
            backTodayView.showTodayButton()
        }else{
            if date.compare(.now) == .orderedAscending {
                backTodayView.showLeftBackButton()
            } else {
                backTodayView.showRightBackButton()
            }
        }
    }
    
    // MARK: - Event Response
    private func clickBackToday() {
        let date = Date()
        visibleDate = date
        updateTitle(with: date)
        calendarView.setSelectedDate(date)
        pageView.setVisibleDate(date, animated: true)
        updateBackTodayView()
    }
    
    @objc private func didTapMaskView() {
        calendarView.switchMode(.week, animated: true)
    }
    
    @objc private func clickMore() {
        TPImpactFeedback.impactWithSoftStyle()
        MyDayPresenter.showSetting()
    }
    
    @objc private func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = visibleDate
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        guard !visibleDate.isInSameDayAs(date) else {
            return
        }
        
        visibleDate = date
        updateTitle(with: date)
        calendarView.setVisibleDateComponents(date.yearMonthDayComponents,
                                              animated: true)
    }

}

extension MyDayMainViewController: CalendarWeekMonthExpandViewDelegate {
    
    func calendarWeekMonthExpandView(_ view: CalendarWeekMonthExpandView, didChangeVisibleDate dateComponents: DateComponents) {
        guard let date = Date.dateFromComponents(dateComponents) else {
            return
        }
        
        visibleDate = date
        updateTitle(with: date)
    }
    
    func calendarWeekMonthExpandView(_ view: CalendarWeekMonthExpandView, didSelectDate dateComponents: DateComponents) {
        guard let date = Date.dateFromComponents(dateComponents) else {
            return
        }

        visibleDate = date
        updateTitle(with: date)
        pageView.setVisibleDate(date, animated: true)
        updateBackTodayView()
    }
    
    func calendarWeekMonthExpandViewFrameChanged(_ view: CalendarWeekMonthExpandView) {
        layoutContents()
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
        case .allDayEventsDisplayOption:
            let displayOption = MyDaySetting.shared.allDayEventsDisplayOption
            pageView.setAllDayEventsDisplayOption(displayOption)
        default:
            break
        }
    }
}
