//
//  WSBodyPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

// MARK: - 配置

/// 正文组件的配置
struct WSBodyConfiguration: Codable {

    /// 正文文本
    var text: String?
}

// MARK: - 组件提供者

/// 正文·自适应·文本。展示用户在配置界面中填写的正文。
class WSBodyPluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .Body.flexibleText
    }

    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSBodyContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSBodyContentInteractor(plugin: plugin, context: context)
    }

    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSBodyConfigViewController(plugin: plugin)
    }

    /// 高度按正文在整行宽度下的实际行数计算
    func makeHeightCalculator(plugin: WSPlugin) -> WSPluginHeightCalculating? {
        return WSBodyHeightCalculator(configuration: plugin.configuration(as: WSBodyConfiguration.self))
    }
}

// MARK: - 内容交互器

/// 正文组件的内容交互器。文本直接取自组件配置，不访问数据仓库。
class WSBodyContentInteractor: WSPluginContentInteractor {

    /// 点击组件直接进入配置，便于修改正文
    override func performPrimaryAction() {
        configActionHandler?()
    }

    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let configuration = plugin.configuration(as: WSBodyConfiguration.self)
        completion(WSBodyDataItem(configuration: configuration))
    }

    // MARK: - 预览数据
    /// 画廊预览数据：展示默认文案
    override func previewDataItem() -> WSPluginDataItem? {
        return WSBodyDataItem(configuration: nil)
    }
}
