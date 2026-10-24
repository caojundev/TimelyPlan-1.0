//
//  WSFocusCountdownDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation

// MARK: - 数据条目

/// 专注·小·倒计时的组件数据。
///
/// 内容视图只依赖该数据渲染，不直接访问专注数据仓库。
class WSFocusCountdownDataItem: NSObject, WSPluginDataItem {
    
    /// 倒计时配置。进度圆环与底部说明都据此渲染
    let config: FocusCountdownConfig
    
    init(config: FocusCountdownConfig) {
        self.config = config
        super.init()
    }
}
