//
//  WorkspacePluginManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

class WorkspacePluginManager: SettingAgentObserver {
    
    let key = "WorkspacePlugin"
    
    let updater = WorkspacePluginProcessorUpdater()
    
    /// 插件字典。暂未接入持久化，先以内存字典模拟：键为面板标识，值为该面板下的插件数组
    private var plugins: [String: [WSPlugin]] = [:]
    
    init() {
        KeyValueStorage.shared.addObserver(self, forKey: key)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeRemoteValue(for keyName: String) {
        debugPrint("Workspace Plugin 远程数据更新: \(keyName)")
        updater.didChangeRemoteWorkspacePlugin()
    }
    
    // MARK: - 获取插件
    /// 面板下的所有插件，按排序因子升序返回
    func getPlugins(in dashboard: WSDashboard) -> [WSPlugin] {
        return (plugins[dashboard.identifier] ?? []).orderedElements()
    }
    
    /// 面板下特定标识的插件
    func getPlugin(withIdentifier identifier: String, in dashboard: WSDashboard) -> WSPlugin? {
        return plugins[dashboard.identifier]?.first { $0.identifier == identifier }
    }
    
    // MARK: - 处理插件
    /// 创建插件
    /// - Parameter index: 插入位置。为 nil 时追加到末尾
    @discardableResult
    func createPlugin(type: WSPluginType,
                      in dashboard: WSDashboard,
                      configJSON: String? = nil,
                      at index: Int? = nil) -> WSPlugin {
        let plugin = WSPlugin(identifier: UUID().uuidString, type: type)
        plugin.configJSON = configJSON
        plugin.order = (plugins[dashboard.identifier] ?? []).insertOrder()
        plugin.creationDate = .now
        plugin.modificationDate = .now
        
        var list = plugins[dashboard.identifier] ?? []
        let insertionIndex = min(max(index ?? list.count, 0), list.count)
        list.insert(plugin, at: insertionIndex)
        /// 按插入位置修正顺序因子，保证插件顺序与展示顺序一致
        list.updateOrders()
        
        plugins[dashboard.identifier] = list
        updater.didCreateWorkspacePlugin(plugin)
        return plugin
    }
    
    /// 更新插件配置
    @discardableResult
    func updatePlugin(_ plugin: WSPlugin,
                      in dashboard: WSDashboard,
                      configJSON: String?) -> WSPlugin? {
        guard plugin.configJSON != configJSON else {
            return nil
        }
        
        let change: WorkspacePluginChange = .configJSON(oldValue: plugin.configJSON,
                                                        newValue: configJSON)
        plugin.configJSON = configJSON
        plugin.modificationDate = .now
        updater.didUpdateWorkspacePlugin(plugin, with: change)
        return plugin
    }
    
    /// 删除插件
    func deletePlugin(_ plugin: WSPlugin, in dashboard: WSDashboard) {
        guard var list = plugins[dashboard.identifier],
              let index = list.firstIndex(where: { $0.identifier == plugin.identifier }) else {
            return
        }
        
        list.remove(at: index)
        if list.isEmpty {
            plugins.removeValue(forKey: dashboard.identifier)
        } else {
            plugins[dashboard.identifier] = list
        }
        
        updater.didDeleteWorkspacePlugin(plugin)
    }
    
    /// 删除面板下的所有插件
    func deletePlugins(in dashboard: WSDashboard) {
        guard let list = plugins.removeValue(forKey: dashboard.identifier) else {
            return
        }
        
        list.forEach { plugin in
            updater.didDeleteWorkspacePlugin(plugin)
        }
    }
    
    /// 排序插件
    func didEndReorderPlugins(with orderedPlugins: [WSPlugin], in dashboard: WSDashboard) {
        guard orderedPlugins.count > 0 else {
            return
        }
        
        /// 拖动结束后仅调整顺序因子，数组顺序即最新的展示顺序
        orderedPlugins.updateOrders()
        plugins[dashboard.identifier] = orderedPlugins
        updater.didReorderWorkspacePlugin()
    }
}
