//
//  CalendarDayViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/30.
//

import Foundation

class CalendarDayViewController: TPViewController,
                                 CalendarTitleViewProvider,
                                 CalendarDatePageViewDelegate,
                                 TPCalendarSingleDateSelectionDelegate {

    /// 标题视图
    var titleView: UIView? {
        return dateButton
    }
    
    private var date: Date = .now
    
    /// 日期按钮
    private lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()

    /// 周视图
    private let weekViewHeight = 80.0
    private lazy var weekView: TPCalendarScrollableWeekView = {
        let view = TPCalendarScrollableWeekView(frame: .zero)
        view.selection = selection
        view.addSeparator(position: .bottom)
        return view
    }()
    
    /// 日期选择管理器
    private lazy var selection: TPCalendarSingleDateSelection = {
        let selection = TPCalendarSingleDateSelection()
        selection.setSelectedDateComponents(date.yearMonthDayComponents)
        selection.delegate = self
        return selection
    }()

    private lazy var pageView: CalendarDayPagingView = {
        let view = CalendarDayPagingView(frame: .zero)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(weekView)
        view.addSubview(pageView)
        weekView.reloadData()
        pageView.reloadData()
        updateTitle(with: date)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let layoutFrame = view.safeLayoutFrame()
        weekView.width = layoutFrame.width
        weekView.height = weekViewHeight
        weekView.top = layoutFrame.minY
        
        pageView.width = layoutFrame.width
        pageView.height = layoutFrame.height - weekViewHeight
        pageView.top = weekView.bottom
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    // MARK: - Update
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthDayString
    }
    
    private func updateWeekView(with date: Date, animated: Bool = true) {
        let dateComponents = date.yearMonthDayComponents
        selection.setSelectedDateComponents(dateComponents)
        weekView.setVisibleDateComponents(dateComponents, animated: animated)
    }
    
    private func updatePagingView(with date: Date, animated: Bool = true) {
        pageView.setVisibleDate(date, animated: animated)
    }
    
    // MARK: - Event Response
    @objc func clickDate(_ button: UIButton) {
        let vc = TPCalendarViewController(date: date)
        vc.didSelectDate = { date in
            self.pickDate(date)
        }
        
        vc.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        if self.date.isInSameDayAs(date) {
            return
        }
        
        self.date = date
        updateTitle(with: date)
        updateWeekView(with: date)
        updatePagingView(with: date)
    }
    
    // MARK: - TPCalendarSingleDateSelectionDelegate
    func singleDateSelection(_ selection: TPCalendarSingleDateSelection, didSelect date: DateComponents) {
        guard let selectedDate = Date.dateFromComponents(date) else {
            return
        }
        
        self.date = selectedDate
        updateTitle(with: selectedDate)
        updatePagingView(with: selectedDate)
    }
    
    // MARK: - CalendarDayPagingViewDelegate
    func calendarDayPagingViewWillEndDragging(_ pageView: CalendarDatePageView, withTargetDate targetDate: Date) {
        if self.date.isInSameDayAs(targetDate) {
            return
        }
            
        self.date = targetDate
        updateTitle(with: targetDate)
        updateWeekView(with: targetDate)
    }

}
