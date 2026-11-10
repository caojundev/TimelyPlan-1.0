//
//  WSHeadlinePluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

// MARK: - 配置

/// 标题组件的配置
struct WSHeadlineConfiguration: Codable {

    /// 标题
    var title: String?

    /// 描述
    var subtitle: String?
}

// MARK: - 组件提供者

/// 标题·自适应·标题描述。展示用户在配置界面中填写的标题与描述。
class WSHeadlinePluginProvider: WSPluginProvider {

    /// 插件类型
    var type: WSPluginType {
        return .Headline.flexibleTitleDescription
    }

    /// 创建该组件内容视图
    func makeContentView() -> WSPluginContentView {
        return WSHeadlineContentView()
    }

    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSHeadlineContentInteractor(plugin: plugin, context: context)
    }

    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return WSHeadlineConfigViewController(plugin: plugin)
    }

    /// 高度按标题与描述在整行宽度下的实际行数计算
    func makeHeightCalculator(plugin: WSPlugin) -> WSPluginHeightCalculating? {
        return WSHeadlineHeightCalculator(configuration: plugin.configuration(as: WSHeadlineConfiguration.self))
    }
}

// MARK: - 内容交互器

/// 标题组件的内容交互器。文案直接取自组件配置，不访问数据仓库。
class WSHeadlineContentInteractor: WSPluginContentInteractor {

    override func performPrimaryAction() {
        configActionHandler?()
    }
    
    // MARK: - 取数
    override func fetchDataItem(completion: @escaping (WSPluginDataItem?) -> Void) {
        let configuration = plugin.configuration(as: WSHeadlineConfiguration.self)
        completion(WSHeadlineDataItem(configuration: configuration))
    }

    // MARK: - 预览数据
    /// 画廊预览数据：展示默认文案
    override func previewDataItem() -> WSPluginDataItem? {
        return WSHeadlineDataItem(configuration: nil)
    }
}
