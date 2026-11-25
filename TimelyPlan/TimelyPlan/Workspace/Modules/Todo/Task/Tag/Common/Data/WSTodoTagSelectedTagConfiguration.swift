//
//  WSTodoTagSelectedTagConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 配置

/// 待办标签单选组件的配置。
///
/// 为空表示用户尚未选择标签，此时组件展示空白内容。
struct WSTodoTagSelectedTagConfiguration: Codable {
    
    /// 用户选择的标签标识
    var tagIdentifier: String?
}
