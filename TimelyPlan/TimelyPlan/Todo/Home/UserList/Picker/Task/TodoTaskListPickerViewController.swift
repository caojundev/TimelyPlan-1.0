//
//  TodoTaskListPickerViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/4.
//

import Foundation
import UIKit

class TodoTaskListPickerViewController: TodoBaseListPickerViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Move To")
    }
    
    override func setupSelectViewController() {
        self.selectViewController = TodoParentListSelectViewController(list: self.list,
                                                                       allowMaxDepth: self.allowMaxDepth)
    }
}
