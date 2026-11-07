//
//  WSTodoSmartListTasksPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 待办自选智能清单任务组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 布局」，智能清单任务的取数与配置由基类统一提供。
class WSTodoSmartListTasksPluginProvider: WSTodoGroupTasksPluginProvider {
    
    init(type: WSPluginType,
         layoutConfiguration: WSTodoGroupTasksContentView.LayoutConfiguration) {
        super.init(type: type,
                   layoutConfiguration: layoutConfiguration,
                   emptyPlaceholderTitle: resGetString("No Smart List Selected"))
    }
    
    override func makeContentInteractor(plugin: WSPlugin,
                                       context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoSmartListTasksContentInteractor(plugin: plugin,
                                                     context: context,
                                                     maximumItemCount: layoutConfiguration.itemCount,
                                                     option: [.schedule, .step])
    }
    
    /// 由用户单选要展示的智能清单
    override func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTodoSmartListSingleSelectionConfigViewController(plugin: plugin)
    }
}
