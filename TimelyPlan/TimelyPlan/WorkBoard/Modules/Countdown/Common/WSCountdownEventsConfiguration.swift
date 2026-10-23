//
//  WSCountdownEventsConfiguration.swift
//  TimelyPlan
//
//  Created by caojun on 2026/10/23.
//

import Foundation

// MARK: - 数据来源

/// 倒数日「事项」类组件的数据来源。
///
/// 组件的展示内容由这里决定：默认按远近自动取最近若干项，
/// 也可切换为用户手动选择的事项。后续扩展（如全部、已归档）在此追加即可。
enum WSCountdownEventsSource: String, Codable {
    
    /// 最近事项：按与当前日期的远近自动取前若干条
    case recent
    
    /// 自选事项：展示用户手动选中的事项
    case selected
}

// MARK: - 配置

/// 倒数日「事项」类组件的配置。
struct WSCountdownEventsConfiguration: Codable {
    
    /// 数据来源。默认为最近事项
    var source: WSCountdownEventsSource = .recent
    
    /// 用户选中的事项标识，按展示顺序排列。仅在 `source == .selected` 时生效
    var eventIdentifiers: [String] = []
    
    private enum CodingKeys: String, CodingKey {
        case source
        case eventIdentifiers
    }
    
    init(source: WSCountdownEventsSource = .recent,
         eventIdentifiers: [String] = []) {
        self.source = source
        self.eventIdentifiers = eventIdentifiers
    }
    
    /// 缺失字段使用默认值，兼容旧版本写入的配置
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        source = try container.decodeIfPresent(WSCountdownEventsSource.self, forKey: .source) ?? .recent
        eventIdentifiers = try container.decodeIfPresent([String].self, forKey: .eventIdentifiers) ?? []
    }
}
