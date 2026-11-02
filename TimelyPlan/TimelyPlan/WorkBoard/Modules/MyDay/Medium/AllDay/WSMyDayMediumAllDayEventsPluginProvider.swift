//
//  WSMyDayMediumAllDayEventsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 我的一天·中·全天事项。以列表展示今天的全天事项。
class WSMyDayMediumAllDayEventsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .myDayMediumAllDayEvents
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSMyDayMediumAllDayEventsContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSMyDayAllDayEventsContentInteractor(plugin: plugin, context: context)
    }
}
