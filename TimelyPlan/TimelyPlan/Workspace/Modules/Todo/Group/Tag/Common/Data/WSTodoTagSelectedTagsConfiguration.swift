//
//  WSTodoTagSelectedTagsConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation

// MARK: - 配置

/// 待办标签组件的配置。
///
/// 为空表示用户尚未配置，此时组件不展示标签。
struct WSTodoTagSelectedTagsConfiguration: Codable {
    
    /// 用户选择的标签标识，按选择顺序展示
    var tagIdentifiers: [String] = []
}
