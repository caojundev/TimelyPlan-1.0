import Foundation

// 待办组件较多，按清单、清单任务、标签、过滤器、任务拆成五个模块，各自对应一个 `WSPluginModule`。

extension WSPluginType {

    /// 待办清单模块的组件类型。
    enum TodoList {

        /// 待办·小·清单列表：逐行展示待办清单。
        static let smallList = make("todoSmallList", .small)

        /// 待办·中·清单列表：逐行展示待办清单。
        static let mediumList = make("todoMediumList", .medium)

        /// 待办·大·清单列表：逐行展示待办清单。
        static let largeList = make("todoLargeList", .large)

        /// 待办·中·清单网格：以两列网格展示待办清单。
        static let mediumGrid = make("todoMediumGrid", .medium)

        /// 待办·大·清单网格：以两列网格展示待办清单。
        static let largeGrid = make("todoLargeGrid", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallList, mediumList, largeList, mediumGrid, largeGrid,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSTodoListSmallListPluginProvider(), title: "Lists", subtitle: "Shows todo lists in a list"),
            .init(WSTodoListMediumListPluginProvider(), title: "Lists", subtitle: "Shows todo lists in a list"),
            .init(WSTodoListLargeListPluginProvider(), title: "Lists", subtitle: "Shows todo lists in a list"),
            .init(WSTodoListMediumGridPluginProvider(), title: "Lists", subtitle: "Shows todo lists in a grid"),
            .init(WSTodoListLargeGridPluginProvider(), title: "Lists", subtitle: "Shows todo lists in a grid"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .todoList, size: size)
        }
    }

    /// 待办清单任务模块的组件类型。
    enum TodoListTask {

        /// 待办·小·自选清单任务列表：展示所选清单的未完成任务。
        static let smallList = make("todoSmallTasksList", .small)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallList,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSTodoListSmallTasksPluginProvider(), title: "List Tasks", subtitle: "Shows uncompleted tasks of a selected list"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .todoListTask, size: size)
        }
    }

    /// 待办标签模块的组件类型。
    enum TodoTag {

        /// 待办·小·标签列表：逐行展示待办标签。
        static let smallList = make("todoTagSmallList", .small)

        /// 待办·中·标签列表：逐行展示待办标签。
        static let mediumList = make("todoTagMediumList", .medium)

        /// 待办·大·标签列表：逐行展示待办标签。
        static let largeList = make("todoTagLargeList", .large)

        /// 待办·中·标签网格：以两列网格展示待办标签。
        static let mediumGrid = make("todoTagMediumGrid", .medium)

        /// 待办·大·标签网格：以两列网格展示待办标签。
        static let largeGrid = make("todoTagLargeGrid", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallList, mediumList, largeList, mediumGrid, largeGrid,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSTodoTagSmallListPluginProvider(), title: "Tags", subtitle: "Shows todo tags in a list"),
            .init(WSTodoTagMediumListPluginProvider(), title: "Tags", subtitle: "Shows todo tags in a list"),
            .init(WSTodoTagLargeListPluginProvider(), title: "Tags", subtitle: "Shows todo tags in a list"),
            .init(WSTodoTagMediumGridPluginProvider(), title: "Tags", subtitle: "Shows todo tags in a grid"),
            .init(WSTodoTagLargeGridPluginProvider(), title: "Tags", subtitle: "Shows todo tags in a grid"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .todoTag, size: size)
        }
    }

    /// 待办过滤器模块的组件类型。
    enum TodoFilter {

        /// 待办·小·过滤器列表：逐行展示待办过滤器。
        static let smallList = make("todoFilterSmallList", .small)

        /// 待办·中·过滤器列表：逐行展示待办过滤器。
        static let mediumList = make("todoFilterMediumList", .medium)

        /// 待办·大·过滤器列表：逐行展示待办过滤器。
        static let largeList = make("todoFilterLargeList", .large)

        /// 待办·中·过滤器网格：以两列网格展示待办过滤器。
        static let mediumGrid = make("todoFilterMediumGrid", .medium)

        /// 待办·大·过滤器网格：以两列网格展示待办过滤器。
        static let largeGrid = make("todoFilterLargeGrid", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallList, mediumList, largeList, mediumGrid, largeGrid,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSTodoFilterSmallListPluginProvider(), title: "Filters", subtitle: "Shows todo filters in a list"),
            .init(WSTodoFilterMediumListPluginProvider(), title: "Filters", subtitle: "Shows todo filters in a list"),
            .init(WSTodoFilterLargeListPluginProvider(), title: "Filters", subtitle: "Shows todo filters in a list"),
            .init(WSTodoFilterMediumGridPluginProvider(), title: "Filters", subtitle: "Shows todo filters in a grid"),
            .init(WSTodoFilterLargeGridPluginProvider(), title: "Filters", subtitle: "Shows todo filters in a grid"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .todoFilter, size: size)
        }
    }

    /// 待办任务模块的组件类型。
    enum TodoTask {

        /// 待办·小·自选任务列表：逐行展示所选待办任务。
        static let smallTaskList = make("todoTaskSmallTaskList", .small)

        /// 待办·中·自选任务列表：逐行展示所选待办任务。
        static let mediumTaskList = make("todoTaskMediumTaskList", .medium)

        /// 待办·大·自选任务列表：逐行展示所选待办任务。
        static let largeTaskList = make("todoTaskLargeTaskList", .large)

        /// 待办·中·自选任务网格：以两列网格展示所选待办任务。
        static let mediumTaskGrid = make("todoTaskMediumTaskGrid", .medium)

        /// 待办·大·自选任务网格：以两列网格展示所选待办任务。
        static let largeTaskGrid = make("todoTaskLargeTaskGrid", .large)

        /// 待办·中·今明两天：按今天、明天两列展示任务。
        static let mediumTwoDays = make("todoTaskMediumTwoDays", .medium)

        /// 待办·大·今明两天：按今天、明天两列展示任务。
        static let largeTwoDays = make("todoTaskLargeTwoDays", .large)

        /// 待办·小·接下来七天：展示从后天起七天的任务负载分布。
        static let smallNextTrends = make("todoTaskSmallNextTrends", .small)

        /// 待办·中·接下来七天：左侧展示七天任务负载，右侧展示接下来要做的任务。
        static let mediumNextTrends = make("todoTaskMediumNextTrends", .medium)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallTaskList, mediumTaskList, largeTaskList, mediumTaskGrid, largeTaskGrid,
            mediumTwoDays, largeTwoDays, smallNextTrends, mediumNextTrends,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSTodoTaskSmallTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected todo tasks in a list"),
            .init(WSTodoTaskMediumTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected todo tasks in a list"),
            .init(WSTodoTaskLargeTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected todo tasks in a list"),
            .init(WSTodoTaskMediumTaskGridPluginProvider(), title: "Tasks", subtitle: "Shows selected todo tasks in a grid"),
            .init(WSTodoTaskLargeTaskGridPluginProvider(), title: "Tasks", subtitle: "Shows selected todo tasks in a grid"),
            .init(WSTodoTaskMediumTwoDaysPluginProvider(), title: "Today & Tomorrow", subtitle: "Shows tasks for today and tomorrow"),
            .init(WSTodoTaskLargeTwoDaysPluginProvider(), title: "Today & Tomorrow", subtitle: "Shows tasks for today and tomorrow"),
            .init(WSTodoTaskSmallNextTrendsPluginProvider(), title: "Upcoming", subtitle: "Shows the task load of the next 7 days"),
            .init(WSTodoTaskMediumNextTrendsPluginProvider(), title: "Upcoming", subtitle: "Shows the next 7 days task load and upcoming tasks"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .todoTask, size: size)
        }
    }
}
