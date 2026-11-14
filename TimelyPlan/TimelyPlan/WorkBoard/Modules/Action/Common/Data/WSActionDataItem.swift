//
//  WSActionDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/13.
//

import Foundation

// MARK: - 数据条目

/// 动作组件的展示数据。
///
/// 行视图的数据条目直接使用 `WSActionItem`，点击时原样交给交互器执行。
class WSActionListDataItem: NSObject, WSPluginDataItem {

    /// 待展示的动作，顺序与配置一致
    let actions: [WSActionItem]

    init(actions: [WSActionItem]) {
        self.actions = actions
        super.init()
    }
}
