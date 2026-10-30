//
//  WSQuadrantSmallDonutPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·小·圆环。以环形展示四个象限未完成任务的占比。
class WSQuadrantSmallDonutPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .quadrantSmallDonut
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSQuadrantSmallDonutContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantCountsContentInteractor(plugin: plugin, context: context)
    }
}
