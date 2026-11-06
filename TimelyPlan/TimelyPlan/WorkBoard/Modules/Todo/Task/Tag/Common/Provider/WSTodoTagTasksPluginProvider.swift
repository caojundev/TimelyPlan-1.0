//
//  WSTodoTagTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 待办自选标签任务组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 布局」，标签任务的取数与配置由基类统一提供。
class WSTodoTagTasksPluginProvider: WSTodoGroupTasksPluginProvider {
    
    init(type: WSPluginType,
         layoutConfiguration: WSTodoGroupTasksContentView.LayoutConfiguration) {
        super.init(type: type,
                   layoutConfiguration: layoutConfiguration,
                   emptyPlaceholderTitle: resGetString("No Tag Selected"))
    }
    
    override func makeContentInteractor(plugin: WSPlugin,
                                       context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoTagTasksContentInteractor(plugin: plugin,
                                               context: context,
                                               maximumItemCount: layoutConfiguration.itemCount,
                                               option: [.schedule, .step])
    }
    
    /// 由用户单选要展示的标签
    override func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTodoTagSingleSelectionConfigViewController(plugin: plugin)
    }
}
