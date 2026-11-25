//
//  WorkspaceDashboardManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation
import CoreData

class WorkspaceDashboardManager {

    /// 数据更新器
    let updater = WorkspaceDashboardProcessorUpdater()
    
    /// 默认上下文对象
    var context: NSManagedObjectContext {
        return .defaultContext
    }
    
    // MARK: - 异步获取面板
    /// 异步获取所有面板
    func fetchDashboards(completion: @escaping ([WSDashboard]?) -> Void) {
        CDDashboard.fetchDashboards { results in
            completion(results?.toWSDashboards)
        }
    }
    
    // MARK: - 同步获取面板
 
    /// 特定标识的面板
    func getDashboard(withIdentifier identifier: String) -> WSDashboard? {
        guard let content = CDDashboard.getDashboard(withIdentifier: identifier) else {
            return nil
        }
        
        return WSDashboard(content: content)
    }
    
    // MARK: - 处理面板
    /// 创建面板
    @discardableResult
    func createDashboard(name: String? = nil,
                         colorHex: String? = nil) -> WSDashboard {
        let content = CDDashboard.newDashboard(name: name, colorHex: colorHex)
        content.order = CDDashboard.maximumOrder + kOrderedStep
        
        let dashboard = WSDashboard(content: content)
        updater.didCreateWorkspaceDashbaord(dashboard)
        HandyRecord.updateChangeCount()
        return dashboard
    }
    
    /// 更新面板名称
    @discardableResult
    func updateDashboard(_ dashboard: WSDashboard, name: String?) -> WSDashboard? {
        guard dashboard.name != name else {
            return nil
        }
        
        guard let content = CDDashboard.getDashboard(withIdentifier: dashboard.identifier) else {
            return nil
        }
        
        let change: WorkspaceDashboardChange = .name(oldValue: dashboard.name, newValue: name)
        content.update(name: name, colorHex: dashboard.colorHex)
        
        /// 同步外部持有的模型实例，避免界面继续读到旧值
        dashboard.name = name
        dashboard.modificationDate = content.modificationDate
        
        updater.didUpdateWorkspaceDashbaord(dashboard, with: change)
        HandyRecord.updateChangeCount()
        return dashboard
    }
    
    /// 删除面板
    /// - Note: 面板与插件为级联删除关系，先同步落库再通知，保证通知后不再查到待删除的插件
    func deleteDashboard(_ dashboard: WSDashboard) {
        guard let content = CDDashboard.getDashboard(withIdentifier: dashboard.identifier) else {
            return
        }
        
        context.delete(content)
        HandyRecord.saveSynchronously()
        
        updater.didDeleteWorkspaceDashbaord(dashboard)
    }
    
    /// 排序面板
    func didEndReorderDashboards(with orderedDashboards: [WSDashboard]) {
        guard orderedDashboards.count > 0 else {
            return
        }
        
        /// 拖动结束后仅调整顺序因子，数组顺序即最新的展示顺序
        orderedDashboards.updateOrders()
        guard CDDashboard.syncOrders(for: orderedDashboards) else {
            return
        }
        
        updater.didReorderWorkspaceDashbaord()
        HandyRecord.updateChangeCount()
    }
}
