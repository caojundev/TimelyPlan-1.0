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
    private lazy var dashboardView: WSDashboardView = {
        let dashboardView = WSDashboardView(frame: .zero)
        dashboardView.elements = WSPluginElement.mockElements()
        return dashboardView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Workspace")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }
        navigationItem.rightBarButtonItem = addBarButtonItem
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
    
    // MARK: - Event Response
    override func clickAdd() {
        super.clickAdd()
        showPluginPicker()
    }
    
    // MARK: - 组件选择
    /// 显示组件选择器
    private func showPluginPicker() {
        let pickerViewController = WSPluginPickerViewController()
        pickerViewController.didSelectModule = { [weak self] module in
            self?.addPlugin(for: module)
        }
        
        let navController = UINavigationController(rootViewController: pickerViewController)
        navController.modalPresentationStyle = .formSheet
        navController.show()
    }
    
    /// 添加组件到工作台
    private func addPlugin(for module: WSPluginModule) {
        /// TODO: 待模块下的插件列表与组件增删能力就绪后补全
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.addSubview(dashboardView)
        dashboardView.reloadData()
    }
}
