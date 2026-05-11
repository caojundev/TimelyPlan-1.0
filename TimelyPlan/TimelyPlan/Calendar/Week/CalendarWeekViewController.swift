//
//  CalendarWeekViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/30.
//

import Foundation

class CalendarWeekViewController: CalendarBaseViewController,
                                  CalendarWeekPageViewDelegate {

    private var firstWeekday: Weekday = .sunday

    /// 周视图
    private lazy var pageView: CalendarWeekPageView = {
        let view = CalendarWeekPageView(frame: .zero, visibleDate: .now)
        view.delegate = self
        return view
    }()
    
    private var dragDropManager: CalendarWeekDragDropManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.insertSubview(pageView, at: 0)
        pageView.reloadData()
        updateTitle(with: pageView.visibleDate)
        dragDropManager = CalendarWeekDragDropManager(pageView: pageView)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        pageView.frame = view.safeLayoutFrame()
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
