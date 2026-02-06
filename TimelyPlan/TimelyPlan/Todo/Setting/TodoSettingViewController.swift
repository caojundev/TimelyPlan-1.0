//
//  TodoSettingViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2024/11/28.
//

import Foundation

class TodoSettingViewController: TPTableSectionsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Settings")
        navigationItem.leftBarButtonItem = chevronDownCancelButtonItem
    }
    
}
