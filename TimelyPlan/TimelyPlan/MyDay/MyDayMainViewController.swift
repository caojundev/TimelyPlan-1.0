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
                                               mode: .week,
                                               firstWeekday: firstWeekday,
                                               visibleDateComponents: visibleDate.yearMonthDayComponents,
                                               showLunar: showLunar,
                                               showChineseHolidays: showChineseHolidays,
                                               eventsInfoFetcher: eventsInfoFetcher)
        view.delegate = self
        return view
    }()
    
    /// 页面视图
    private lazy var pageView: MyDayTimelinePageView = {
        let view = MyDayTimelinePageView(frame: .zero)
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
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let view = UIVisualEffectView(effect: blurEffect)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapMaskView))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        view.contentView.addGestureRecognizer(gesture)
        return view
    }()
    
    private let contentView = UIView()
    
    private(set) var visibleDate: Date
    
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
        view.addSubview(contentView)
        contentView.addSubview(pageView)
        contentView.addSubview(maskView)
        contentView.addSubview(calendarView)
        pageView.setVisibleDate(visibleDate, animated: false)
        updateTitle(with: visibleDate)
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
        
        let progress = calendarView.progress
        maskView.alpha = progress
        maskView.isUserInteractionEnabled = progress > 0
    }
    
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
        dateButton.sizeToFit()
    }
    
    // MARK: - Event Response
    @objc func didTapMaskView() {
        calendarView.switchMode(.week, animated: true)
    }
    
    @objc private func clickMore() {
        TPImpactFeedback.impactWithSoftStyle()
        MyDayPresenter.showSetting()
    }
    
    @objc func clickDate(_ button: UIButton) {
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
        calendarView.setVisibleDateComponents(date.yearMonthDayComponents, animated: true)
    }
    
}

extension MyDayMainViewController: TPDayPageViewDelegate {
    
    // MARK: - TPDayPageViewDelegate
    func dayPageViewWillEndDragging(_ pageView: TPDayPageView, withTargetDate targetDate: Date) {
        visibleDate = targetDate
        updateTitle(with: targetDate)
        calendarView.setSelectedDate(targetDate)
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
        default:
            break
        }
    }

}
