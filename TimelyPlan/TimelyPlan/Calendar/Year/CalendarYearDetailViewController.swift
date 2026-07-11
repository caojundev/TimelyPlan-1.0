//
//  CalendarYearDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/7/11.
//

import Foundation
import UIKit

class CalendarYearDetailViewController: CalendarListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.titleView = titleView
    }
}
