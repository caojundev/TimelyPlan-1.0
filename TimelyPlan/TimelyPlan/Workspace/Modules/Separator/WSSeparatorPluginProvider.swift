//
//  WSSeparatorPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 配置

/// 分割线组件的配置
struct WSSeparatorConfiguration: Codable {

    /// 分割线样式
    var style: WSSeparatorStyle?
}

// MARK: - 组件提供者

/// 分割线·自适应·分割线。展示一条可配置样式的分割线。
class WSSeparatorPluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .Separator.flexibleLine
    }

    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSSeparatorContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSSeparatorContentInteractor(plugin: plugin, context: context)
    }

    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSSeparatorConfigViewController(plugin: plugin)
    }

    /// 高度当前为固定值
    func makeHeightCalculator(plugin: WSPlugin) -> WSPluginHeightCalculating? {
        return WSSeparatorHeightCalculator()
    }

    /// 分割线本身即为视觉元素，单元格不需要背景
    func appearance(for plugin: WSPlugin) -> WSPluginAppearance {
        return .transparent
    }
}

// MARK: - 内容交互器

/// 分割线组件的内容交互器。样式直接取自组件配置，不访问数据仓库。
class WSSeparatorContentInteractor: WSPluginContentInteractor {

    /// 点击组件直接进入配置，便于切换样式
    override func performPrimaryAction() {
        configActionHandler?()
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let configuration = plugin.configuration(as: WSSeparatorConfiguration.self)
        completion(WSSeparatorDataItem(configuration: configuration))
    }

    // MARK: - 预览数据
    /// 画廊预览数据：展示默认的实线
    override func previewDataItem() -> WSPluginDataItem? {
        return WSSeparatorDataItem(style: .solid)
    }
}
