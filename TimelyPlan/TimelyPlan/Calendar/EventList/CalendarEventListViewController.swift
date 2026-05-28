//
//  CalendarEventListViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/28.
//

import Foundation

class CalendarEventListViewController: TPViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let date = Date()
        title = date.yearMonthDayString
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
    }
}
