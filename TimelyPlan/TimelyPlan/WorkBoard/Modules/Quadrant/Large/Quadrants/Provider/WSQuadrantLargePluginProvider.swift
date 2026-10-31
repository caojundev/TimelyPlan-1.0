//
//  WSQuadrantLargePluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·大·任务。以两列两行的网格展示四个象限的未完成任务。
class WSQuadrantLargePluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .quadrantLargeTasks
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSQuadrantLargePluginContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantLargeContentInteractor(plugin: plugin, context: context)
    }
}
