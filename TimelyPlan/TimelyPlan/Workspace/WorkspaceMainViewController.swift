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
    
    /// 仪表盘视图
    private lazy var dashboardView: WorkspaceDashboardView = {
        let dashboardView = WorkspaceDashboardView(frame: .zero)
        dashboardView.elements = WSPluginElement.mockElements()
        return dashboardView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Workspace")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        self.setupSubviews()
    }

    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override var themeNavigationBarBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dashboardView.frame = view.bounds
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.addSubview(dashboardView)
        dashboardView.reloadData()
    }
}
