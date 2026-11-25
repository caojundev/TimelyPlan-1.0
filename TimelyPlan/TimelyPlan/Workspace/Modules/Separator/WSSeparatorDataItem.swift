//
//  WSSeparatorDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/11.
//

import Foundation

// MARK: - 数据条目

/// 分割线组件数据。
///
/// 只承载绘制样式，未配置时使用实线。
class WSSeparatorDataItem: NSObject, WSPluginDataItem {

    /// 分割线样式
    let style: WSSeparatorStyle

    init(style: WSSeparatorStyle) {
        self.style = style
        super.init()
    }

    /// 由组件配置生成展示数据。配置为空时使用实线
    convenience init(configuration: WSSeparatorConfiguration?) {
        self.init(style: configuration?.style ?? .solid)
    }
}
