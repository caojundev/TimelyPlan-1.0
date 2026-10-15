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

    /// 对应的 SF Symbols 图标名。
    var iconName: String {
        module.iconName
    }
}

// MARK: - 模块

/// 模块维度。一个模块下挂载三个固定尺寸的组件类型。
public enum WSPluginModule: String, Codable, CaseIterable {
    case todo
    case habit
    case focus
    case goal
    case countdown
}

public extension WSPluginModule {

    /// 模块展示名称（不含尺寸后缀）。
    var displayName: String {
        switch self {
        case .todo: return "待办任务"
        case .habit: return "习惯打卡"
        case .focus: return "专注计时"
        case .goal: return "目标进度"
        case .countdown: return "倒数日"
        }
    }

    /// 模块对应的 SF Symbols 图标名。
    var iconName: String {
        switch self {
        case .todo: return "checklist"
        case .habit: return "flame"
        case .focus: return "timer"
        case .goal: return "target"
        case .countdown: return "calendar.badge.clock"
        }
    }

    /// 该模块下的全部组件类型，按尺寸由小到大排列。
    var types: [WSPluginType] {
        WSPluginType.allCases
            .filter { $0.module == self }
            .sorted { $0.size.order < $1.size.order }
    }
}
