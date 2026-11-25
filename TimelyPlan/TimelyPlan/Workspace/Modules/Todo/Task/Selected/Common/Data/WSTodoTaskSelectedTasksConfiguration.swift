//
//  WSTodoTaskSelectedTasksConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/5.
//

import Foundation

// MARK: - 配置

/// 待办自选任务组件的配置。
///
/// 为空表示用户尚未配置，此时组件展示空白内容并引导完成配置。
struct WSTodoTaskSelectedTasksConfiguration: Codable {

    /// 用户选择的任务标识，按选择顺序展示
    var taskIdentifiers: [String] = []
}
