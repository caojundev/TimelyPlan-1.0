//
//  WSQuadrantSmallTaskListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·小·任务列表。展示配置中选择的一个象限的未完成任务。
class WSQuadrantSmallTaskListPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .quadrantSmallTaskList
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSQuadrantSmallTaskListContentView()
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantTaskListContentInteractor(plugin: plugin, context: context)
    }
    
    /// 配置界面：选择要展示的象限
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSQuadrantTaskConfigViewController(plugin: plugin)
    }
}
