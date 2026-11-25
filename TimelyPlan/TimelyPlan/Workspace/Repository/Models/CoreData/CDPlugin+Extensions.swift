//
//  CDPlugin+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/20.
//

import Foundation
import CoreData

extension CDPlugin: SortableIdentifiable {
    
    /// 面板关系键名
    static var dashboardKey: String {
        return "dashboard"
    }
    
    /// 面板标识键路径
    static var dashboardIdentifierKey: String {
        return "dashboard.identifier"
    }
    
    /// 收件箱插件：未归属任何面板
    static var inboxPluginPredicate: NSPredicate {
        let condition: PredicateCondition = (dashboardKey, .isEmpty)
        return NSPredicate.predicate(with: condition)
    }
    
    /// 指定面板下的插件。收件箱面板对应未归属任何面板的插件
    static func pluginPredicate(in dashboard: WSDashboard) -> NSPredicate {
        if dashboard.isInbox {
            return inboxPluginPredicate
        }
        
        let condition: PredicateCondition = (dashboardIdentifierKey, .equal(dashboard.identifier))
        return NSPredicate.predicate(with: condition)
    }
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    /// 插件类型。标识无法识别时返回 nil，避免旧数据导致崩溃
    var type: WSPluginType? {
        guard let typeRawValue = typeRawValue else {
            return nil
        }
        
        return WSPluginType(rawValue: typeRawValue)
    }
    
    /// 根据插件模型创建新插件
    static func newPlugin(with plugin: WSPlugin, in dashboard: CDDashboard?) -> CDPlugin {
        let content = CDPlugin.createEntity(in: .defaultContext)
        content.identifier = plugin.identifier
        content.typeRawValue = plugin.type.rawValue
        content.configJSON = plugin.configJSON
        content.order = plugin.order
        content.creationDate = plugin.creationDate ?? .now
        content.modificationDate = plugin.modificationDate ?? .now
        content.dashboard = dashboard
        return content
    }
    
    /// 更新插件配置
    func update(configJSON: String?) {
        self.configJSON = configJSON
        self.modificationDate = .now
    }
    
    /// 同步获取面板下的所有插件
    static func getPlugins(in dashboard: WSDashboard) -> [CDPlugin]? {
        let plugins: [CDPlugin]? = getAll(matching: pluginPredicate(in: dashboard),
                                          sortBy: ElementOrderKey,
                                          ascending: true,
                                          in: .defaultContext)
        return plugins
    }
}
