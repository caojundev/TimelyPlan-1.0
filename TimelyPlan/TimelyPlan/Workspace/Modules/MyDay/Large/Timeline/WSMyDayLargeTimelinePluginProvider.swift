//
//  WSMyDayLargeTimelinePluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 我的一天·大·时间线。以时间线展示正在进行或即将开始的事项。
class WSMyDayLargeTimelinePluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .MyDay.largeTimeline
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSMyDayLargeTimelineContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSMyDayTimelineContentInteractor(plugin: plugin, context: context)
    }
}
