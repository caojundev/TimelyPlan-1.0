//
//  WorkspaceCoordinator.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/18.
//

import Foundation
import UIKit

/// 工作台协调器。
///
/// 负责创建并切换当前选中的面板视图控制器（`WSDashboardViewController`），
/// 并将面板的状态变化同步给容器视图控制器，由其更新导航栏显示。
class WorkspaceCoordinator {
    
    /// 工作台容器视图控制器
    private(set) weak var containerViewController: WorkspaceMainViewController?
    
    /// 当前选中的面板
    private(set) var dashboard: WSDashboard?
    
    /// 当前面板视图控制器
    private(set) var dashboardViewController: WSDashboardViewController?
    
    // MARK: - Initialization
    init(containerViewController: WorkspaceMainViewController) {
        self.containerViewController = containerViewController
        
        /// 监听面板变化，当前面板被删除或重命名时同步界面
        WorkspaceRepository.addUpdater(self, for: [.dashboard])
    }
    
    deinit {
        WorkspaceRepository.removeUpdater(self)
    }
    
    // MARK: - 面板
    /// 启动工作台，展示默认面板
    func start() {
        showDashboard(defaultDashboard())
    }
    
    /// 展示指定面板
    /// - Parameter dashboard: 需要展示的面板
    func showDashboard(_ dashboard: WSDashboard) {
        guard let containerViewController = containerViewController else {
            return
        }
        
        /// 同一面板已在展示时仅刷新数据与导航栏，避免重建视图控制器丢失状态
        if let viewController = dashboardViewController,
           self.dashboard?.identifier == dashboard.identifier {
            viewController.reloadPluginsIfNeeded()
            containerViewController.updateNavigationBarItems()
            return
        }
        
        self.dashboard = dashboard
        
        let viewController = WSDashboardViewController(dashboard: dashboard)
        viewController.delegate = self
        self.dashboardViewController = viewController
        
        containerViewController.setContentViewController(viewController)
        containerViewController.updateNavigationBarItems()
    }
    
    /// 默认展示的面板。面板不存在时会自动创建
    private func defaultDashboard() -> WSDashboard {
        return WorkspaceRepository.getDashboards().first ?? WorkspaceRepository.createDashboard()
    }
    
    // MARK: - 面板交互
    /// 展示组件选择器
    func showPluginPicker() {
        dashboardViewController?.showPluginPicker()
    }
    
    /// 进入编辑模式
    func beginReordering() {
        dashboardViewController?.beginReordering()
    }
    
    /// 退出编辑模式
    func endReordering() {
        dashboardViewController?.endReordering()
    }
}

// MARK: - WSDashboardViewControllerDelegate
extension WorkspaceCoordinator: WSDashboardViewControllerDelegate {
    
    func dashboardViewController(_ viewController: WSDashboardViewController,
                                 didChangeReordering isReordering: Bool) {
        guard viewController === dashboardViewController else {
            return
        }
        
        /// 编辑状态变化后由容器更新导航栏按钮
        containerViewController?.updateNavigationBarItems()
    }
}

// MARK: - WorkspaceDashboardProcessorDelegate
extension WorkspaceCoordinator: WorkspaceDashboardProcessorDelegate {
    
    func didChangeRemoteWorkspaceDashbaord() {
        guard let dashboard = dashboard,
              WorkspaceRepository.getDashboard(withIdentifier: dashboard.identifier) == nil else {
            return
        }
        
        /// 当前面板已不存在，回落到默认面板
        showDashboard(defaultDashboard())
    }
    
    func didDeleteWorkspaceDashbaord(_ board: WSDashboard) {
        guard board.identifier == dashboard?.identifier else {
            return
        }
        
        /// 当前面板被删除，回落到默认面板
        showDashboard(defaultDashboard())
    }
    
    func didUpdateWorkspaceDashbaord(_ board: WSDashboard,
                                     with change: WorkspaceDashboardChange) {
        guard board.identifier == dashboard?.identifier else {
            return
        }
        
        /// 名称变化时同步导航栏标题
        containerViewController?.updateNavigationBarItems()
    }
}
