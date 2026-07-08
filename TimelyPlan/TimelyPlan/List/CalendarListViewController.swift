//
//  CalendarListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/7.
//

import Foundation
import UIKit

class CalendarListViewContller: TPViewController {
    
    private lazy var calendarView: CalendarWeekMonthExpandView = {
        let view = CalendarWeekMonthExpandView(frame: .zero, firstWeekday: .sunday)
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
        view.addSubview(calendarView)
        calendarView.width = view.width
        calendarView.height = 480.0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

}
