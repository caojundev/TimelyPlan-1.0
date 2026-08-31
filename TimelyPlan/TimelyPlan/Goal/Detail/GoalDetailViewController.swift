//
//  GoalDetailViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

class GoalDetailViewController: TPMultiColumnDetailViewController {
    
    /// 当前目标计划
    var goalPlan: GoalPlan?
    
    init(goalPlan: GoalPlan) {
        self.goalPlan = goalPlan
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = goalPlan?.displayName ?? resGetString("Goal Detail")
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
}
