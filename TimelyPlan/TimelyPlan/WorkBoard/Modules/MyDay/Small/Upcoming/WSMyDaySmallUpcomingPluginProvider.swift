//
//  WSMyDaySmallUpcomingPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 我的一天·小·临近事项。展示正在进行或今天接下来即将开始的第一个事项。
class WSMyDaySmallUpcomingPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .myDaySmallUpcoming
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSMyDaySmallUpcomingContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSMyDayUpcomingContentInteractor(plugin: plugin, context: context)
    }
}
