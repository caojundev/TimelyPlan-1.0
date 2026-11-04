//
//  WSTodoFilterSelectedFiltersConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation

// MARK: - 配置

/// 待办过滤器组件的配置。
///
/// 为空表示用户尚未配置，此时组件不展示过滤器。
struct WSTodoFilterSelectedFiltersConfiguration: Codable {
    
    /// 用户选择的过滤器标识，按选择顺序展示
    var filterIdentifiers: [String] = []
}
