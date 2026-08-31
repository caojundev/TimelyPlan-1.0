//
//  GoalHomeViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/8/30.
//

import Foundation
import UIKit

class GoalHomeViewController: TPTableViewController,
                               TPSidebarContent {
    /// 侧边栏控制器
    var sidebarController: SidebarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = resGetString("Goal")
        navigationItem.leftBarButtonItem = sidebarController?.newMenuButtonItem()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
}
