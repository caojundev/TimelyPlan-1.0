//
//  WSQuadrantMediumCountsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·中·数量。以一行四列横向展示四个象限的未完成任务数。
class WSQuadrantMediumCountsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .quadrantMediumCounts
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSQuadrantMediumCountsContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantCountsContentInteractor(plugin: plugin, context: context)
    }
}
