import Foundation

extension WSPluginType {

    /// 日历模块的组件类型。
    enum Calendar {

        /// 日历·小·经典日期：红色月份抬头，日期与星期居中。
        static let smallClassicDate = make("calendarSmallClassicDate", .small)

        /// 日历·小·极简日期：月份与星期靠上左对齐，日期左对齐放大。
        static let smallMinimalDate = make("calendarSmallMinimalDate", .small)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallClassicDate, smallMinimalDate,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSCalendarSmallClassicDatePluginProvider(), title: "Classic Date", subtitle: "Shows today's date with a red month banner"),
            .init(WSCalendarSmallMinimalDatePluginProvider(), title: "Minimal Date", subtitle: "Shows today's date in a minimal layout"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .calendar, size: size)
        }
    }
}
