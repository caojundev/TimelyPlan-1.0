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
        view.autoSwitchToWeekOnSelectDate = true
        view.delegate = self
        return view
    }()
    
    /// 页面视图
    private lazy var pageView: MyDayTimelinePageView = {
        let view = MyDayTimelinePageView(frame: .zero)
        view.delegate = self
        view.eventAddController = self.addController
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
    /// 添加视图按钮
    private let addViewSize = CGSize(width: 40.0, height: 40.0)
    
    /// 添加视图边界间距
    private let addViewMargins = UIEdgeInsets(top: 10.0,
                                              left: 0.0,
                                              bottom: 10.0,
                                              right: 20.0)
    
    /// 添加视图
    private lazy var addView: TPAddView = {
        let view = TPAddView()
        view.normalBackgroundColor = .primary
        view.didClickAdd = { [weak self] _ in
            self?.clickEventAdd()
        }
       
        return view
    }()
    
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
    
    private let contentView = UIView()
    
    private var visibleDate: Date

    /// 待办任务快速添加控制器
    private lazy var quickAddManager: TodoTaskQuickAddManager = {
        let options = TodoQuickAddOptions(showMoreSetting: false,
                                          forbidContinuousAdd: true)
        let manager = TodoTaskQuickAddManager(containerViewController: self, options: options)
        return manager
    }()
    
    private lazy var addController: MyDayEventAddController = {
        let controller = MyDayEventAddController()
        controller.quickAddManager = quickAddManager
        return controller
    }()
    
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
        contentView.addSubview(backTodayView)
        contentView.addSubview(addView)
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
        
        addView.size = addViewSize
        addView.bottom = layoutFrame.maxY - addViewMargins.bottom
        addView.right = layoutFrame.maxX - addViewMargins.right
        
        backTodayView.size = addView.size
        backTodayView.right = addView.left - backViewMargin
        backTodayView.centerY = addView.centerY
        
        let progress = calendarView.progress
        maskView.alpha = progress
        maskView.isUserInteractionEnabled = progress > 0
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
    
    func clickEventAdd() {
        TPImpactFeedback.impactWithSoftStyle()
        let menuController = MyDayEventAddMenuController()
        menuController.didSelectMenuActionType = { [weak self] type in
            guard let self = self, let date = self.pageView.visibleDate else { return }
            self.addController.performAddMenuAction(with: type, on: date)
        }

        let sourceRect = addView.bounds.insetBy(dx: -5.0, dy: -5.0)
        menuController.showMenu(from: addView,
                                sourceRect: sourceRect,
                                isCovered: true)
    }
    
    @objc private func didTapMaskView() {
        calendarView.switchMode(.week, animated: true)
    }
    
    @objc private func clickMore() {
        TPImpactFeedback.impactWithSoftStyle()
//        MyDayPresenter.showSetting()
        
        let vc = IAPMainViewController()
        vc.showAsNavigationRoot()
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

extension MyDayMainViewController: TPDayPageViewDelegate {
    
    // MARK: - TPDayPageViewDelegate
    func dayPageViewWillEndDragging(_ pageView: TPDayPageView, withTargetDate targetDate: Date) {
        visibleDate = targetDate
        updateTitle(with: targetDate)
        calendarView.setSelectedDate(targetDate)
        updateBackTodayView()
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
        default:
            break
        }
    }
}
