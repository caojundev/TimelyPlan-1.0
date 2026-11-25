//
//  WSFocusUserTimerConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/24.
//

import Foundation

// MARK: - 配置

/// 用户计时器组件的配置。
struct WSFocusUserTimerConfiguration: Codable {
    
    /// 用户选中的计时器标识，按展示顺序排列
    var timerIdentifiers: [String] = []
    
    private enum CodingKeys: String, CodingKey {
        case timerIdentifiers
    }
    
    init(timerIdentifiers: [String] = []) {
        self.timerIdentifiers = timerIdentifiers
    }
    
    /// 缺失字段使用默认值，兼容旧版本写入的配置
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        timerIdentifiers = try container.decodeIfPresent([String].self, forKey: .timerIdentifiers) ?? []
    }
}
