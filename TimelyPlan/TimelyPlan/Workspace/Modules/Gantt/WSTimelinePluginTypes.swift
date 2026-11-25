import Foundation

extension WSPluginType {

    /// 时间线模块的组件类型。
    enum Timeline {

        /// 时间线·大·按天甘特图：以甘特时间线按天展示事项排期。
        static let largeDayChart = make("timelineLargeDayChart", .large)

        /// 时间线·大·按周甘特图：以甘特时间线按周展示事项排期。
        static let largeWeekChart = make("timelineLargeWeekChart", .large)

        /// 时间线·大·按月甘特图：以甘特时间线按月展示事项排期。
        static let largeMonthChart = make("timelineLargeMonthChart", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            largeDayChart, largeWeekChart, largeMonthChart,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSTimelineLargeDayChartPluginProvider(), title: "Daily Gantt", subtitle: "Shows tasks on a timeline by day"),
            .init(WSTimelineLargeWeekChartPluginProvider(), title: "Weekly Gantt", subtitle: "Shows tasks on a timeline by week"),
            .init(WSTimelineLargeMonthChartPluginProvider(), title: "Monthly Gantt", subtitle: "Shows tasks on a timeline by month"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .timeline, size: size)
        }
    }
}
