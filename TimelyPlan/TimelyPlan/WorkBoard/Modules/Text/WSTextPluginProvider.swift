//
//  WSTextPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

// MARK: - 配置

/// 文本组件的配置
struct WSTextConfiguration: Codable {

    /// 文本内容
    var text: String?

    /// 文本样式
    var textStyle: WSTextStyle?

    /// 文本对齐方式
    var textAlignment: WSTextAlignment?
}

// MARK: - 组件提供者

/// 文本·自适应·文本块。展示用户在配置界面中填写的文本。
class WSTextPluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .Text.flexibleText
    }

    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSTextContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSTextContentInteractor(plugin: plugin, context: context)
    }

    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSTextConfigViewController(plugin: plugin)
    }

    /// 高度按文本在整行宽度下的实际行数计算
    func makeHeightCalculator(plugin: WSPlugin) -> WSPluginHeightCalculating? {
        return WSTextHeightCalculator(configuration: plugin.configuration(as: WSTextConfiguration.self))
    }

    /// 文本本身即为视觉元素，单元格不需要背景
    func appearance(for plugin: WSPlugin) -> WSPluginAppearance {
        return .transparent
    }
}

// MARK: - 内容交互器

/// 文本组件的内容交互器。文本直接取自组件配置，不访问数据仓库。
class WSTextContentInteractor: WSPluginContentInteractor {

    /// 点击组件直接进入配置，便于修改文本
    override func performPrimaryAction() {
        configActionHandler?()
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let configuration = plugin.configuration(as: WSTextConfiguration.self)
        completion(WSTextDataItem(configuration: configuration))
    }

    // MARK: - 预览数据
    /// 画廊预览数据：展示默认文案
    override func previewDataItem() -> WSPluginDataItem? {
        return WSTextDataItem(configuration: nil)
    }
}
