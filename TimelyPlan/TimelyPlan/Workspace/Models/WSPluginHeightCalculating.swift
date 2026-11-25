//
//  WSPluginHeightCalculating.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/10.
//

import Foundation
import UIKit

// MARK: - 自适应高度

/// `flexible` 尺寸组件的高度计算对象。
///
/// 布局拿到容器宽度后直接向计算对象询问高度，因此条目尺寸在一趟布局内即可确定，
/// 不需要先创建单元格再二次布局；宽度变化（旋转、分屏、画廊）时会重新询问。
///
/// 计算对象由组件提供者按插件配置创建，只应依赖插件配置与给定宽度：
/// 展示数据引起的尺寸变化应由组件在数据更新后让面板重新布局。
protocol WSPluginHeightCalculating {

    /// 组件在给定宽度下所需的高度。
    /// - Parameter width: 可用宽度，已扣除容器边距与行内间距
    func height(forWidth width: CGFloat) -> CGFloat
}
