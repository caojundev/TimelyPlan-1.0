import Foundation

extension WSPluginType {

    /// 专注模块的组件类型。
    enum Focus {

        /// 专注·小·默认计时器：展示默认的系统计时器。
        static let smallSystemTimer = make("focusSmallSystemTimer", .small)

        /// 专注·中·默认计时器：以三列展示默认的系统计时器。
        static let mediumSystemTimer = make("focusMediumSystemTimer", .medium)

        /// 专注·小·用户计时器：展示用户自选的计时器。
        static let smallUserTimer = make("focusSmallUserTimer", .small)

        /// 专注·中·用户计时器（列表）：纵向展示用户自选的计时器。
        static let mediumUserTimerList = make("focusMediumUserTimerList", .medium)

        /// 专注·中·用户计时器（网格）：以两列网格展示用户自选的计时器。
        static let mediumUserTimerGrid = make("focusMediumUserTimerGrid", .medium)

        /// 专注·大·用户计时器（列表）：纵向展示用户自选的计时器。
        static let largeUserTimerList = make("focusLargeUserTimerList", .large)

        /// 专注·大·用户计时器（网格）：以两列网格展示用户自选的计时器。
        static let largeUserTimerGrid = make("focusLargeUserTimerGrid", .large)

        /// 专注·小·今日活动：展示今日专注时长与每小时活动分布。
        static let smallTodayActivity = make("focusSmallTodayActivity", .small)

        /// 专注·小·今日对比：展示今日时长、与昨日的增减以及昨日时长。
        static let smallTodayComparison = make("focusSmallTodayComparison", .small)

        /// 专注·小·本周活动：展示本周专注时长与每天的活动分布。
        static let smallWeekActivity = make("focusSmallWeekActivity", .small)

        /// 专注·小·本月热力图：展示本月专注时长与每天的热力分布。
        static let smallMonthHeatMap = make("focusSmallMonthHeatMap", .small)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallSystemTimer, mediumSystemTimer,
            smallUserTimer, mediumUserTimerList, mediumUserTimerGrid,
            largeUserTimerList, largeUserTimerGrid,
            smallTodayActivity, smallTodayComparison, smallWeekActivity, smallMonthHeatMap,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
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
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .focus, size: size)
        }
    }
}
