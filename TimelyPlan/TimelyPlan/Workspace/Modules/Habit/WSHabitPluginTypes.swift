import Foundation

extension WSPluginType {

    /// 习惯模块的组件类型。
    enum Habit {

        /// 习惯·小·自选：展示用户选择的一个习惯任务。
        static let smallSelected = make("habitSmallSelected", .small)

        /// 习惯·小·任务：逐行展示今日排期的习惯任务。
        static let smallTasks = make("habitSmallTasks", .small)

        /// 习惯·小·任务网格：以两列两行的图标展示今日排期的习惯任务。
        static let smallTasksGrid = make("habitSmallTasksGrid", .small)

        /// 习惯·小·最近三天：展示所选习惯最近三天的状态与进度。
        static let smallRecent = make("habitSmallRecent", .small)

        /// 习惯·小·月报告：以热力图展示所选习惯本月的完成情况。
        static let smallMonthReport = make("habitSmallMonthReport", .small)

        /// 习惯·中·任务列表：以列表展示今日排期的习惯任务。
        static let mediumTasksList = make("habitMediumTasksList", .medium)

        /// 习惯·中·任务网格：以网格卡片展示今日排期的习惯任务。
        static let mediumTasksGrid = make("habitMediumTasksGrid", .medium)

        /// 习惯·中·周进度：展示今日首个习惯本周七天的状态与进度。
        static let mediumWeek = make("habitMediumWeek", .medium)

        /// 习惯·中·周报告列表：逐行展示今日排期习惯本周的完成情况。
        static let mediumWeekReportList = make("habitMediumWeekReportList", .medium)

        /// 习惯·中·本月活动列表：逐行展示今日排期习惯本月每天的活动。
        static let mediumMonthActivityList = make("habitMediumMonthActivityList", .medium)

        /// 习惯·大·任务列表：以列表展示今日排期的习惯任务。
        static let largeTasksList = make("habitLargeTasksList", .large)

        /// 习惯·大·任务网格：以网格卡片展示今日排期的习惯任务。
        static let largeTasksGrid = make("habitLargeTasksGrid", .large)

        /// 习惯·大·周报告列表：逐行展示今日排期习惯本周的完成情况。
        static let largeWeekReportList = make("habitLargeWeekReportList", .large)

        /// 习惯·大·本月活动列表：逐行展示今日排期习惯本月每天的活动。
        static let largeMonthActivityList = make("habitLargeMonthActivityList", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallSelected, smallTasks, smallTasksGrid, smallRecent, smallMonthReport,
            mediumTasksList, mediumTasksGrid, mediumWeek, mediumWeekReportList, mediumMonthActivityList,
            largeTasksList, largeTasksGrid, largeWeekReportList, largeMonthActivityList,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
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
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .habit, size: size)
        }
    }
}
