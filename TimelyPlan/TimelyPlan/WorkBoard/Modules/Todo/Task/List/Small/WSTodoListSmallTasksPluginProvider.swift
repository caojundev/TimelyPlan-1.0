//
//  WSTodoListSmallTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者

/// 待办·小·自选清单任务列表。展示所选清单中的未完成任务。
class WSTodoListSmallTasksPluginProvider: WSPluginProvider {
    
    /// 插件类型
    var type: WSPluginType {
        return .TodoListTask.smallList
    }
    
    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSTodoListSmallTasksContentView(maximumRowCount: WSTodoTaskItemCount.smallList)
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoListTasksContentInteractor(plugin: plugin,
                                                context: context,
                                                option: [.schedule, .step])
    }
    
    /// 未选择清单时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No List Selected")
        return configuration
    }
    
    /// 由用户单选要展示的清单
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTodoListSingleSelectionConfigViewController(plugin: plugin)
    }
}
