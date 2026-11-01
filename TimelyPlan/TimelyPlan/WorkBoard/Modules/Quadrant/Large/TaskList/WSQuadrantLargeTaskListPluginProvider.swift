//
//  WSQuadrantLargeTaskListPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/31.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 四象限·大·任务列表。展示配置中选择的一个象限的未完成任务。
class WSQuadrantLargeTaskListPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .quadrantLargeTaskList
    }
    
    /// 创建该组件内容视图。大尺寸高度更大，行高与行间距相应增大
    func makeContentView() -> WSPluginContentView {
        return WSQuadrantTaskListContentView(minimumRowHeight: 36.0, rowSpacing: 3.0)
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSQuadrantLargeTaskListContentInteractor(plugin: plugin, context: context)
    }
    
    /// 配置界面：选择要展示的象限
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSQuadrantTaskConfigViewController(plugin: plugin)
    }
}
