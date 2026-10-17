//
//  WorkspaceDashboardManager.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

class WorkspaceDashboardManager: SettingAgentObserver {

    let key = "WorkspaceDashboard"
    
    let updater = WorkspaceDashboardProcessorUpdater()
    
    /// 仪表盘字典。暂未接入持久化，先以内存字典模拟：键为标识，值为对应仪表盘
    private var dashboards: [String: WSDashboard] = [:]
    
    init() {
        KeyValueStorage.shared.addObserver(self, forKey: key)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeRemoteValue(for keyName: String) {
        debugPrint("Workspace Dashboard 远程数据更新: \(keyName)")
        updater.didChangeRemoteWorkspaceDashbaord()
    }
    
    // MARK: - 获取仪表盘
    /// 所有仪表盘，按排序因子升序返回。不存在时创建默认仪表盘
    func getDashboards() -> [WSDashboard] {
        createDefaultDashboardIfNeeded()
        return Array(dashboards.values).orderedElements()
    }
    
    /// 特定标识的仪表盘
    func getDashboard(withIdentifier identifier: String) -> WSDashboard? {
        return dashboards[identifier]
    }
    
    // MARK: - 处理仪表盘
    /// 创建仪表盘
    @discardableResult
    func createDashboard(name: String? = nil,
                         colorHex: String? = nil) -> WSDashboard {
        let dashboard = WSDashboard(identifier: UUID().uuidString)
        dashboard.name = name
        dashboard.colorHex = colorHex
        dashboard.order = Array(dashboards.values).insertOrder()
        dashboard.creationDate = .now
        dashboard.modificationDate = .now
        
        dashboards[dashboard.identifier] = dashboard
        updater.didCreateWorkspaceDashbaord(dashboard)
        return dashboard
    }
    
    /// 更新仪表盘名称
    @discardableResult
    func updateDashboard(_ dashboard: WSDashboard, name: String?) -> WSDashboard? {
        guard dashboard.name != name else {
            return nil
        }
        
        let change: WorkspaceDashboardChange = .name(oldValue: dashboard.name, newValue: name)
        dashboard.name = name
        dashboard.modificationDate = .now
        updater.didUpdateWorkspaceDashbaord(dashboard, with: change)
        return dashboard
    }
    
    /// 删除仪表盘
    func deleteDashboard(_ dashboard: WSDashboard) {
        guard dashboards.removeValue(forKey: dashboard.identifier) != nil else {
            return
        }
        
        updater.didDeleteWorkspaceDashbaord(dashboard)
    }
    
    /// 排序仪表盘
    func didEndReorderDashboards(with orderedDashboards: [WSDashboard]) {
        guard orderedDashboards.count > 0 else {
            return
        }
        
        /// 拖动结束后仅调整顺序因子，数组顺序即最新的展示顺序
        orderedDashboards.updateOrders()
        updater.didReorderWorkspaceDashbaord()
    }
    
    // MARK: - Helper
    /// 不存在仪表盘时创建默认仪表盘
    private func createDefaultDashboardIfNeeded() {
        guard dashboards.isEmpty else {
            return
        }
        
        createDashboard()
    }
}
