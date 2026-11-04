//
//  WSTodoListSelectedListsConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation

// MARK: - 配置

/// 待办清单组件的配置。
///
/// 为空表示用户尚未配置，此时组件按待办首页的顺序展示清单。
struct WSTodoListSelectedListsConfiguration: Codable {
    
    /// 用户选择的清单标识，按选择顺序展示
    var listIdentifiers: [String] = []
}
