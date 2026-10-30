
import Foundation

/// 组件类型。
///
/// 命名规则：模块 + 尺寸 + 内容。尺寸之后的词语说明该组件展示什么，
/// 用于区分同模块、同尺寸下的多种组件。
public enum WSPluginType: String, Codable, CaseIterable {
    
    // MARK: 时间线
    /// 时间线·大·按天甘特图：以甘特时间线按天展示事项排期。
    case timelineLargeDayChart

    /// 时间线·大·按周甘特图：以甘特时间线按周展示事项排期。
    case timelineLargeWeekChart

    /// 时间线·大·按月甘特图：以甘特时间线按月展示事项排期。
    case timelineLargeMonthChart
    
    // MARK: 四象限
    /// 四象限·小·数量：以两列网格展示四个象限的未完成任务数。
    case quadrantSmallCounts
    
    /// 四象限·小·圆环：以环形展示四个象限未完成任务的占比。
    case quadrantSmallDonut
    
    /// 四象限·小·比例条：以圆角堆叠比例条展示四个象限未完成任务的占比。
    case quadrantSmallStackedBar
    
    /// 四象限·中·数量：以一行四列横向展示四个象限的未完成任务数。
    case quadrantMediumCounts
    
    /// 四象限·中·圆环：左侧以环形展示占比，右侧以列表展示各象限的未完成任务数。
    case quadrantMediumDonut
    
    /// 四象限·中·比例条：以圆角堆叠比例条展示占比，并以网格列出各象限详情。
    case quadrantMediumStackedBar
    
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
    
    /// 目标·小·计划双环：以内环任务进度、外环时间进度展示所选目标计划。
    case goalSmallPlanRing
    
    /// 目标·小·自选任务列表：逐行展示所选目标任务。
    case goalSmallTaskList
    
    /// 目标·中·自选任务列表：逐行展示所选目标任务。
    case goalMediumTaskList
    
    /// 目标·大·自选任务列表：逐行展示所选目标任务。
    case goalLargeTaskList
    
    /// 目标·中·自选任务网格：以两列网格展示所选目标任务。
    case goalMediumTaskGrid
    
    /// 目标·大·自选任务网格：以两列网格展示所选目标任务。
    case goalLargeTaskGrid
    
    /// 目标·中·计划三环：以三个环展示所选目标计划的任务进度。
    case goalMediumPlanRings
    
    /// 目标·中·计划网格：以两列网格展示进行中的目标计划。
    case goalMediumPlanGrid
    
    /// 目标·大·计划网格：以两列网格展示进行中的目标计划。
    case goalLargePlanGrid
    
    /// 目标·中·计划列表：逐行展示进行中的目标计划。
    case goalMediumPlanList
    
    /// 目标·大·计划列表：逐行展示进行中的目标计划。
    case goalLargePlanList
    
}

// MARK: - 固有属性

public extension WSPluginType {

    /// 该组件固定的尺寸。
    var size: WSPluginSize {
        switch self {
        case .quadrantSmallCounts, .quadrantSmallDonut, .quadrantSmallStackedBar,
             .countdownSmallSelected, .countdownSmallEvents,
             .focusSmallUserTimer, .focusSmallSystemTimer, .focusSmallTodayActivity,
             .focusSmallTodayComparison, .focusSmallWeekActivity, .focusSmallMonthHeatMap,
             .habitSmallSelected, .habitSmallTasks, .habitSmallTasksGrid, .habitSmallRecent,
             .habitSmallMonthReport,
             .goalSmallSelected, .goalSmallInbox, .goalSmallPlanList, .goalSmallPlanRing,
             .goalSmallTaskList:
            return .small
        case .quadrantMediumCounts, .quadrantMediumDonut, .quadrantMediumStackedBar,
             .countdownMediumEventsList, .countdownMediumEventsGrid, .countdownMediumEventsColumns,
             .focusMediumUserTimerList, .focusMediumUserTimerGrid, .focusMediumSystemTimer,
             .habitMediumTasksList, .habitMediumTasksGrid, .habitMediumWeek,
             .habitMediumWeekReportList, .habitMediumMonthActivityList,
             .goalMediumPlanGrid, .goalMediumPlanList, .goalMediumPlanRings,
             .goalMediumTaskGrid, .goalMediumTaskList:
            return .medium
        case .timelineLargeDayChart, .timelineLargeWeekChart, .timelineLargeMonthChart,
             .countdownLargeEventsList, .countdownLargeEventsGrid, .focusLargeUserTimerList,
             .focusLargeUserTimerGrid,
             .habitLargeTasksList, .habitLargeTasksGrid, .habitLargeWeekReportList,
             .habitLargeMonthActivityList,
             .goalLargePlanGrid, .goalLargePlanList,
             .goalLargeTaskGrid, .goalLargeTaskList:
            return .large
        }
    }

    /// 所属模块。用于组件选择器分组，以及同模块三个尺寸之间的归类。
    var module: WSPluginModule {
        switch self {
        case .timelineLargeDayChart, .timelineLargeWeekChart, .timelineLargeMonthChart:
            return .timeline
        case .quadrantSmallCounts, .quadrantSmallDonut, .quadrantSmallStackedBar,
             .quadrantMediumCounts, .quadrantMediumDonut, .quadrantMediumStackedBar:
            return .quadrants
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
        case .goalSmallSelected, .goalSmallInbox, .goalSmallPlanList, .goalSmallPlanRing,
             .goalMediumPlanGrid, .goalLargePlanGrid,
             .goalMediumPlanList, .goalLargePlanList, .goalMediumPlanRings,
             .goalSmallTaskList, .goalMediumTaskList, .goalLargeTaskList,
             .goalMediumTaskGrid, .goalLargeTaskGrid:
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
        // 时间线
        .init(WSTimelineLargeDayChartPluginProvider(), title: "Daily Gantt", subtitle: "Shows tasks on a timeline by day"),
        .init(WSTimelineLargeWeekChartPluginProvider(), title: "Weekly Gantt", subtitle: "Shows tasks on a timeline by week"),
        .init(WSTimelineLargeMonthChartPluginProvider(), title: "Monthly Gantt", subtitle: "Shows tasks on a timeline by month"),
        
        // 四象限
        .init(WSQuadrantSmallCountsPluginProvider(), title: "Quadrants", subtitle: "Shows the number of unfinished tasks in each quadrant"),
        .init(WSQuadrantSmallDonutPluginProvider(), title: "Quadrant Ring", subtitle: "Shows the share of unfinished tasks in a ring"),
        .init(WSQuadrantSmallStackedBarPluginProvider(), title: "Quadrant Bar", subtitle: "Shows the share of unfinished tasks as a stacked bar"),
        .init(WSQuadrantMediumCountsPluginProvider(), title: "Quadrants", subtitle: "Shows the number of unfinished tasks in each quadrant in a row"),
        .init(WSQuadrantMediumDonutPluginProvider(), title: "Quadrant Ring", subtitle: "Shows the share of unfinished tasks in a ring with a list"),
        .init(WSQuadrantMediumStackedBarPluginProvider(), title: "Quadrant Bar", subtitle: "Shows the share of unfinished tasks as a stacked bar with details"),
        
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
        .init(WSGoalPlanSmallPlanRingPluginProvider(), title: "Goal Progress", subtitle: "Shows the selected goal's progress rings"),
        .init(WSGoalPlanMediumPlanRingsPluginProvider(), title: "Goal Rings", subtitle: "Shows progress rings of selected goals"),
        .init(WSGoalPlanMediumPlanGridPluginProvider(), title: "Goals", subtitle: "Shows active goals in a grid"),
        .init(WSGoalPlanLargePlanGridPluginProvider(), title: "Goals", subtitle: "Shows active goals in a grid"),
        .init(WSGoalPlanMediumPlanListPluginProvider(), title: "Goals", subtitle: "Shows active goals in a list"),
        .init(WSGoalPlanLargePlanListPluginProvider(), title: "Goals", subtitle: "Shows active goals in a list"),
        .init(WSGoalTaskSmallTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a list"),
        .init(WSGoalTaskMediumTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a list"),
        .init(WSGoalTaskLargeTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a list"),
        .init(WSGoalTaskMediumTaskGridPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a grid"),
        .init(WSGoalTaskLargeTaskGridPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a grid"),
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
