//
//  WSPluginIcon.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/17.
//

import Foundation
import UIKit

// MARK: - 模块图标

/// 模块图标：图标名称、渲染色、图标区域背景色与尺寸。
///
/// 由模块声明，选择器单元格负责应用。后续需要更多图标维度（描边等）时在这里追加字段即可。
struct WSPluginIcon {

    /// 图标名称。为 nil 时不展示图标
    var name: String?

    /// 图标渲染色。为 nil 时保留图片原色；传动态色即可随明暗模式变化
    var color: UIColor?

    /// 图标区域背景色。为 nil 时使用单元格默认背景
    var backgroundColor: UIColor?

    /// 图标尺寸。为 nil 时使用单元格默认尺寸
    var size: CGSize?

    static let empty = WSPluginIcon()

    init(name: String? = nil,
         color: UIColor? = nil,
         backgroundColor: UIColor? = nil,
         size: CGSize? = nil) {
        self.name = name
        self.color = color
        self.backgroundColor = backgroundColor
        self.size = size
    }

    /// 图标渲染配置。每次返回新实例，避免多个条目共享同一份可变配置
    var imageConfig: TPImageAccessoryConfig {
        let config = TPImageAccessoryConfig()
        config.shouldRenderImageWithColor = color != nil
        config.color = color
        if let size = size {
            config.size = size
        }

        return config
    }

    /// 变体覆盖：只覆盖值为非 nil 的字段，nil 沿用原图标
    func merging(_ other: WSPluginIcon?) -> WSPluginIcon {
        guard let other = other else {
            return self
        }

        return WSPluginIcon(name: other.name ?? name,
                            color: other.color ?? color,
                            backgroundColor: other.backgroundColor ?? backgroundColor,
                            size: other.size ?? size)
    }
}
