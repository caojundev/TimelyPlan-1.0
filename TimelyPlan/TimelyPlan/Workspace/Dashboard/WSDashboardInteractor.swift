//
//  WSDashboardInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

class WSDashboardInteractor {
    
    /// 插件变化回调
    var didChangePlugins: (() -> Void)?
    
    /// 当前面板的插件数组
    private(set) var plugins: [WSPlugin]?
    
    /// 当前面板
    let dashboard: WSDashboard
    
    /// 是否需要重新获取插件
    private var needsReload = true
    
    /// 占位视图
    private(set) var placeholderProvider = TPLoadableListPlaceholderProvider()
    
    /// 加载状态
    private(set) var loadingState: TPListLoadingState = .initialLoading {
        didSet {
            placeholderProvider.state = loadingState
        }
    }
    
    init(dashboard: WSDashboard) {
        self.dashboard = dashboard
        self.placeholderProvider.emptyTitle = resGetString("No Plugin")
        self.placeholderProvider.state = self.loadingState
        WorkspaceRepository.addUpdater(self, for: [.plugin])
    }
    
    deinit {
        WorkspaceRepository.removeUpdater(self)
    }
    
    /// 重置加载状态
    func resetLoadingState() {
        self.loadingState = .initialLoading
    }
    
    // MARK: - 加载
    /// 按需加载插件。数据仍然有效时直接回调已有数据，避免重复取数。
    func loadPluginsIfNeeded() {
        guard needsReload else {
            didChangePlugins?()
            return
        }
        
        loadPlugins()
    }
    
    /// 重新加载插件
    func loadPlugins() {
        loadingState = .loading
        plugins = WorkspaceRepository.getPlugins(in: dashboard)
        needsReload = false
        loadingState = .loaded
        didChangePlugins?()
    }
    
    /// 标记插件已过期，下次加载时重新获取
    func setNeedsReload() {
        needsReload = true
    }
    
    // MARK: - 处理插件
    /// 创建插件
    /// - Parameter index: 插入位置。为 nil 时追加到末尾
    @discardableResult
    func createPlugin(type: WSPluginType,
                      configJSON: String? = nil,
                      at index: Int? = nil) -> WSPlugin {
        return WorkspaceRepository.createPlugin(type: type,
                                                in: dashboard,
                                                configJSON: configJSON,
                                                at: index)
    }
    
    /// 更新插件配置
    @discardableResult
    func updatePlugin(_ plugin: WSPlugin, configJSON: String?) -> WSPlugin? {
        return WorkspaceRepository.updatePlugin(plugin,
                                                in: dashboard,
                                                configJSON: configJSON)
    }
    
    /// 删除插件
    func deletePlugin(_ plugin: WSPlugin) {
        WorkspaceRepository.deletePlugin(plugin, in: dashboard)
    }
    
    /// 排序插件
    func didEndReorderPlugins(with orderedPlugins: [WSPlugin]) {
        WorkspaceRepository.didEndReorderPlugins(with: orderedPlugins, in: dashboard)
    }
}

// MARK: - WorkspacePluginProcessorDelegate
extension WSDashboardInteractor: WorkspacePluginProcessorDelegate {
    
    func didChangeRemoteWorkspacePlugin() {
        setNeedsReload()
        loadPlugins()
    }
    
    func didCreateWorkspacePlugin(_ plugin: WSPlugin) {
        setNeedsReload()
        loadPlugins()
    }
    
    func didDeleteWorkspacePlugin(_ plugin: WSPlugin) {
        setNeedsReload()
        loadPlugins()
    }
    
    func didUpdateWorkspacePlugin(_ plugin: WSPlugin, with change: WorkspacePluginChange) {
        setNeedsReload()
        loadPlugins()
    }
    
    func didReorderWorkspacePlugin() {
        setNeedsReload()
        loadPlugins()
    }
}
