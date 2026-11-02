//
//  WSMyDayMediumTimelinePluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/2.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 我的一天·中·时间线。以时间线展示正在进行或即将开始的事项。
class WSMyDayMediumTimelinePluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .myDayMediumTimeline
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSMyDayMediumTimelineContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSMyDayTimelineContentInteractor(plugin: plugin, context: context)
    }
}
