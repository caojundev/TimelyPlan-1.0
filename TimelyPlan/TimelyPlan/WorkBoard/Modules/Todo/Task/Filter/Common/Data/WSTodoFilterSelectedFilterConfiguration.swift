//
//  WSTodoFilterSelectedFilterConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 配置

/// 待办过滤器单选组件的配置。
///
/// 为空表示用户尚未选择过滤器，此时组件展示空白内容。
struct WSTodoFilterSelectedFilterConfiguration: Codable {
    
    /// 用户选择的过滤器标识
    var filterIdentifier: String?
}
