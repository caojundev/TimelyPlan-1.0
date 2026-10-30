//
//  WSQuadrantSmallCountsPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/30.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·小·数量。以两列网格展示四个象限的未完成任务数。
class WSQuadrantSmallCountsPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .quadrantSmallCounts
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSQuadrantSmallCountsContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantCountsContentInteractor(plugin: plugin, context: context)
    }
}
