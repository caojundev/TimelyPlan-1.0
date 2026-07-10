//
//  CalendarListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/7.
//

import Foundation
import UIKit

class CalendarListViewController: CalendarBaseViewController,
                                  CalendarWeekMonthExpandViewDelegate {
    
    var date: Date = .now
    
    private lazy var calendarView: CalendarWeekMonthExpandView = {
        let view = CalendarWeekMonthExpandView(frame: .zero, firstWeekday: .sunday)
        view.delegate = self
        return view
    }()

    private lazy var eventListView: CalendarEventListView = {
        let options = CalendarEventListOptions(date: .now)
        let view = CalendarEventListView(options: options)
        return view
    }()
    
    let contentView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.insertSubview(contentView, at: 0)
        contentView.addSubview(eventListView)
        contentView.addSubview(calendarView)
        updateTitle(with: date)
        
        eventListView.onEventSelected = { [weak self] event in
            self?.selectEvent(event)
        }
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
    }
    
    private func selectEvent(_ event: CalendarEvent) {
        TPImpactFeedback.impactWithSoftStyle()
        eventProcessor.clickEvent(event)
    }
    
    // MARK: - CalendarWeekMonthExpandViewDelegate
    func calendarWeekMonthExpandViewFrameChanged(_ view: CalendarWeekMonthExpandView) {
        layoutContents()
    }
}
