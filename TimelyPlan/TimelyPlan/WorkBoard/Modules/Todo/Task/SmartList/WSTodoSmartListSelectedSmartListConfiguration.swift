//
//  WSTodoSmartListSelectedSmartListConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/7.
//

import Foundation

// MARK: - 配置

/// 待办智能清单单选组件的配置。
///
/// 为空表示用户尚未选择智能清单，此时组件展示空白内容。
struct WSTodoSmartListSelectedSmartListConfiguration: Codable {
    
    /// 用户选择的智能清单类型标识
    var smartListIdentifier: String?
}
