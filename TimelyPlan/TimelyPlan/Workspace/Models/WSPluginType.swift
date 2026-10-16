// 文件：Workspace/Sources/Workspace/Core/Models/WSPluginType.swift

import Foundation

/// 组件类型。
public enum WSPluginType: String, Codable, CaseIterable {
    
    // MARK: 倒数日
    case countdownSmall
    case countdownMedium
    case countdownLarge
}

// MARK: - 固有属性

public extension WSPluginType {

    /// 该组件固定的尺寸。
    var size: WSPluginSize {
        switch self {
        case .countdownSmall:
            return .small
        case .countdownMedium:
            return .medium
        case .countdownLarge:
            return .large
        }
    }

    /// 所属模块。用于组件选择器分组，以及同模块三个尺寸之间的归类。
    var module: WSPluginModule {
        switch self {
        case .countdownSmall, .countdownMedium, .countdownLarge:
            return .countdown
        }
    }

    /// 组件展示名称，已包含尺寸后缀，可直接用于选择器列表。
    var displayName: String {
        "\(module.displayName)·\(size.displayName)"
    }
}
