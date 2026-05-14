//
//  CalendarEventAlertEditViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/14.
//

import Foundation
import UIKit

class CalendarEventAlertEditViewController: ReminderEditViewController {

    init(reminder: TaskReminder?, isAllDay: Bool) {
        super.init(reminder: reminder, isAllDay: isAllDay, startDate: nil, endDate: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isAllDay {
            self.title = resGetString("All-Day Event Alert")
        } else {
            self.title = resGetString("Timed Event Alert")
        }
        
        self.navigationItem.leftBarButtonItem = nil
    }
    
    override func clickDone() {
        self.navigationController?.popViewController(animated: true)
        callback(after: 0.1) {
            self.didEndEditing?(self.reminder)
        }
    }
    
}
