import Foundation

extension WSPluginType {

    /// 我的一天模块的组件类型。
    enum MyDay {

        /// 我的一天·小·全天事项：逐行展示今天的全天事项。
        static let smallAllDayEvents = make("myDaySmallAllDayEvents", .small)

        /// 我的一天·中·全天事项：以列表展示今天的全天事项。
        static let mediumAllDayEvents = make("myDayMediumAllDayEvents", .medium)

        /// 我的一天·大·全天事项：以列表展示今天的全天事项。
        static let largeAllDayEvents = make("myDayLargeAllDayEvents", .large)

        /// 我的一天·小·临近事项：展示正在进行或今天接下来即将开始的第一个事项。
        static let smallUpcoming = make("myDaySmallUpcoming", .small)

        /// 我的一天·中·时间线：以时间线展示正在进行或即将开始的事项。
        static let mediumTimeline = make("myDayMediumTimeline", .medium)

        /// 我的一天·大·时间线：以时间线展示正在进行或即将开始的事项。
        static let largeTimeline = make("myDayLargeTimeline", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallAllDayEvents, mediumAllDayEvents, largeAllDayEvents,
            smallUpcoming, mediumTimeline, largeTimeline,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSMyDaySmallAllDayEventsPluginProvider(), title: "All-Day Events", subtitle: "Shows today's all-day events"),
            .init(WSMyDayMediumAllDayEventsPluginProvider(), title: "All-Day Events", subtitle: "Shows today's all-day events in a list"),
            .init(WSMyDayLargeAllDayEventsPluginProvider(), title: "All-Day Events", subtitle: "Shows today's all-day events in a list"),
            .init(WSMyDaySmallUpcomingPluginProvider(), title: "Upcoming", subtitle: "Shows the ongoing or next event"),
            .init(WSMyDayMediumTimelinePluginProvider(), title: "Timeline", subtitle: "Shows the ongoing and upcoming events on a timeline"),
            .init(WSMyDayLargeTimelinePluginProvider(), title: "Timeline", subtitle: "Shows the ongoing and upcoming events on a timeline"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .myDay, size: size)
        }
    }
}
