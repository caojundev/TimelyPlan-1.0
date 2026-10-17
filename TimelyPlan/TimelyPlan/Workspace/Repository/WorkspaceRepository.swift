//
//  WorkspaceRepository.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

struct WorkspaceUpdaterOption: OptionSet {
    
    let rawValue: Int
    
    /// 面板
    static let dashboard = WorkspaceUpdaterOption(rawValue: 1 << 1)
    
    /// 插件
    static let plugin = WorkspaceUpdaterOption(rawValue: 1 << 2)
    
    /// 所有
    static let all: WorkspaceUpdaterOption = [.dashboard, .plugin]
}

class WorkspaceRepository {
    
    // MARK: - 数据管理器
    private static let dashboardManager = WorkspaceDashboardManager()
    
    private static let pluginManager = WorkspacePluginManager()
    
    // MARK: - 更新器
    /// 添加更新器代理对象
    static func addUpdater(_ updater: AnyObject, for option: WorkspaceUpdaterOption = .all) {
        if option.contains(.dashboard) {
            dashboardManager.updater.addDelegate(updater)
        }
        
        if option.contains(.plugin) {
            pluginManager.updater.addDelegate(updater)
        }
    }
    
    /// 移除更新器代理对象
    static func removeUpdater(_ updater: AnyObject) {
        dashboardManager.updater.removeDelegate(updater)
        pluginManager.updater.removeDelegate(updater)
    }
    
    // MARK: - 获取面板
    /// 所有面板，按排序因子升序返回。不存在时创建默认面板
    static func getDashboards() -> [WSDashboard] {
        return dashboardManager.getDashboards()
    }
    
    /// 特定标识的面板
    static func getDashboard(withIdentifier identifier: String) -> WSDashboard? {
        return dashboardManager.getDashboard(withIdentifier: identifier)
    }
    
    // MARK: - 处理面板
    /// 创建面板
    @discardableResult
    static func createDashboard(name: String? = nil,
                                colorHex: String? = nil) -> WSDashboard {
        return dashboardManager.createDashboard(name: name, colorHex: colorHex)
    }
    
    /// 更新面板名称
    @discardableResult
    static func updateDashboard(_ dashboard: WSDashboard, name: String?) -> WSDashboard? {
        return dashboardManager.updateDashboard(dashboard, name: name)
    }
    
    /// 删除面板
    static func deleteDashboard(_ dashboard: WSDashboard) {
        dashboardManager.deleteDashboard(dashboard)
    }
    
    /// 排序面板
    static func didEndReorderDashboards(with orderedDashboards: [WSDashboard]) {
        dashboardManager.didEndReorderDashboards(with: orderedDashboards)
    }
    
    // MARK: - 获取插件
    /// 面板下的所有插件，按排序因子升序返回
    static func getPlugins(in dashboard: WSDashboard) -> [WSPlugin] {
        return pluginManager.getPlugins(in: dashboard)
    }
    
    /// 面板下特定标识的插件
    static func getPlugin(withIdentifier identifier: String, in dashboard: WSDashboard) -> WSPlugin? {
        return pluginManager.getPlugin(withIdentifier: identifier, in: dashboard)
    }
    
    // MARK: - 处理插件
    /// 创建插件
    @discardableResult
    static func createPlugin(type: WSPluginType,
                             in dashboard: WSDashboard,
                             configJSON: String? = nil) -> WSPlugin {
        return pluginManager.createPlugin(type: type,
                                          in: dashboard,
                                          configJSON: configJSON)
    }
    
    /// 更新插件配置
    @discardableResult
    static func updatePlugin(_ plugin: WSPlugin,
                             in dashboard: WSDashboard,
                             configJSON: String?) -> WSPlugin? {
        return pluginManager.updatePlugin(plugin,
                                          in: dashboard,
                                          configJSON: configJSON)
    }
    
    /// 删除插件
    static func deletePlugin(_ plugin: WSPlugin, in dashboard: WSDashboard) {
        pluginManager.deletePlugin(plugin, in: dashboard)
    }
    
    /// 删除面板下的所有插件
    static func deletePlugins(in dashboard: WSDashboard) {
        pluginManager.deletePlugins(in: dashboard)
    }
    
    /// 排序插件
    static func didEndReorderPlugins(with orderedPlugins: [WSPlugin], in dashboard: WSDashboard) {
        pluginManager.didEndReorderPlugins(with: orderedPlugins, in: dashboard)
    }
}
