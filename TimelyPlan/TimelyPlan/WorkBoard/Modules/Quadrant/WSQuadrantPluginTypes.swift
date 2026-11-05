import Foundation

extension WSPluginType {

    /// 四象限模块的组件类型。
    enum Quadrant {

        /// 四象限·小·数量：以两列网格展示四个象限的未完成任务数。
        static let smallCounts = make("quadrantSmallCounts", .small)

        /// 四象限·小·圆环：以环形展示四个象限未完成任务的占比。
        static let smallDonut = make("quadrantSmallDonut", .small)

        /// 四象限·小·比例条：以圆角堆叠比例条展示四个象限未完成任务的占比。
        static let smallStackedBar = make("quadrantSmallStackedBar", .small)

        /// 四象限·小·任务列表：展示配置中选择的一个象限的未完成任务。
        static let smallTaskList = make("quadrantSmallTaskList", .small)

        /// 四象限·中·数量：以一行四列横向展示四个象限的未完成任务数。
        static let mediumCounts = make("quadrantMediumCounts", .medium)

        /// 四象限·中·圆环：左侧以环形展示占比，右侧以列表展示各象限的未完成任务数。
        static let mediumDonut = make("quadrantMediumDonut", .medium)

        /// 四象限·中·比例条：以圆角堆叠比例条展示占比，并以网格列出各象限详情。
        static let mediumStackedBar = make("quadrantMediumStackedBar", .medium)

        /// 四象限·中·任务列表：展示配置中选择的一个象限的未完成任务。
        static let mediumTaskList = make("quadrantMediumTaskList", .medium)

        /// 四象限·大·任务：以两列两行的网格展示四个象限的未完成任务列表。
        static let largeTasks = make("quadrantLargeTasks", .large)

        /// 四象限·大·任务列表：展示配置中选择的一个象限的未完成任务。
        static let largeTaskList = make("quadrantLargeTaskList", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallCounts, smallDonut, smallStackedBar, smallTaskList,
            mediumCounts, mediumDonut, mediumStackedBar, mediumTaskList,
            largeTasks, largeTaskList,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSQuadrantSmallCountsPluginProvider(), title: "Quadrants", subtitle: "Shows the number of unfinished tasks in each quadrant"),
            .init(WSQuadrantSmallDonutPluginProvider(), title: "Quadrant Ring", subtitle: "Shows the share of unfinished tasks in a ring"),
            .init(WSQuadrantSmallStackedBarPluginProvider(), title: "Quadrant Bar", subtitle: "Shows the share of unfinished tasks as a stacked bar"),
            .init(WSQuadrantSmallTaskListPluginProvider(), title: "Quadrant Tasks", subtitle: "Shows unfinished tasks in a selected quadrant"),
            .init(WSQuadrantMediumCountsPluginProvider(), title: "Quadrants", subtitle: "Shows the number of unfinished tasks in each quadrant in a row"),
            .init(WSQuadrantMediumDonutPluginProvider(), title: "Quadrant Ring", subtitle: "Shows the share of unfinished tasks in a ring with a list"),
            .init(WSQuadrantMediumStackedBarPluginProvider(), title: "Quadrant Bar", subtitle: "Shows the share of unfinished tasks as a stacked bar with details"),
            .init(WSQuadrantMediumTaskListPluginProvider(), title: "Quadrant Tasks", subtitle: "Shows unfinished tasks in a selected quadrant"),
            .init(WSQuadrantTasksPluginProvider(), title: "Quadrants", subtitle: "Shows unfinished tasks in each quadrant"),
            .init(WSQuadrantLargeTaskListPluginProvider(), title: "Quadrant Tasks", subtitle: "Shows unfinished tasks in a selected quadrant"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .quadrants, size: size)
        }
    }
}
