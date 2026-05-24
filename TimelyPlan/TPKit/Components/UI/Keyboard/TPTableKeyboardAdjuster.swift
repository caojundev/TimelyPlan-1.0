//
//  TPTableKeyboardAdjuster.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation
import UIKit

class TPTableKeyboardAdjuster {
    
    /// 绑定的滚动视图
    private weak var tableView: UITableView?
    
    var isEnabled: Bool = false {
        didSet {
            if isEnabled {
                tableView?.addKeyboardNotification()
            } else {
                tableView?.removeKeyboardNotification()
            }
        }
    }
    
    init(tableView: UITableView) {
        self.tableView = tableView
    }
    
    deinit {
        tableView?.removeKeyboardNotification()
    }
}

