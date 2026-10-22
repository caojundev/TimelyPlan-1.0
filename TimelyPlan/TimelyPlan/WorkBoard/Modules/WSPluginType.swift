// 文件：Workspace/Sources/Workspace/Core/Models/WSPluginType.swift

import Foundation

/// 组件类型。
///
/// 命名规则：模块 + 尺寸 + 内容。尺寸之后的词语说明该组件展示什么，
/// 用于区分同模块、同尺寸下的多种组件。
public enum WSPluginType: String, Codable, CaseIterable {
    
    // MARK: 倒数日
    /// 倒数日·小·自选：展示用户自己选择的一个倒数日事件。
    case countdownSmallSelected
    
    /// 倒数日·中·最近：展示距离当前日期最近的三个倒数日事项。
    case countdownMediumRecent
    
    /// 倒数日·大·最近：展示距离当前日期最近的五个倒数日事项。
    case countdownLargeRecent
}

// MARK: - 固有属性

public extension WSPluginType {

    /// 该组件固定的尺寸。
    var size: WSPluginSize {
        switch self {
        case .countdownSmallSelected:
            return .small
        case .countdownMediumRecent:
            return .medium
        case .countdownLargeRecent:
            return .large
        }
    }

    /// 所属模块。用于组件选择器分组，以及同模块三个尺寸之间的归类。
    var module: WSPluginModule {
        switch self {
        case .countdownSmallSelected, .countdownMediumRecent, .countdownLargeRecent:
            return .countdown
        }
    }

    /// 组件标题
    var title: String {
        switch self {
        case .countdownSmallSelected:
            return resGetString("Selected Countdown")
        case .countdownMediumRecent, .countdownLargeRecent:
            return resGetString("Recent Countdowns")
        }
    }

    /// 组件描述。画廊等入口作为副标题展示，一句话说明展示内容。
    var subtitle: String {
        switch self {
        case .countdownSmallSelected:
            return resGetString("Shows the selected countdown")
        case .countdownMediumRecent, .countdownLargeRecent:
            return resGetString("Shows the most recent countdowns")
        }
    }
}
