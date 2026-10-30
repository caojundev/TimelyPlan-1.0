//
//  WSQuadrantMediumDonutPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·中·圆环。左侧以环形展示四个象限未完成任务的占比，右侧以列表展示各象限的数目。
class WSQuadrantMediumDonutPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .quadrantMediumDonut
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSQuadrantMediumDonutContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantCountsContentInteractor(plugin: plugin, context: context)
    }
}
