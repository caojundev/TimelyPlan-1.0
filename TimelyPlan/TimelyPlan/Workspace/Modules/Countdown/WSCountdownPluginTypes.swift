import Foundation

extension WSPluginType {

    /// 倒数日模块的组件类型。
    enum Countdown {

        /// 倒数日·小·自选：展示用户自己选择的一个倒数日事件。
        static let smallSelected = make("countdownSmallSelected", .small)

        /// 倒数日·小·事项：展示最近或用户自选的两个倒数日事项。
        static let smallEvents = make("countdownSmallEvents", .small)

        /// 倒数日·中·事项（列表）：逐行展示最近或用户自选的三个倒数日事项。
        static let mediumEventsList = make("countdownMediumEventsList", .medium)

        /// 倒数日·中·事项（网格）：以两列两行的网格展示最近或用户自选的四个倒数日事项。
        static let mediumEventsGrid = make("countdownMediumEventsGrid", .medium)

        /// 倒数日·中·事项（三列）：以一行三列的竖排卡片展示最近或用户自选的三个倒数日事项。
        static let mediumEventsColumns = make("countdownMediumEventsColumns", .medium)

        /// 倒数日·大·事项（列表）：逐行展示最近或用户自选的五个倒数日事项。
        static let largeEventsList = make("countdownLargeEventsList", .large)

        /// 倒数日·大·事项（网格）：以两列四行的网格展示最近或用户自选的八个倒数日事项。
        static let largeEventsGrid = make("countdownLargeEventsGrid", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallSelected, smallEvents,
            mediumEventsList, mediumEventsGrid, mediumEventsColumns,
            largeEventsList, largeEventsGrid,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSCountdownSmallSelectedPluginProvider(), title: "Selected Countdown", subtitle: "Shows the selected countdown"),
            .init(WSCountdownSmallEventsPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns"),
            .init(WSCountdownMediumEventsListPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in a list"),
            .init(WSCountdownMediumEventsGridPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in a grid"),
            .init(WSCountdownMediumEventsColumnsPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in columns"),
            .init(WSCountdownLargeEventsListPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in a list"),
            .init(WSCountdownLargeEventsGridPluginProvider(), title: "Countdowns", subtitle: "Shows recent or selected countdowns in a grid"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .countdown, size: size)
        }
    }
}
