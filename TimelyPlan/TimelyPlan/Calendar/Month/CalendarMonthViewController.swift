//
//  CalendarMonthViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2025/4/27.
//

import Foundation

class CalendarMonthViewController: TPViewController,
                                   CalendarTitleViewProvider,
                                   CalendarMonthViewDelegate {
    var titleView: UIView? {
        return dateButton
    }
    
    /// 标题视图
    private lazy var dateButton: CalendarDateButton = {
        let button = CalendarDateButton()
        button.addTarget(self, action: #selector(clickDate(_:)), for: .touchUpInside)
        return button
    }()

    private lazy var monthView: CalendarMonthView = {
        let view = CalendarMonthView(frame: view.bounds, monthDate: .now)
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(monthView)
        updateTitle(with: monthView.visibleMonthDate)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        monthView.frame = view.safeLayoutFrame()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemGroupedBackground
    }
    
    private func updateTitle(with date: Date) {
        dateButton.title = date.slashFormattedYearMonthString
    }
    
    @objc func clickDate(_ button: UIButton) {
        let datePickerVC = TPYearMonthDatePickerViewController()
        datePickerVC.date = monthView.visibleMonthDate
        datePickerVC.didPickDate = { date in
            self.pickDate(date)
        }
        
        datePickerVC.popoverShow(from: button, preferredPosition: .bottomCenter)
    }
    
    private func pickDate(_ date: Date) {
        let date = date.startOfMonth()
        if date.isInSameMonthAs(monthView.visibleMonthDate) {
            return
        }
        
        monthView.setVisibleDate(date)
        updateTitle(with: date)
    }
    
    // MARK: - CalendarMonthViewDelegate
    func calendarMonthView(_ monthView: CalendarMonthView, didScrollTo topWeekStartDate: Date) {
        let monthDate = monthView.visibleMonthDate(with: topWeekStartDate)
        updateTitle(with: monthDate)
    }
    
    func calendarMonthView(_ monthView: CalendarMonthView, fetchEventsForWeek weekStartDate: Date, completion: @escaping ([CalendarEvent]?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var events = [CalendarEvent]()
            var event = CalendarEvent(name: "事件名称1",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(1)!,
                                      endDate: weekStartDate.dateByAddingDays(2)!)
            events.append(event)

            event = CalendarEvent(name: "事件名称2",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(2)!,
                                      endDate: weekStartDate.dateByAddingDays(4)!)
            events.append(event)

            event = CalendarEvent(name: "事件名称3",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(3)!,
                                      endDate: weekStartDate.dateByAddingDays(3)!)
            events.append(event)
            
            event = CalendarEvent(name: "事件名称4",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(1)!,
                                      endDate: weekStartDate.dateByAddingDays(4)!)
            events.append(event)
            
            event = CalendarEvent(name: "事件名称5",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(1)!,
                                      endDate: weekStartDate.dateByAddingDays(1)!)
            events.append(event)
            
            event = CalendarEvent(name: "事件名称6",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(4)!,
                                      endDate: weekStartDate.dateByAddingDays(5)!)
            events.append(event)
            
            event = CalendarEvent(name: "事件名称7",
                                  color: CalendarEventColor.random,
                                  startDate: weekStartDate,
                                  endDate: weekStartDate.dateByAddingDays(1)!)
            events.append(event)
            
            event = CalendarEvent(name: "事件名称8",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(1)!,
                                      endDate: weekStartDate.dateByAddingDays(1)!)
            events.append(event)
            
            event = CalendarEvent(name: "事件名称9",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(1)!,
                                      endDate: weekStartDate.dateByAddingDays(1)!)
            events.append(event)
            
            event = CalendarEvent(name: "事件名称10",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(1)!,
                                      endDate: weekStartDate.dateByAddingDays(2)!)
            events.append(event)
            
            event = CalendarEvent(name: "事件名称11",
                                      color: CalendarEventColor.random,
                                        startDate: weekStartDate.dateByAddingDays(2)!,
                                      endDate: weekStartDate.dateByAddingDays(2)!)
            events.append(event)

            DispatchQueue.main.async {
                completion(events)
            }
        }
    }
}
