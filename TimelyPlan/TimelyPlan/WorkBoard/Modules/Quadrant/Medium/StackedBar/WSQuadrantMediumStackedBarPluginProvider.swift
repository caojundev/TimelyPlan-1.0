//
//  WSQuadrantMediumStackedBarPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·中·比例条。以圆角堆叠比例条展示四个象限未完成任务的占比，并列出各象限详情。
class WSQuadrantMediumStackedBarPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .quadrantMediumStackedBar
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSQuadrantMediumStackedBarContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantCountsContentInteractor(plugin: plugin, context: context)
    }
}
