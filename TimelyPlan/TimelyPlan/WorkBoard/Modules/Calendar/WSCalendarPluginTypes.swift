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

        /// 日历·小·单月历：整月网格，日期下方用小圆点展示当天事项。
        static let smallMonth = make("calendarSmallMonth", .small)

        /// 日历·中·双月历：本月与下月左右排列，每月占据一半宽度。
        static let mediumMonth = make("calendarMediumMonth", .medium)

        /// 日历·中·月历与事项列表：左侧本月月历，右侧本月的事项列表。
        static let mediumMonthEventList = make("calendarMediumMonthEventList", .medium)

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

        /// 日历·中·事项条（2 天）：展示今天起 2 天的事项条。
        static let mediumEventBar2Days = make("calendarMediumEventBar2Days", .medium)

        /// 日历·中·事项条（3 天）：展示今天起 3 天的事项条。
        static let mediumEventBar3Days = make("calendarMediumEventBar3Days", .medium)

        /// 日历·中·事项条（4 天）：展示今天起 4 天的事项条。
        static let mediumEventBar4Days = make("calendarMediumEventBar4Days", .medium)

        /// 日历·中·事项条（5 天）：展示今天起 5 天的事项条。
        static let mediumEventBar5Days = make("calendarMediumEventBar5Days", .medium)

        /// 日历·中·事项条（本周）：展示今天所在那一周的事项条。
        static let mediumEventBarWeek = make("calendarMediumEventBarWeek", .medium)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallClassicDate, smallMinimalDate, smallCount, smallMonth,
            mediumMonth, mediumMonthEventList,
            smallUpcoming, mediumUpcoming, largeUpcoming,
            mediumTwoDays, largeTwoDays,
            mediumEventBar2Days, mediumEventBar3Days, mediumEventBar4Days, mediumEventBar5Days,
            mediumEventBarWeek,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSCalendarSmallClassicDatePluginProvider(), title: "Classic Date", subtitle: "Shows today's date with a red month banner"),
            .init(WSCalendarSmallMinimalDatePluginProvider(), title: "Minimal Date", subtitle: "Shows today's date in a minimal layout"),
            .init(WSCalendarSmallCountPluginProvider(), title: "Today Count", subtitle: "Shows today's date with the number of events"),
            .init(WSCalendarSingleMonthPluginProvider(), title: "Month Calendar", subtitle: "Shows this month's calendar with event dots"),
            .init(WSCalendarDoubleMonthPluginProvider(), title: "Two Months", subtitle: "Shows this month and next month side by side"),
            .init(WSCalendarMediumMonthEventListPluginProvider(), title: "Month & Events", subtitle: "Shows this month's calendar with its events"),
            .init(WSCalendarSmallUpcomingPluginProvider(), title: "Upcoming Events", subtitle: "Lists upcoming events grouped by day"),
            .init(WSCalendarMediumUpcomingPluginProvider(), title: "Upcoming Events", subtitle: "Lists upcoming events grouped by day with their source"),
            .init(WSCalendarLargeUpcomingPluginProvider(), title: "Upcoming Events", subtitle: "Lists upcoming events grouped by day with their source"),
            .init(WSCalendarMediumTwoDaysPluginProvider(), title: "Today & Tomorrow", subtitle: "Shows events for today and tomorrow"),
            .init(WSCalendarLargeTwoDaysPluginProvider(), title: "Today & Tomorrow", subtitle: "Shows events for today and tomorrow"),
            .init(WSCalendarMediumEventBar2DaysPluginProvider(), title: "Next 2 Days", subtitle: "Shows the next 2 days of events as bars"),
            .init(WSCalendarMediumEventBar3DaysPluginProvider(), title: "Next 3 Days", subtitle: "Shows the next 3 days of events as bars"),
            .init(WSCalendarMediumEventBar4DaysPluginProvider(), title: "Next 4 Days", subtitle: "Shows the next 4 days of events as bars"),
            .init(WSCalendarMediumEventBar5DaysPluginProvider(), title: "Next 5 Days", subtitle: "Shows the next 5 days of events as bars"),
            .init(WSCalendarMediumEventBarWeekPluginProvider(), title: "This Week", subtitle: "Shows this week's events as bars"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .calendar, size: size)
        }
    }
}
