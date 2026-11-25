//
//  WSPluginBootstrap.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

/// 组件注册入口。
enum WSPluginBootstrap {
    
    /// 注册所有组件。组件清单见 `WSPluginCatalog.all`，新增组件无需修改此处。
    static func registerAll() {
        let registry = WSPluginRegistry.shared
        WSPluginCatalog.all.forEach { registry.register($0.provider) }
    }
}
