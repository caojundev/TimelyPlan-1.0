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

    /// 组件标题。画廊等「一页一个组件」的入口作为主标题展示，只体现组件本身，不含尺寸后缀。
    var title: String {
        return module.displayName
    }

    /// 组件描述。画廊等入口作为副标题展示，说明该尺寸组件展示的内容。
    var subtitle: String {
        switch self {
        case .countdownSmall:
            return "小尺寸，只展示最近的一个倒数日"
        case .countdownMedium:
            return "中尺寸，展示倒数日与剩余天数"
        case .countdownLarge:
            return "大尺寸，展示倒数日、剩余天数与进度"
        }
    }
}
