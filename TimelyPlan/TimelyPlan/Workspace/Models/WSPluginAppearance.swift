//
//  WSPluginAppearance.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation
import UIKit

// MARK: - 组件外观

/// 组件在面板中的外观。
///
/// 由组件提供者按插件返回，单元格负责应用。后续需要更多外观维度
/// （圆角、内边距、描边、阴影等）时在这里追加字段即可，提供者协议无需改动。
struct WSPluginAppearance {

    /// 单元格背景色。为 nil 时不绘制背景，直接露出面板底色
    var backgroundColor: UIColor?

    /// 默认外观：系统分组背景色，与系统小组件一致
    static let `default` = WSPluginAppearance(backgroundColor: .secondarySystemGroupedBackground)

    /// 无背景外观：单元格与内容视图都透明
    static let transparent = WSPluginAppearance(backgroundColor: nil)
}
