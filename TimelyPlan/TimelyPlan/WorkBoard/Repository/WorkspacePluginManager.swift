//
//  WorkspacePluginManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation
import CoreData

class WorkspacePluginManager {

    /// 数据更新器
    let updater = WorkspacePluginProcessorUpdater()
    
    /// 默认上下文对象
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    // MARK: - 获取插件
    /// 面板下的所有插件，按排序因子升序返回。收件箱面板返回未归属任何面板的插件
    func getPlugins(in dashboard: WSDashboard) -> [WSPlugin] {
        return CDPlugin.getPlugins(in: dashboard)?.toWSPlugins ?? []
    }
    
    // MARK: - 处理插件
    /// 创建插件
    /// - Parameter index: 插入位置。为 nil 时追加到末尾
    @discardableResult
    func createPlugin(type: WSPluginType,
                      in dashboard: WSDashboard,
                      configJSON: String? = nil,
                      at index: Int? = nil) -> WSPlugin {
        var plugins = CDPlugin.getPlugins(in: dashboard)?.toWSPlugins ?? []
        
        let plugin = WSPlugin(identifier: UUID().uuidString, type: type)
        plugin.configJSON = configJSON
        plugin.creationDate = .now
        plugin.modificationDate = plugin.creationDate
        
        let insertionIndex = min(max(index ?? plugins.count, 0), plugins.count)
        plugins.insert(plugin, at: insertionIndex)
        /// 按插入位置修正顺序因子，保证插件顺序与展示顺序一致
        plugins.updateOrders()
        
        /// 重排可能修正其余插件的顺序因子，统一同步到存储
        CDPlugin.syncOrders(for: plugins)
        
        /// 收件箱面板不持久化，其插件归属为 nil
        let dashboardContent = dashboard.isInbox ? nil : CDDashboard.getDashboard(withIdentifier: dashboard.identifier)
        CDPlugin.newPlugin(with: plugin, in: dashboardContent)
        
        updater.didCreateWorkspacePlugin(plugin)
        HandyRecord.updateChangeCount()
        return plugin
    }
    
    /// 更新插件配置
    @discardableResult
    func updatePlugin(_ plugin: WSPlugin, configJSON: String?) -> WSPlugin? {
        guard plugin.configJSON != configJSON else {
            return nil
        }
        
        guard let content = CDPlugin.getItem(with: plugin.identifier) else {
            return nil
        }
        
        let change: WorkspacePluginChange = .configJSON(oldValue: plugin.configJSON,
                                                        newValue: configJSON)
        content.update(configJSON: configJSON)
        
        /// 同步外部持有的模型实例，避免界面继续读到旧值
        plugin.configJSON = configJSON
        plugin.modificationDate = content.modificationDate
        
        updater.didUpdateWorkspacePlugin(plugin, with: change)
        HandyRecord.updateChangeCount()
        return plugin
    }
    
    /// 删除插件
    func deletePlugin(_ plugin: WSPlugin) {
        guard let content = CDPlugin.getItem(with: plugin.identifier) else {
            return
        }
        
        context.delete(content)
        updater.didDeleteWorkspacePlugin(plugin)
        HandyRecord.updateChangeCount()
    }

    /// 排序插件
    func didEndReorderPlugins(with orderedPlugins: [WSPlugin]) {
        guard orderedPlugins.count > 0 else {
            return
        }
        
        /// 拖动结束后仅调整顺序因子，数组顺序即最新的展示顺序
        orderedPlugins.updateOrders()
        guard CDPlugin.syncOrders(for: orderedPlugins) else {
            return
        }
        
        updater.didReorderWorkspacePlugin()
        HandyRecord.updateChangeCount()
    }
}
