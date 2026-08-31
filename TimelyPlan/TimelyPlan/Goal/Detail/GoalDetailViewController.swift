//
//  GoalDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

class GoalDetailViewController: TPMultiColumnDetailViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Goal Detail")
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
}
