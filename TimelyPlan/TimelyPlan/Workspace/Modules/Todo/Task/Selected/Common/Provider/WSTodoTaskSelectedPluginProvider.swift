//
//  WSTodoTaskSelectedPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation
import UIKit

// MARK: - 展示条数

/// 待办自选任务组件的展示条数。
enum WSTodoTaskItemCount {

    /// 小号列表组件的展示条数
    static let smallList = 3

    /// 中号列表组件的展示条数
    static let mediumList = 3

    /// 大号列表组件的展示条数
    static let largeList = 6

    /// 中号网格组件的展示条数
    static let mediumGrid = 4

    /// 大号网格组件的展示条数
    static let largeGrid = 10

    /// 网格组件的列数
    static let gridColumnCount = 2
}

// MARK: - 组件提供者基类

/// 待办自选任务组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 展示条数 + 布局」，取数与交互由基类统一提供。
class WSTodoTaskSelectedPluginProvider: WSPluginProvider {

    /// 插件类型
    let type: WSPluginType

    /// 最多展示的任务数目
    let itemCount: Int

    /// 任务详情的展示项，默认与待办任务列表一致
    let option: TodoTaskDetailOption

    /// 内容视图的布局配置
    let layoutConfiguration: WSTodoTaskSelectedRowsContentView.LayoutConfiguration

    init(type: WSPluginType,
         itemCount: Int,
         option: TodoTaskDetailOption = .allExceptList,
         layoutConfiguration: WSTodoTaskSelectedRowsContentView.LayoutConfiguration) {
        self.type = type
        self.itemCount = itemCount
        self.option = option
        self.layoutConfiguration = layoutConfiguration
    }

    /// 该组件尺寸
    var size: WSPluginSize {
        return type.size
    }

    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSTodoTaskSelectedRowsContentView(itemCount: itemCount,
                                                 layoutConfiguration: layoutConfiguration)
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTodoTaskSelectedContentInteractor(plugin: plugin,
                                                   context: context,
                                                   maximumItemCount: itemCount,
                                                   option: option)
    }

    /// 未选择任务时提示配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        var configuration = WSPluginEmptyPlaceholderConfiguration()
        configuration.iconName = "checklist"
        configuration.title = resGetString("No Task Selected")
        return configuration
    }

    /// 由用户选择要展示的任务，最多可选择与展示条数相同的数目
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTodoTaskSelectedConfigViewController(plugin: plugin,
                                                      maximumSelectionCount: itemCount)
    }
}
