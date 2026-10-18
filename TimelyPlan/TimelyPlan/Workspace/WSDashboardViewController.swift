//
//  WSDashboardViewController.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/18.
//

import Foundation
import UIKit

/// 面板视图控制器代理
protocol WSDashboardViewControllerDelegate: AnyObject {
    
    /// 面板编辑状态发生变化
    func dashboardViewController(_ viewController: WSDashboardViewController,
                                 didChangeReordering isReordering: Bool)
}

/// 面板视图控制器。
///
/// 负责单个面板的组件展示、排序以及组件增删，导航栏由 `WorkspaceCoordinator` 统一管理。
class WSDashboardViewController: TPViewController,
                                 WSDashboardViewDelegate {
    
    /// 代理对象
    weak var delegate: WSDashboardViewControllerDelegate?
    
    /// 展示的面板
    let dashboard: WSDashboard
    
    /// 是否处于编辑模式
    var isReordering: Bool {
        return dashboardView.isReordering
    }
    
    /// 仪表盘视图
    private lazy var dashboardView: WSDashboardView = {
        let dashboardView = WSDashboardView(frame: .zero)
        dashboardView.delegate = self
        return dashboardView
    }()
    
    /// 面板交互器
    private lazy var interactor: WSDashboardInteractor = {
        let interactor = WSDashboardInteractor(dashboard: dashboard)
        interactor.didChangePlugins = { [weak self] in
            self?.didChangePlugins()
        }
        
        return interactor
    }()
    
    /// 新插件的待插入位置。nil 表示追加到末尾
    private var pendingInsertionIndex: Int?
    
    // MARK: - Initialization
    init(dashboard: WSDashboard) {
        self.dashboard = dashboard
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = themeBackgroundColor
        self.setupSubviews()
    }
    
    override var themeBackgroundColor: UIColor? {
        return .systemBackground
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        dashboardView.frame = view.bounds
    }
    
    // MARK: - 编辑模式
    /// 进入编辑模式，组件抖动并支持拖动排序
    func beginReordering() {
        dashboardView.beginReordering()
    }
    
    /// 退出编辑模式
    func endReordering() {
        dashboardView.endReordering()
    }
    
    // MARK: - 加载
    /// 按需重新加载插件。数据仍然有效时直接回调已有数据
    func reloadPluginsIfNeeded() {
        interactor.loadPluginsIfNeeded()
    }
    
    /// 重新加载插件
    func reloadPlugins() {
        interactor.loadPlugins()
    }
    
    // MARK: - 组件选择
    /// 显示组件选择器
    /// - Parameter insertionIndex: 新插件的插入位置。为 nil 时追加到末尾
    func showPluginPicker(insertionIndex: Int? = nil) {
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
    
    private func didChangePlugins() {
        DispatchQueue.main.async {
            self.dashboardView.plugins = self.interactor.plugins
            self.dashboardView.performUpdate()
        }
    }
}

// MARK: - WSDashboardViewDelegate
extension WSDashboardViewController {
    
    func dashboardView(_ dashboardView: WSDashboardView, didChangeReordering isReordering: Bool) {
        /// 编辑状态由协调器同步到导航栏
        delegate?.dashboardViewController(self, didChangeReordering: isReordering)
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
