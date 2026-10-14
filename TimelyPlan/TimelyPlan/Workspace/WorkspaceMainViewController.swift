//
//  WorkspaceMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation
import UIKit

class WorkspaceMainViewController: TPViewController,
                               TPSidebarContent {

    var sidebarController: SidebarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
}
