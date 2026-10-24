
import Foundation

/// 组件类型。
///
/// 命名规则：模块 + 尺寸 + 内容。尺寸之后的词语说明该组件展示什么，
/// 用于区分同模块、同尺寸下的多种组件。
public enum WSPluginType: String, Codable, CaseIterable {
    
    // MARK: 倒数日
    /// 倒数日·小·自选：展示用户自己选择的一个倒数日事件。
    case countdownSmallSelected
    
    /// 倒数日·小·事项：展示最近或用户自选的两个倒数日事项。
    case countdownSmallEvents
    
    /// 倒数日·中·事项（列表）：逐行展示最近或用户自选的三个倒数日事项。
    case countdownMediumEventsList
    
    /// 倒数日·中·事项（网格）：以两列两行的网格展示最近或用户自选的四个倒数日事项。
    case countdownMediumEventsGrid
    
    /// 倒数日·中·事项（三列）：以一行三列的竖排卡片展示最近或用户自选的三个倒数日事项。
    case countdownMediumEventsColumns
    
    /// 倒数日·大·事项（列表）：逐行展示最近或用户自选的五个倒数日事项。
    case countdownLargeEventsList
    
    /// 倒数日·大·事项（网格）：以两列四行的网格展示最近或用户自选的八个倒数日事项。
    case countdownLargeEventsGrid
    
    // MARK: 专注
    /// 专注·小·番茄钟：展示番茄钟专注状态的入口。
    case focusSmallPomodoro
    
    /// 专注·小·倒计时：展示倒计时专注状态的入口。
    case focusSmallCountdown
    
    /// 专注·小·默认计时器：展示默认的系统计时器。
    case focusSmallSystemTimer
    
    /// 专注·中·默认计时器：以三列展示默认的系统计时器。
    case focusMediumSystemTimer
}

// MARK: - 固有属性

public extension WSPluginType {

    /// 该组件固定的尺寸。
    var size: WSPluginSize {
        switch self {
        case .countdownSmallSelected, .countdownSmallEvents,
             .focusSmallPomodoro, .focusSmallCountdown, .focusSmallSystemTimer:
            return .small
        case .countdownMediumEventsList, .countdownMediumEventsGrid, .countdownMediumEventsColumns,
             .focusMediumSystemTimer:
            return .medium
        case .countdownLargeEventsList, .countdownLargeEventsGrid:
            return .large
        }
    }

    /// 所属模块。用于组件选择器分组，以及同模块三个尺寸之间的归类。
    var module: WSPluginModule {
        switch self {
        case .countdownSmallSelected, .countdownSmallEvents,
             .countdownMediumEventsList, .countdownMediumEventsGrid, .countdownMediumEventsColumns,
             .countdownLargeEventsList, .countdownLargeEventsGrid:
            return .countdown
        case .focusSmallPomodoro, .focusSmallCountdown, .focusSmallSystemTimer,
             .focusMediumSystemTimer:
            return .focus
        }
    }

    /// 组件标题
    var title: String {
        switch self {
        case .countdownSmallSelected:
            return resGetString("Selected Countdown")
        case .countdownSmallEvents, .countdownMediumEventsList, .countdownMediumEventsGrid,
             .countdownMediumEventsColumns, .countdownLargeEventsList, .countdownLargeEventsGrid:
            return resGetString("Countdowns")
        case .focusSmallPomodoro:
            return resGetString("Pomodoro")
        case .focusSmallCountdown:
            return resGetString("Countdown Timer")
        case .focusSmallSystemTimer, .focusMediumSystemTimer:
            return resGetString("Default Timer")
        }
    }

    /// 组件描述。画廊等入口作为副标题展示，一句话说明展示内容。
    var subtitle: String {
        switch self {
        case .countdownSmallSelected:
            return resGetString("Shows the selected countdown")
        case .countdownMediumEventsList, .countdownLargeEventsList:
            return resGetString("Shows recent or selected countdowns in a list")
        case .countdownMediumEventsGrid, .countdownLargeEventsGrid:
            return resGetString("Shows recent or selected countdowns in a grid")
        case .countdownMediumEventsColumns:
            return resGetString("Shows recent or selected countdowns in columns")
        case .countdownSmallEvents:
            return resGetString("Shows recent or selected countdowns")
            
        case .focusSmallPomodoro:
            return resGetString("Quickly starts the default pomodoro")
        case .focusSmallCountdown:
            return resGetString("Quickly starts the default countdown")
        case .focusSmallSystemTimer:
            return resGetString("Quickly starts the default timer")
        case .focusMediumSystemTimer:
            return resGetString("Shows the default timers in columns")
        }
    }
}
