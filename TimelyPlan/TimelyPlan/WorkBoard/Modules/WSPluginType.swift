
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
    /// 专注·小·默认计时器：展示默认的系统计时器。
    case focusSmallSystemTimer
    
    /// 专注·中·默认计时器：以三列展示默认的系统计时器。
    case focusMediumSystemTimer
    
    /// 专注·小·用户计时器：展示用户自选的计时器。
    case focusSmallUserTimer
    
    /// 专注·中·用户计时器（列表）：纵向展示用户自选的计时器。
    case focusMediumUserTimerList
    
    /// 专注·中·用户计时器（网格）：以两列网格展示用户自选的计时器。
    case focusMediumUserTimerGrid
    
    /// 专注·大·用户计时器（列表）：纵向展示用户自选的计时器。
    case focusLargeUserTimerList
    
    /// 专注·大·用户计时器（网格）：以两列网格展示用户自选的计时器。
    case focusLargeUserTimerGrid
    
    /// 专注·小·今日活动：展示今日专注时长与每小时活动分布。
    case focusSmallTodayActivity
    
    /// 专注·小·今日对比：展示今日时长、与昨日的增减以及昨日时长。
    case focusSmallTodayComparison
    
    /// 专注·小·本周活动：展示本周专注时长与每天的活动分布。
    case focusSmallWeekActivity

    /// 专注·小·本月热力图：展示本月专注时长与每天的热力分布。
    case focusSmallMonthHeatMap
    
    // MARK: 习惯
    /// 习惯·小·自选：展示用户选择的一个习惯任务。
    case habitSmallSelected
    
    /// 习惯·小·任务：逐行展示今日排期的习惯任务。
    case habitSmallTasks
    
    /// 习惯·小·任务网格：以两列两行的图标展示今日排期的习惯任务。
    case habitSmallTasksGrid
    
    /// 习惯·小·最近三天：展示所选习惯最近三天的状态与进度。
    case habitSmallRecent
    
    /// 习惯·小·月报告：以热力图展示所选习惯本月的完成情况。
    case habitSmallMonthReport
    
    /// 习惯·中·任务列表：以列表展示今日排期的习惯任务。
    case habitMediumTasksList
    
    /// 习惯·中·任务网格：以网格卡片展示今日排期的习惯任务。
    case habitMediumTasksGrid
    
    /// 习惯·中·周进度：展示今日首个习惯本周七天的状态与进度。
    case habitMediumWeek
    
    /// 习惯·中·周报告列表：逐行展示今日排期习惯本周的完成情况。
    case habitMediumWeekReportList
    
    /// 习惯·中·本月活动列表：逐行展示今日排期习惯本月每天的活动。
    case habitMediumMonthActivityList
    
    /// 习惯·大·任务列表：以列表展示今日排期的习惯任务。
    case habitLargeTasksList
    
    /// 习惯·大·任务网格：以网格卡片展示今日排期的习惯任务。
    case habitLargeTasksGrid
    
    /// 习惯·大·周报告列表：逐行展示今日排期习惯本周的完成情况。
    case habitLargeWeekReportList
    
    /// 习惯·大·本月活动列表：逐行展示今日排期习惯本月每天的活动。
    case habitLargeMonthActivityList
    
    // MARK: 目标
    /// 目标·小·自选：展示用户选择的一个目标计划。
    case goalSmallSelected
    
    /// 目标·小·收件箱：展示收件箱中的任务数目。
    case goalSmallInbox
    
    /// 目标·小·计划列表：逐行展示进行中的目标计划。
    case goalSmallPlanList
    
}

// MARK: - 固有属性

public extension WSPluginType {

    /// 该组件固定的尺寸。
    var size: WSPluginSize {
        switch self {
        case .countdownSmallSelected, .countdownSmallEvents,
             .focusSmallUserTimer, .focusSmallSystemTimer, .focusSmallTodayActivity,
             .focusSmallTodayComparison, .focusSmallWeekActivity, .focusSmallMonthHeatMap,
             .habitSmallSelected, .habitSmallTasks, .habitSmallTasksGrid, .habitSmallRecent,
             .habitSmallMonthReport,
             .goalSmallSelected, .goalSmallInbox, .goalSmallPlanList:
            return .small
        case .countdownMediumEventsList, .countdownMediumEventsGrid, .countdownMediumEventsColumns,
             .focusMediumUserTimerList, .focusMediumUserTimerGrid, .focusMediumSystemTimer,
             .habitMediumTasksList, .habitMediumTasksGrid, .habitMediumWeek,
             .habitMediumWeekReportList, .habitMediumMonthActivityList:
            return .medium
        case .countdownLargeEventsList, .countdownLargeEventsGrid, .focusLargeUserTimerList,
             .focusLargeUserTimerGrid,
             .habitLargeTasksList, .habitLargeTasksGrid, .habitLargeWeekReportList,
             .habitLargeMonthActivityList:
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
        case .focusSmallUserTimer, .focusMediumUserTimerList, .focusMediumUserTimerGrid,
             .focusLargeUserTimerList, .focusLargeUserTimerGrid,
             .focusSmallSystemTimer, .focusMediumSystemTimer, .focusSmallTodayActivity,
             .focusSmallTodayComparison, .focusSmallWeekActivity, .focusSmallMonthHeatMap:
            return .focus
        case .habitSmallSelected, .habitSmallTasks, .habitSmallTasksGrid, .habitSmallRecent,
             .habitSmallMonthReport,
             .habitMediumTasksList, .habitMediumTasksGrid, .habitMediumWeek,
             .habitMediumWeekReportList, .habitMediumMonthActivityList,
             .habitLargeTasksList, .habitLargeTasksGrid, .habitLargeWeekReportList,
             .habitLargeMonthActivityList:
            return .habit
        case .goalSmallSelected, .goalSmallInbox, .goalSmallPlanList:
            return .goal
        }
    }

    /// 组件标题，取自组件清单
    var title: String {
        return WSPluginCatalog.configuration(for: self)?.title ?? rawValue
    }

    /// 组件描述，取自组件清单。画廊等入口作为副标题展示，一句话说明展示内容。
    var subtitle: String {
        return WSPluginCatalog.configuration(for: self)?.subtitle ?? ""
    }
}

// MARK: - 组件配置

/// 单个组件的配置。
///
/// 组件类型取自提供者，标题与描述只存本地化 key，展示时再取值。
struct WSPluginConfiguration {

    /// 组件提供者
    let provider: WSPluginProvider

    /// 标题本地化 key
    let titleKey: String

    /// 描述本地化 key
    let subtitleKey: String

    /// 组件类型
    var type: WSPluginType {
        return provider.type
    }

    /// 组件标题
    var title: String {
        return resGetString(titleKey)
    }

    /// 组件描述
    var subtitle: String {
        return resGetString(subtitleKey)
    }

    init(_ provider: WSPluginProvider, title titleKey: String, subtitle subtitleKey: String) {
        self.provider = provider
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
    }
}

/// 组件清单。
///
/// 新增组件时只需在 `all` 中追加一行配置，组件注册与选择器、画廊的文案会自动生效；
/// 尺寸与模块属于组件固有属性，仍需在 `WSPluginType` 中归类。
enum WSPluginCatalog {

    /// 全部组件配置
    static let all: [WSPluginConfiguration] = [
        // 倒数日
        .init(WSCountdownSmallSelectedPluginProvider(), title: "Selected Countdown", subtitle: "Shows the selected countdown"),
        .init(WSCountdownSmallEventsPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns"),
        .init(WSCountdownMediumEventsListPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in a list"),
        .init(WSCountdownMediumEventsGridPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in a grid"),
        .init(WSCountdownMediumEventsColumnsPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in columns"),
        .init(WSCountdownLargeEventsListPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in a list"),
        .init(WSCountdownLargeEventsGridPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in a grid"),
        
        // 专注
        .init(WSFocusSmallUserTimerPluginProvider(), title: "Custom Timers", subtitle: "Shows selected custom timers"),
        .init(WSFocusMediumUserTimerListPluginProvider(), title: "Custom Timers", subtitle: "Shows selected custom timers in a list"),
        .init(WSFocusMediumUserTimerGridPluginProvider(), title: "Custom Timers", subtitle: "Shows selected custom timers in a grid"),
        .init(WSFocusLargeUserTimerListPluginProvider(), title: "Custom Timers", subtitle: "Shows selected custom timers in a list"),
        .init(WSFocusLargeUserTimerGridPluginProvider(), title: "Custom Timers", subtitle: "Shows selected custom timers in a grid"),
        .init(WSFocusSmallSystemTimerPluginProvider(), title: "Default Timer", subtitle: "Quickly starts the default timer"),
        .init(WSFocusMediumSystemTimerPluginProvider(), title: "Default Timer", subtitle: "Shows the default timers in columns"),
        .init(WSFocusSmallTodayActivityPluginProvider(), title: "Today's Focus", subtitle: "Shows today's focus duration and hourly activity"),
        .init(WSFocusSmallTodayComparisonPluginProvider(), title: "Focus Comparison", subtitle: "Compares today's focus time with yesterday"),
        .init(WSFocusSmallWeekActivityPluginProvider(), title: "Week's Focus", subtitle: "Shows this week's focus duration and daily activity"),
        .init(WSFocusSmallMonthHeatMapPluginProvider(), title: "Month Heatmap", subtitle: "Shows this month's focus heatmap"),
        
        // 习惯
        .init(WSHabitSmallSelectedPluginProvider(), title: "Selected Habit", subtitle: "Shows the selected habit"),
        .init(WSHabitSmallTasksListPluginProvider(), title: "Habits", subtitle: "Shows today's habits and progress"),
        .init(WSHabitSmallTasksGridPluginProvider(), title: "Habits", subtitle: "Shows today's habits in a grid"),
        .init(WSHabitMediumTasksListPluginProvider(), title: "Habits", subtitle: "Shows today's habits in a list"),
        .init(WSHabitMediumTasksGridPluginProvider(), title: "Habits", subtitle: "Shows today's habits in a grid"),
        .init(WSHabitWeekPluginProvider(), title: "Habit Week", subtitle: "Shows this week's progress of a habit"),
        .init(WSHabitRecentPluginProvider(), title: "Recent Days", subtitle: "Shows the last 3 days of a habit"),
        .init(WSHabitSmallMonthReportPluginProvider(), title: "Month Report", subtitle: "Shows this month's progress of a habit"),
        .init(WSHabitMediumWeekReportListPluginProvider(), title: "Weekly Report", subtitle: "Shows this week's progress of habits"),
        .init(WSHabitMediumMonthActivityListPluginProvider(), title: "Monthly Activity", subtitle: "Shows this month's activity of habits"),
        .init(WSHabitLargeTasksListPluginProvider(), title: "Habits", subtitle: "Shows today's habits in a list"),
        .init(WSHabitLargeTasksGridPluginProvider(), title: "Habits", subtitle: "Shows today's habits in a grid"),
        .init(WSHabitLargeWeekReportListPluginProvider(), title: "Weekly Report", subtitle: "Shows this week's progress of habits"),
        .init(WSHabitLargeMonthActivityListPluginProvider(), title: "Monthly Activity", subtitle: "Shows this month's activity of habits"),
        
        // 目标
        .init(WSGoalPlanSmallSelectedPluginProvider(), title: "Selected Goal", subtitle: "Shows the selected goal"),
        .init(WSGoalPlanSmallInboxPluginProvider(), title: "Inbox", subtitle: "Shows the number of inbox tasks"),
        .init(WSGoalPlanSmallPlanListPluginProvider(), title: "Goals", subtitle: "Shows active goals in a list"),
    ]

    /// 按类型取回组件配置
    static func configuration(for type: WSPluginType) -> WSPluginConfiguration? {
        return configurations[type]
    }

    /// 类型索引，避免每次按类型查找都遍历数组
    private static let configurations: [WSPluginType: WSPluginConfiguration] = {
        return Dictionary(all.map { ($0.type, $0) }, uniquingKeysWith: { first, _ in first })
    }()
}
