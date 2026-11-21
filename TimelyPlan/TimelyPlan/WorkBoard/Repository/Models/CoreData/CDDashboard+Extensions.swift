//
//  CDDashboard+Extensions.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/20.
//

import Foundation
import CoreData

// MARK: - CoreData
extension CDDashboard: SortableIdentifiable {
    
    // MARK: - SortableIdentifiable
    var identifiableKey: String {
        return self.identifier ?? ""
    }
    
    /// 根据名称与颜色创建新面板
    static func newDashboard(name: String?, colorHex: String?) -> CDDashboard {
        let dashboard = CDDashboard.createEntity(in: .defaultContext)
        dashboard.identifier = UUID().uuidString /// 新创建面板设置标识
        dashboard.creationDate = .now
        dashboard.update(name: name, colorHex: colorHex)
        return dashboard
    }
    
    /// 更新面板基本信息
    func update(name: String?, colorHex: String?) {
        self.name = name
        self.colorHex = colorHex
        self.modificationDate = .now
    }
    
    /// 异步获取所有面板
    static func fetchDashboards(completion: @escaping ([CDDashboard]?) -> Void) {
        fetchAll(matching: nil, sortBy: ElementOrderKey, ascending: true) { results in
            completion(results as? [CDDashboard])
        }
    }
    
    /// 同步获取所有面板
    static func getDashboards() -> [CDDashboard]? {
        let dashboards: [CDDashboard]? = getAll(sortBy: ElementOrderKey,
                                                ascending: true,
                                                in: .defaultContext)
        return dashboards
    }
    
    /// 获取特定标识的面板
    static func getDashboard(withIdentifier identifier: String) -> CDDashboard? {
        return getItem(with: identifier)
    }
}
