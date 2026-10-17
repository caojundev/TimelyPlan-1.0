//
//  WorkspaceMainViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/14.
//

import Foundation
import UIKit

class WorkspaceMainViewController: TPViewController,
                                   TPSidebarContent,
                                   WSDashboardViewDelegate {
    
    struct Constants {
        
        /// 「完成编辑」按钮高度
        static let doneEditingButtonHeight = 50.0
        
        /// 「完成编辑」按钮内容左右内边距
        static let doneEditingButtonHorizontalPadding = 28.0
        
        /// 「完成编辑」按钮与底部安全区的间距
        static let doneEditingButtonBottomMargin = 16.0
    }
    
    var sidebarController: SidebarController?
    
    /// 仪表盘视图
    private lazy var dashboardView: WSDashboardView = {
        let dashboardView = WSDashboardView(frame: .zero)
        dashboardView.delegate = self
        return dashboardView
    }()
    
    /// 面板交互器
    private lazy var interactor: WSDashboardInteractor = {
        /// 暂无面板切换能力，先取第一个面板作为测试
        let dashboard = WorkspaceRepository.getDashboards().first ?? WorkspaceRepository.createDashboard()
        let interactor = WSDashboardInteractor(dashboard: dashboard)
        interactor.didChangePlugins = { [weak self] in
            self?.didChangePlugins()
        }
        
        return interactor
    }()
    
    /// 完成编辑按钮。仅排序模式下显示在底部中间
    private lazy var doneEditingButton: TPDefaultButton = {
        let button = TPDefaultButton()
        button.title = resGetString("Done Editing")
        button.titleConfig.font = BOLD_SYSTEM_FONT
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.selectedBackgroundColor = .primary.darkerColor
        button.cornerRadius = .greatestFiniteMagnitude
        button.padding = UIEdgeInsets(horizontal: Constants.doneEditingButtonHorizontalPadding)
        button.isHidden = true
        button.addTarget(self, action: #selector(clickDoneEditing), for: .touchUpInside)
        return button
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
        layoutDoneEditingButton()
    }
    
    /// 布局底部中间的「完成编辑」按钮
    private func layoutDoneEditingButton() {
        let layoutFrame = view.safeLayoutFrame()
        let fitSize = doneEditingButton.sizeThatFits(CGSize(width: layoutFrame.width,
                                                            height: .greatestFiniteMagnitude))
        doneEditingButton.width = min(fitSize.width, layoutFrame.width)
        doneEditingButton.height = Constants.doneEditingButtonHeight
        doneEditingButton.bottom = layoutFrame.maxY - Constants.doneEditingButtonBottomMargin
        doneEditingButton.alignHorizontalCenter()
    }
    
    private func didChangePlugins() {
        DispatchQueue.main.async {
            self.dashboardView.plugins = self.interactor.plugins
            self.dashboardView.performUpdate()
        }
    }
    
    // MARK: - Event Response
    override func clickAdd() {
        super.clickAdd()
        showPluginPicker()
    }
    
    /// 点击「完成编辑」，退出排序模式
    @objc private func clickDoneEditing() {
        dashboardView.endReordering()
    }
    
    // MARK: - 组件选择
    /// 显示组件选择器
    private func showPluginPicker() {
        let pickerViewController = WSPluginPickerViewController()
        
        let navController = UINavigationController(rootViewController: pickerViewController)
        navController.modalPresentationStyle = .formSheet
        
        pickerViewController.didAddPlugin = { [weak self, weak navController] plugin in
            self?.addPlugin(plugin)
            /// 添加完成后关闭选择器
            navController?.dismiss(animated: true)
        }
        
        navController.show()
    }
    
    /// 添加组件到当前面板
    private func addPlugin(_ plugin: WSPlugin) {
        interactor.createPlugin(type: plugin.type, configJSON: plugin.configJSON)
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.addSubview(dashboardView)
        /// 按钮浮在仪表盘之上，排序模式下显示
        view.addSubview(doneEditingButton)
        interactor.loadPlugins()
    }
}

// MARK: - WSDashboardViewDelegate
extension WorkspaceMainViewController {
    
    func dashboardView(_ dashboardView: WSDashboardView, didChangeReordering isReordering: Bool) {
        /// 排序模式下在底部中间显示「完成编辑」
        doneEditingButton.isHidden = !isReordering
        if isReordering {
            view.bringSubviewToFront(doneEditingButton)
        }
        
        /// 让内容让出按钮高度，避免最后一行被按钮遮挡
        let bottomInset = Constants.doneEditingButtonHeight + Constants.doneEditingButtonBottomMargin * 2.0
        dashboardView.contentInset = isReordering ? UIEdgeInsets(bottom: bottomInset) : .zero
    }
    
    func dashboardView(_ dashboardView: WSDashboardView,
                       didSelectMenuAction action: WSPluginCell.MenuActionType,
                       for plugin: WSPlugin) {
        switch action {
        case .addPlugin:
            showPluginPicker()
        case .edit:
            /// 进入排序模式，组件抖动并支持长按拖动排序
            dashboardView.beginReordering()
        case .remove:
            interactor.deletePlugin(plugin)
        }
    }
    
    func dashboardView(_ dashboardView: WSDashboardView, didReorderPlugins plugins: [WSPlugin]) {
        interactor.didEndReorderPlugins(with: plugins)
    }
}
