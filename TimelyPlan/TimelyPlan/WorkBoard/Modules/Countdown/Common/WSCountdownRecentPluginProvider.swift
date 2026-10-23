//
//  WSCountdownRecentPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation
import UIKit

// MARK: - 组件提供者基类

/// 倒数日「最近」类组件提供者基类。
///
/// 各尺寸组件只需声明「类型 + 单元格 + 展示条数」，取数与行内点击详情等行为由基类统一提供。
class WSCountdownRecentPluginProvider: WSPluginProvider {
    
    /// 插件类型
    let type: WSPluginType
    
    /// 该组件注册的单元格类
    let cellClass: WSPluginCell.Type
    
    /// 最多展示的事项数目
    let itemCount: Int
    
    /// 初始化提供者
    /// - Parameters:
    ///   - type: 插件类型
    ///   - cellClass: 单元格类
    ///   - itemCount: 最多展示的事项数目
    init(type: WSPluginType, cellClass: WSPluginCell.Type, itemCount: Int) {
        self.type = type
        self.cellClass = cellClass
        self.itemCount = itemCount
    }
    
    /// 该组件尺寸
    var size: WSPluginSize {
        return type.size
    }
    
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor {
        return WSCountdownRecentContentInteractor(plugin: plugin,
                                                  context: context,
                                                  maximumItemCount: itemCount)
    }
}
