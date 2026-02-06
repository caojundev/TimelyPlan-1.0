//
//  CalendarWeekViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/30.
//

import Foundation

class CalendarWeekViewController: TPViewController,
                                    CalendarTitleViewProvider,
                                    CalendarWeekPageViewDelegate {
    
    var titleView: UIView? {
        return dateButton
    }
    
    private var firstWeekday: Weekday = .sunday

    /// 日期按钮
    private lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()

    /// 周视图
    private lazy var pageView: CalendarWeekPageView = {
        let view = CalendarWeekPageView(frame: .zero, visibleDate: .now)
        view.delegate = self
        return view
    }()
    
    private var dragDropManager: CalendarWeekDragDropManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(pageView)
        pageView.reloadData()
        updateTitle(with: pageView.visibleDate)
        
        dragDropManager = CalendarWeekDragDropManager(pageView: pageView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageView.frame = view.safeLayoutFrame()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }

    // MARK: - Update
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
    }
    
    // MARK: - Event Response
    @objc func clickDate(_ button: UIButton) {
        pageView.goPreviousDay()
        
//        let datePickerVC = TPYearMonthDatePickerViewController()
//        datePickerVC.date = pageView.visibleDate
//        datePickerVC.didPickDate = { date in
//            self.pickDate(date)
//        }
//
//        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
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
    
    func calendarWeekPageView(_ weekPageView: CalendarWeekPageView, fetchEventsForWeek weekStartDate: Date, completion: @escaping ([CalendarEvent]?) -> Void) {
        
    }
}
