import Foundation

extension WSPluginType {

    /// 日历模块的组件类型。
    enum Calendar {

        /// 日历·小·经典日期：红色月份抬头，日期与星期居中。
        static let smallClassicDate = make("calendarSmallClassicDate", .small)

        /// 日历·小·极简日期：月份与星期靠上左对齐，日期左对齐放大。
        static let smallMinimalDate = make("calendarSmallMinimalDate", .small)

        /// 日历·小·今日事项数目：与极简日期一致，左下角展示今日日程数目。
        static let smallCount = make("calendarSmallCount", .small)

        /// 日历·小·最近事项：按天分组列出最近的事项，只展示时间。
        static let smallUpcoming = make("calendarSmallUpcoming", .small)

        /// 日历·中·最近事项：按天分组列出最近的事项，展示时间与来源。
        static let mediumUpcoming = make("calendarMediumUpcoming", .medium)

        /// 日历·大·最近事项：按天分组列出最近的事项，展示时间与来源。
        static let largeUpcoming = make("calendarLargeUpcoming", .large)

        /// 日历·中·今明两天：按今天、明天两列展示事项。
        static let mediumTwoDays = make("calendarMediumTwoDays", .medium)

        /// 日历·大·今明两天：按今天、明天两列展示事项。
        static let largeTwoDays = make("calendarLargeTwoDays", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallClassicDate, smallMinimalDate, smallCount,
            smallUpcoming, mediumUpcoming, largeUpcoming,
            mediumTwoDays, largeTwoDays,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSCalendarSmallClassicDatePluginProvider(), title: "Classic Date", subtitle: "Shows today's date with a red month banner"),
            .init(WSCalendarSmallMinimalDatePluginProvider(), title: "Minimal Date", subtitle: "Shows today's date in a minimal layout"),
            .init(WSCalendarSmallCountPluginProvider(), title: "Today Count", subtitle: "Shows today's date with the number of events"),
            .init(WSCalendarSmallUpcomingPluginProvider(), title: "Upcoming Events", subtitle: "Lists upcoming events grouped by day"),
            .init(WSCalendarMediumUpcomingPluginProvider(), title: "Upcoming Events", subtitle: "Lists upcoming events grouped by day with their source"),
            .init(WSCalendarLargeUpcomingPluginProvider(), title: "Upcoming Events", subtitle: "Lists upcoming events grouped by day with their source"),
            .init(WSCalendarMediumTwoDaysPluginProvider(), title: "Today & Tomorrow", subtitle: "Shows events for today and tomorrow"),
            .init(WSCalendarLargeTwoDaysPluginProvider(), title: "Today & Tomorrow", subtitle: "Shows events for today and tomorrow"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .calendar, size: size)
        }
    }
}
