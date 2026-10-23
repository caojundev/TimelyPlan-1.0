//
//  WSPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

/// 组件的展示上下文。
///
/// 同一组件会同时出现在仪表盘与画廊中：仪表盘展示用户真实数据，
/// 画廊只展示固定预览数据，由上下文决定交互器的取数来源。
enum WSPluginContext {
    
    /// 仪表盘：读取用户真实数据
    case dashboard
    
    /// 画廊：展示固定预览数据，不访问数据仓库
    case gallery
}

/// 组件提供者。
///
/// 提供者决定组件的「外观与数据来源」：用哪个单元格承载、用哪个内容视图渲染，
/// 以及用哪个内容 ViewModel 取数。
protocol WSPluginProvider: AnyObject {
    
    /// 插件类型
    var type: WSPluginType { get }
    
    /// 该组件注册的单元格类
    var cellClass: WSPluginCell.Type { get }
    
    /// 创建该组件内容交互器
    func makeContentInteractor(plugin: WSPlugin, context: WSPluginContext) -> WSPluginContentInteractor
    
    /// 创建该组件的占位视图，用于数据加载完成前的占位展示。
    ///
    /// 返回 nil 时，单元格使用默认加载占位视图 `WSPluginLoadingPlaceholderView`。
    func makeLoadingPlaceholderView() -> UIView?
    
    /// 创建该组件的空白内容视图，用于数据加载完成但没有内容（`dataItem` 为 nil）时的展示。
    ///
    /// 返回 nil 时，单元格使用默认空白内容视图 `WSPluginDefaultEmptyPlaceholderView`。
    ///
    /// 自定义视图继承 `WSPluginEmptyPlaceholderView` 即可复用交互器注入与配置入口。
    func makeEmptyPlaceholderView() -> UIView?
    
    /// 创建默认空白内容视图的配置项。
    ///
    /// 仅在未提供 `makeEmptyPlaceholderView()` 时生效，用于定制默认空白视图的图标、
    /// 描述与「配置插件」按钮样式。返回 nil 时使用默认配置。
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration?
    
    /// 创建该组件的配置界面。
    ///
    /// 组件可返回 `WSPluginConfigViewController` 子类，也可返回任意实现
    /// `WSPluginConfigurable` 的视图控制器；返回 nil 表示该组件不支持配置，
    /// 长按菜单中不显示「配置」项。
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)?
}

extension WSPluginProvider {
    
    /// 默认不提供占位视图，由单元格使用默认加载占位视图
    func makeLoadingPlaceholderView() -> UIView? {
        return nil
    }
    
    /// 默认不提供空白内容视图，由单元格使用默认空白内容视图
    func makeEmptyPlaceholderView() -> UIView? {
        return nil
    }
    
    /// 默认不提供空白内容配置，由默认空白内容视图使用内置配置
    func makeEmptyPlaceholderConfiguration() -> WSPluginEmptyPlaceholderConfiguration? {
        return nil
    }
    
    /// 默认不支持配置
    func makeConfigViewController(plugin: WSPlugin) -> (UIViewController & WSPluginConfigurable)? {
        return nil
    }
}
