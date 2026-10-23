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
    
    /// 倒数日·小·最近：展示距离当前日期最近的两个倒数日事项。
    case countdownSmallRecent
    
    /// 倒数日·中·最近（列表）：逐行展示距离当前日期最近的三个倒数日事项。
    case countdownMediumRecentList
    
    /// 倒数日·中·最近（网格）：以两列两行的网格展示距离当前日期最近的四个倒数日事项。
    case countdownMediumRecentGrid
    
    /// 倒数日·中·最近（三列）：以一行三列的竖排卡片展示距离当前日期最近的三个倒数日事项。
    case countdownMediumRecentColumns
    
    /// 倒数日·大·最近（列表）：逐行展示距离当前日期最近的五个倒数日事项。
    case countdownLargeRecentList
    
    /// 倒数日·大·最近（网格）：以两列四行的网格展示距离当前日期最近的八个倒数日事项。
    case countdownLargeRecentGrid
}

// MARK: - 固有属性

public extension WSPluginType {

    /// 该组件固定的尺寸。
    var size: WSPluginSize {
        switch self {
        case .countdownSmallSelected, .countdownSmallRecent:
            return .small
        case .countdownMediumRecentList, .countdownMediumRecentGrid, .countdownMediumRecentColumns:
            return .medium
        case .countdownLargeRecentList, .countdownLargeRecentGrid:
            return .large
        }
    }

    /// 所属模块。用于组件选择器分组，以及同模块三个尺寸之间的归类。
    var module: WSPluginModule {
        switch self {
        case .countdownSmallSelected, .countdownSmallRecent,
             .countdownMediumRecentList, .countdownMediumRecentGrid, .countdownMediumRecentColumns,
             .countdownLargeRecentList, .countdownLargeRecentGrid:
            return .countdown
        }
    }

    /// 组件标题
    var title: String {
        switch self {
        case .countdownSmallSelected:
            return resGetString("Selected Countdown")
        case .countdownSmallRecent, .countdownMediumRecentList, .countdownMediumRecentGrid,
             .countdownMediumRecentColumns, .countdownLargeRecentList, .countdownLargeRecentGrid:
            return resGetString("Recent Countdowns")
        }
    }

    /// 组件描述。画廊等入口作为副标题展示，一句话说明展示内容。
    var subtitle: String {
        switch self {
        case .countdownSmallSelected:
            return resGetString("Shows the selected countdown")
        case .countdownMediumRecentList, .countdownLargeRecentList:
            return resGetString("Shows the most recent countdowns in a list")
        case .countdownMediumRecentGrid, .countdownLargeRecentGrid:
            return resGetString("Shows the most recent countdowns in a grid")
        case .countdownMediumRecentColumns:
            return resGetString("Shows the most recent countdowns in columns")
        case .countdownSmallRecent:
            return resGetString("Shows the most recent countdowns")
        }
    }
}
