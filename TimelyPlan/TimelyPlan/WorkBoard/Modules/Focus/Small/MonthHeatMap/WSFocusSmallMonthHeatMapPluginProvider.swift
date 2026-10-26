//
//  WSFocusSmallMonthHeatMapPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/26.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·小·本月热力图。展示本月专注时长与每天的热力分布。
class WSFocusSmallMonthHeatMapPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .focusSmallMonthHeatMap
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSFocusSmallMonthHeatMapContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSFocusMonthHeatMapContentInteractor(plugin: plugin, context: context)
    }
}
