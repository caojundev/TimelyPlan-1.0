//
//  WSTodoFilterTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 待办自选过滤器任务组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 布局」，过滤器任务的取数与配置由基类统一提供。
class WSTodoFilterTasksPluginProvider: WSTodoGroupTasksPluginProvider {
    
    init(type: WSPluginType,
         layoutConfiguration: WSTodoGroupTasksContentView.LayoutConfiguration) {
        super.init(type: type,
                   layoutConfiguration: layoutConfiguration,
                   emptyPlaceholderTitle: resGetString("No Filter Selected"))
    }
    
    override func makeContentInteractor(plugin: WSPlugin,
                                       context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoFilterTasksContentInteractor(plugin: plugin,
                                                  context: context,
                                                  maximumItemCount: layoutConfiguration.itemCount,
                                                  option: [.schedule, .step])
    }
    
    /// 由用户单选要展示的过滤器
    override func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTodoFilterSingleSelectionConfigViewController(plugin: plugin)
    }
}
