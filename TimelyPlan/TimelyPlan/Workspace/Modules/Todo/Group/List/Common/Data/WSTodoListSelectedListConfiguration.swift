//
//  WSTodoListSelectedListConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/6.
//

import Foundation

// MARK: - 配置

/// 待办清单单选组件的配置。
///
/// 为空表示用户尚未选择清单，此时组件展示空白内容。
struct WSTodoListSelectedListConfiguration: Codable {
    
    /// 用户选择的清单标识
    var listIdentifier: String?
}
