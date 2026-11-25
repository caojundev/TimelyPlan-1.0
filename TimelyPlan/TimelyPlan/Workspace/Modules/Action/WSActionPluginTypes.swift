import Foundation

extension WSPluginType {

    /// 动作模块的组件类型。
    enum Action {

        /// 动作·小·列表：逐行展示用户自定义的添加与跳转动作。
        static let smallList = make("actionSmallList", .small)

        /// 动作·中·列表：逐行展示用户自定义的添加与跳转动作。
        static let mediumList = make("actionMediumList", .medium)

        /// 动作·中·网格：以两列网格展示用户自定义的添加与跳转动作。
        static let mediumGrid = make("actionMediumGrid", .medium)

        /// 动作·大·列表：逐行展示用户自定义的添加与跳转动作。
        static let largeList = make("actionLargeList", .large)

        /// 动作·大·网格：以两列网格展示用户自定义的添加与跳转动作。
        static let largeGrid = make("actionLargeGrid", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallList,
            mediumList, mediumGrid,
            largeList, largeGrid,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSActionSmallListPluginProvider(), title: "Actions", subtitle: "Shows custom actions"),
            .init(WSActionMediumListPluginProvider(), title: "Actions", subtitle: "Shows custom actions in a list"),
            .init(WSActionMediumGridPluginProvider(), title: "Actions", subtitle: "Shows custom actions in a grid"),
            .init(WSActionLargeListPluginProvider(), title: "Actions", subtitle: "Shows custom actions in a list"),
            .init(WSActionLargeGridPluginProvider(), title: "Actions", subtitle: "Shows custom actions in a grid"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .action, size: size)
        }
    }
}
