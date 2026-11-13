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
                                 didChangeEditing isEditing: Bool)
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
    
    /// 是否处于编辑模式。重写系统属性，由面板视图的编辑状态决定
    var isEditingMode: Bool {
        return dashboardView.isEditing
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
    
    /// 编辑模式下选中的插件
    private var selectedPlugins: [WSPlugin] = []
    
    /// 选中插件时的底部工具栏
    private var toolView: TPMenuToolView<WSPluginMenuActionType>?
    
    /// 工具栏是否正在滑入
    private var isShowingToolView = false
    
    /// 工具栏内容高度
    private let toolViewContentHeight = 60.0
    
    /// 工具栏整体高度，包含底部安全区
    private var toolViewFitHeight: CGFloat {
        return toolViewContentHeight + view.safeAreaInsets.bottom
    }
    
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
        
        if let toolView = toolView {
            toolView.width = view.width
            toolView.height = toolViewFitHeight
            toolView.bottom = view.height
        }
    }
    
    func endEditing() {
        dashboardView.endEditing()
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
            
            let createdPlugin = self.addPlugin(plugin, at: self.pendingInsertionIndex)
            self.pendingInsertionIndex = nil
            /// 添加完成后关闭选择器，需要配置的组件在选择器关闭后再弹出配置界面
            navController?.dismiss(animated: true) { [weak self] in
                /// 等选择器的关闭转场结束再弹出，避免上一场转场未结束时弹出失败
                DispatchQueue.main.async {
                    self?.showConfigIfNeeded(for: createdPlugin)
                }
            }
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
    /// - Returns: 创建后的组件，用于添加后继续配置
    @discardableResult
    private func addPlugin(_ plugin: WSPlugin, at index: Int? = nil) -> WSPlugin {
        return interactor.createPlugin(type: plugin.type, configJSON: plugin.configJSON, at: index)
    }

    /// 添加后立即进入配置。仅模块声明了「添加后配置」时生效
    private func showConfigIfNeeded(for plugin: WSPlugin) {
        guard plugin.type.module.opensConfigAfterAdd else {
            return
        }

        showPluginConfig(for: plugin)
    }
    
    // MARK: - 组件配置
    /// 显示组件配置界面。配置界面由组件提供者决定，未提供时不做任何处理
    private func showPluginConfig(for plugin: WSPlugin) {
        guard let provider = WSPluginRegistry.shared.provider(for: plugin.type),
              let configViewController = provider.makeConfigViewController(plugin: plugin) else {
            return
        }
        
        configViewController.didChangeConfigJSON = { [weak self] configJSON in
            self?.interactor.updatePlugin(plugin, configJSON: configJSON)
        }
        
        let navController = UINavigationController(rootViewController: configViewController)
        navController.popoverShow()
    }
    
    // MARK: - 底部工具栏
    /// 按选中的插件更新工具栏
    private func updateToolView(with plugins: [WSPlugin]) {
        guard plugins.count > 0 else {
            hideToolView()
            return
        }
        
        guard let toolView = showToolViewIfNeeded() else {
            return
        }
        
        toolView.setActionTypes(actionTypes(for: plugins), animated: true)
    }
    
    /// 按选中数量返回可用动作。多选时仅支持删除，单选时配置动作仅在组件支持配置时提供
    private func actionTypes(for plugins: [WSPlugin]) -> [WSPluginMenuActionType] {
        guard plugins.count == 1, let plugin = plugins.first else {
            return [.removePlugin]
        }
        
        var actionTypes: [WSPluginMenuActionType] = [.addPreviousPlugin, .addNextPlugin, .removePlugin]
        if plugin.isConfigurable {
            actionTypes.insert(.configPlugin, at: 2)
        }
        
        return actionTypes
    }
    
    /// 显示工具栏
    private func showToolViewIfNeeded() -> TPMenuToolView<WSPluginMenuActionType>? {
        if let toolView = toolView {
            return toolView
        }
        
        /// 滑入动画期间不重复创建
        guard !isShowingToolView else {
            return nil
        }
        
        isShowingToolView = true
        
        /// 移除可能仍在滑出动画中的旧工具栏
        view.subviews.compactMap { $0 as? TPMenuToolView<WSPluginMenuActionType> }
            .forEach { $0.removeFromSuperview() }
        
        let toolView = TPMenuToolView(actionTypes: actionTypes(for: selectedPlugins))
        toolView.backgroundColor = .secondarySystemGroupedBackground
        toolView.preferredItemsCount = WSPluginMenuActionType.allCases.count
        toolView.addSeparator(position: .top)
        toolView.didSelectActionType = { [weak self] actionType, _ in
            self?.performMenuAction(actionType)
        }
        
        let height = toolViewFitHeight
        toolView.frame = CGRect(x: 0.0, y: view.height, width: view.width, height: height)
        view.addSubview(toolView)
        
        updateDashboardContentInset(bottomInset: toolViewContentHeight)
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut) {
            toolView.bottom = self.view.height
        } completion: { _ in
            self.isShowingToolView = false
            
            /// 动画期间选中已被清空，直接移除
            guard self.selectedPlugins.count > 0 else {
                toolView.removeFromSuperview()
                self.updateDashboardContentInset(bottomInset: 0.0)
                return
            }
            
            self.toolView = toolView
        }
        
        return toolView
    }
    
    /// 隐藏工具栏
    private func hideToolView() {
        guard let toolView = toolView else {
            updateDashboardContentInset(bottomInset: 0.0)
            return
        }
        
        self.toolView = nil
        isShowingToolView = false
        updateDashboardContentInset(bottomInset: 0.0)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut) {
            toolView.top = self.view.height
        } completion: { _ in
            toolView.removeFromSuperview()
        }
    }
    
    /// 更新面板底部内边距，避免末尾内容被工具栏遮挡
    private func updateDashboardContentInset(bottomInset: CGFloat) {
        dashboardView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: bottomInset, right: 0.0)
    }
    
    /// 执行工具栏动作。执行后退出编辑模式，多选时仅支持删除
    private func performMenuAction(_ action: WSPluginMenuActionType) {
        let plugins = selectedPlugins
        guard plugins.count > 0 else {
            return
        }
        
        if action == .removePlugin {
            plugins.forEach { interactor.deletePlugin($0) }
            dashboardView.endEditing()
            return
        }
        
        /// 其余动作仅对单个插件生效
        guard plugins.count == 1, let plugin = plugins.first else {
            return
        }
        
        performMenuAction(action, for: plugin)
        
        /// 菜单动作执行后退出编辑模式
        dashboardView.endEditing()
    }
    
    /// 执行单个插件的菜单动作
    private func performMenuAction(_ action: WSPluginMenuActionType, for plugin: WSPlugin) {
        switch action {
        case .addPreviousPlugin:
            insertPlugin(around: plugin, isNext: false)
        case .addNextPlugin:
            insertPlugin(around: plugin, isNext: true)
        case .configPlugin:
            showPluginConfig(for: plugin)
        case .removePlugin:
            interactor.deletePlugin(plugin)
        }
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
    
    func dashboardView(_ dashboardView: WSDashboardView, didChangeEditing isEditing: Bool) {
        /// 退出编辑模式时收起底部工具栏
        if !isEditing {
            hideToolView()
        }
        
        /// 编辑状态由协调器同步到导航栏
        delegate?.dashboardViewController(self, didChangeEditing: isEditing)
    }
    
    func dashboardView(_ dashboardView: WSDashboardView, didChangeSelectedPlugins plugins: [WSPlugin]) {
        selectedPlugins = plugins
        updateToolView(with: plugins)
    }
    
    func dashboardView(_ dashboardView: WSDashboardView,
                       didSelectMenuAction action: WSPluginMenuActionType,
                       for plugin: WSPlugin) {
        performMenuAction(action, for: plugin)
    }
    
    func dashboardView(_ dashboardView: WSDashboardView, didReorderPlugins plugins: [WSPlugin]) {
        interactor.didEndReorderPlugins(with: plugins)
    }
    
    func dashboardView(_ dashboardView: WSDashboardView, didSelectGapAfter plugin: WSPlugin) {
        /// 选择器展示后，新组件插入到点击空白的前一个组件之后
        insertPlugin(around: plugin, isNext: true)
    }
}
