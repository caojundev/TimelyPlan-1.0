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
        
        /// 「完成」按钮高度
        static let doneBarButtonHeight = 32.0
        
        /// 「完成」按钮内容左右内边距
        static let doneBarButtonHorizontalPadding = 12.0
    }
    
    var sidebarController: SidebarController?
    
    /// 更多菜单按钮
    private lazy var moreBarButtonItem: WorkspaceMoreBarButtonItem = {
        let item = WorkspaceMoreBarButtonItem()
        item.didSelectType = { [weak self] type in
            self?.performMoreMenuAction(type)
        }
        
        return item
    }()
    
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
    
    /// 新插件的待插入位置。nil 表示追加到末尾
    private var pendingInsertionIndex: Int?
    
    /// 完成编辑按钮。仅编辑模式下显示在导航栏右侧
    private lazy var doneEditingBarButtonItem: UIBarButtonItem = {
        let button = TPDefaultButton()
        button.title = resGetString("Done")
        button.titleConfig.font = .boldSystemFont(ofSize: 14.0)
        button.titleConfig.textColor = .white
        button.normalBackgroundColor = .primary
        button.selectedBackgroundColor = .primary.darkerColor
        button.cornerRadius = .greatestFiniteMagnitude
        button.padding = UIEdgeInsets(horizontal: Constants.doneBarButtonHorizontalPadding)
        button.addTarget(self, action: #selector(clickDoneEditing), for: .touchUpInside)
        
        /// 自定义视图需给出尺寸，否则导航栏无法正确布局
        let height = Constants.doneBarButtonHeight
        let fitSize = button.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: height))
        button.size = CGSize(width: fitSize.width, height: height)
        
        return UIBarButtonItem(customView: button)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = resGetString("Workspace")
        if let sidebarButtonItem = sidebarController?.newMenuButtonItem() {
            navigationItem.leftBarButtonItems = [sidebarButtonItem]
        }

        navigationItem.rightBarButtonItems = [moreBarButtonItem, addBarButtonItem]
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
    
    /// 点击「完成」，退出编辑模式
    @objc private func clickDoneEditing() {
        dashboardView.endReordering()
    }
    
    // MARK: - 更多菜单
    /// 处理更多菜单动作
    private func performMoreMenuAction(_ type: WorkspaceMoreMenuType) {
        switch type {
        case .editDashboard:
            /// 进入编辑模式，组件抖动并支持拖动排序
            dashboardView.beginReordering()
        }
    }
    
    // MARK: - 组件选择
    /// 显示组件选择器
    /// - Parameter insertionIndex: 新插件的插入位置。为 nil 时追加到末尾
    private func showPluginPicker(insertionIndex: Int? = nil) {
        pendingInsertionIndex = insertionIndex
        
        let pickerViewController = WSPluginPickerViewController()
        
        let navController = UINavigationController(rootViewController: pickerViewController)
        navController.modalPresentationStyle = .formSheet
        
        pickerViewController.didAddPlugin = { [weak self, weak navController] plugin in
            guard let self = self else {
                return
            }
            
            self.addPlugin(plugin, at: self.pendingInsertionIndex)
            self.pendingInsertionIndex = nil
            /// 添加完成后关闭选择器
            navController?.dismiss(animated: true)
        }
        
        navController.show()
    }
    
    /// 在指定插件前 / 后添加插件
    private func insertPlugin(around plugin: WSPlugin, isNext: Bool) {
        guard let index = interactor.plugins?.firstIndex(where: { $0.identifier == plugin.identifier }) else {
            /// 找不到对应插件时追加到末尾
            showPluginPicker()
            return
        }
        
        showPluginPicker(insertionIndex: isNext ? index + 1 : index)
    }
    
    /// 添加组件到当前面板
    /// - Parameter index: 插入位置。为 nil 时追加到末尾
    private func addPlugin(_ plugin: WSPlugin, at index: Int? = nil) {
        interactor.createPlugin(type: plugin.type, configJSON: plugin.configJSON, at: index)
    }
    
    // MARK: - Setup
    private func setupSubviews() {
        view.addSubview(dashboardView)
        dashboardView.placeholderProvider = interactor.placeholderProvider
        interactor.loadPlugins()
    }
}

// MARK: - WSDashboardViewDelegate
extension WorkspaceMainViewController {
    
    func dashboardView(_ dashboardView: WSDashboardView, didChangeReordering isReordering: Bool) {
        /// 编辑模式下右侧仅显示「完成」按钮，添加与更多按钮不显示
        navigationItem.rightBarButtonItems = isReordering ? [doneEditingBarButtonItem]
                                                          : [moreBarButtonItem,
                                                             addBarButtonItem]
    }
    
    func dashboardView(_ dashboardView: WSDashboardView,
                       didSelectMenuAction action: WSPluginCell.MenuActionType,
                       for plugin: WSPlugin) {
        switch action {
        case .addPreviousPlugin:
            insertPlugin(around: plugin, isNext: false)
        case .addNextPlugin:
            insertPlugin(around: plugin, isNext: true)
        case .editDashboard:
            /// 进入编辑模式，组件抖动并支持长按拖动排序
            dashboardView.beginReordering()
        case .remove:
            interactor.deletePlugin(plugin)
        }
    }
    
    func dashboardView(_ dashboardView: WSDashboardView, didReorderPlugins plugins: [WSPlugin]) {
        interactor.didEndReorderPlugins(with: plugins)
    }
}
