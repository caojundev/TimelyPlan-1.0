//
//  WSPluginBootstrap.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/17.
//

import Foundation

/// 组件注册入口。
enum WSPluginBootstrap {
    
    /// 全部组件提供者。
    ///
    /// 新增组件时只需在此数组追加一项。数组顺序不影响结果，
    /// 展示顺序由 `WSPluginRegistry` 按模块、尺寸统一排序。
    static let providers: [WSPluginProvider] = [
        // 倒数日
        WSCountdownSmallSelectedPluginProvider(),
        WSCountdownSmallEventsPluginProvider(),
        WSCountdownMediumEventsListPluginProvider(),
        WSCountdownMediumEventsGridPluginProvider(),
        WSCountdownMediumEventsColumnsPluginProvider(),
        WSCountdownLargeEventsListPluginProvider(),
        WSCountdownLargeEventsGridPluginProvider(),
        
        // 专注
        WSFocusSmallSystemTimerPluginProvider(),
        WSFocusMediumSystemTimerPluginProvider(),
    ]

    /// 注册所有组件 Provider。必须在 App 启动时调用一次。
    static func registerAll() {
        let registry = WSPluginRegistry.shared
        providers.forEach { registry.register($0) }
    }
}
