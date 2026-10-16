//
//  WSPluginProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/15.
//

import Foundation
import UIKit

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
    func makeContentInteractor(element: WSPluginElement) -> WSPluginContentInteractor
    
    /// 创建该组件的占位视图，用于数据加载完成前的占位展示。
    ///
    /// 返回 nil 时，单元格使用默认占位视图 `WSPluginDefaultPlaceholderView`。
    func makePlaceholderView() -> UIView?
}

extension WSPluginProvider {
    
    /// 默认不提供占位视图，由单元格使用默认占位视图
    func makePlaceholderView() -> UIView? {
        return nil
    }
}
