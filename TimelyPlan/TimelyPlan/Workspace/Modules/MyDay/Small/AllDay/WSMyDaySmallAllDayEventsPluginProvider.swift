//
//  WSMyDaySmallAllDayEventsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 我的一天·小·全天事项。逐行展示今天的全天事项。
class WSMyDaySmallAllDayEventsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .MyDay.smallAllDayEvents
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSMyDaySmallAllDayEventsContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSMyDayAllDayEventsContentInteractor(plugin: plugin, context: context)
    }
}
