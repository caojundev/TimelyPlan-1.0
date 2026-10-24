//
//  WSFocusPomodoroDataItem.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation

// MARK: - 数据条目

/// 专注·小·番茄钟的组件数据。
///
/// 内容视图只依赖该数据渲染，不直接访问专注数据仓库。
class WSFocusPomodoroDataItem: NSObject, WSPluginDataItem {
    
    /// 番茄钟配置。圆环分段与底部说明都据此渲染
    let config: FocusPomodoroConfig
    
    init(config: FocusPomodoroConfig) {
        self.config = config
        super.init()
    }
}
