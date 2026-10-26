//
//  WSFocusSmallWeekActivityPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/25.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·小·本周活动。展示本周专注总时长与每天的活动分布。
class WSFocusSmallWeekActivityPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .focusSmallWeekActivity
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSFocusSmallWeekActivityContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSFocusWeekActivityContentInteractor(plugin: plugin, context: context)
    }
}
