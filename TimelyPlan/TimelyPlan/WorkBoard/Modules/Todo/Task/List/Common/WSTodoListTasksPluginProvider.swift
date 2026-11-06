//
//  WSTodoListTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 待办自选清单任务组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 布局」，清单任务的取数与配置由基类统一提供。
class WSTodoListTasksPluginProvider: WSTodoGroupTasksPluginProvider {
    
    init(type: WSPluginType,
         layoutConfiguration: WSTodoGroupTasksContentView.LayoutConfiguration) {
        super.init(type: type,
                   layoutConfiguration: layoutConfiguration,
                   emptyPlaceholderTitle: resGetString("No List Selected"))
    }
    
    override func makeContentInteractor(plugin: WSPlugin,
                                       context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoListTasksContentInteractor(plugin: plugin,
                                                context: context,
                                                maximumItemCount: layoutConfiguration.itemCount,
                                                option: [.schedule, .step])
    }
    
    /// 由用户单选要展示的清单
    override func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTodoListSingleSelectionConfigViewController(plugin: plugin)
    }
}
