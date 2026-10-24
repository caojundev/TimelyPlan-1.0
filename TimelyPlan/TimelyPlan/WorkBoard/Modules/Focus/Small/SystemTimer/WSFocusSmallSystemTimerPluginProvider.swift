//
//  WSFocusSmallSystemTimerPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 专注·小·默认计时器。纵向展示三个默认的系统计时器。
class WSFocusSmallSystemTimerPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .focusSmallSystemTimer
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSFocusSmallSystemTimerContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSFocusSystemTimerContentInteractor(plugin: plugin, context: context)
    }
}
