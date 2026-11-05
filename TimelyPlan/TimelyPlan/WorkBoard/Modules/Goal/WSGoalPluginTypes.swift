import Foundation

extension WSPluginType {

    /// 目标模块的组件类型。
    enum Goal {

        /// 目标·小·自选：展示用户选择的一个目标计划。
        static let smallSelected = make("goalSmallSelected", .small)

        /// 目标·小·收件箱：展示收件箱中的任务数目。
        static let smallInbox = make("goalSmallInbox", .small)

        /// 目标·小·计划列表：逐行展示进行中的目标计划。
        static let smallPlanList = make("goalSmallPlanList", .small)

        /// 目标·小·计划双环：以内环任务进度、外环时间进度展示所选目标计划。
        static let smallPlanRing = make("goalSmallPlanRing", .small)

        /// 目标·小·自选任务列表：逐行展示所选目标任务。
        static let smallTaskList = make("goalSmallTaskList", .small)

        /// 目标·中·自选任务列表：逐行展示所选目标任务。
        static let mediumTaskList = make("goalMediumTaskList", .medium)

        /// 目标·大·自选任务列表：逐行展示所选目标任务。
        static let largeTaskList = make("goalLargeTaskList", .large)

        /// 目标·中·自选任务网格：以两列网格展示所选目标任务。
        static let mediumTaskGrid = make("goalMediumTaskGrid", .medium)

        /// 目标·大·自选任务网格：以两列网格展示所选目标任务。
        static let largeTaskGrid = make("goalLargeTaskGrid", .large)

        /// 目标·中·计划三环：以三个环展示所选目标计划的任务进度。
        static let mediumPlanRings = make("goalMediumPlanRings", .medium)

        /// 目标·中·计划网格：以两列网格展示进行中的目标计划。
        static let mediumPlanGrid = make("goalMediumPlanGrid", .medium)

        /// 目标·大·计划网格：以两列网格展示进行中的目标计划。
        static let largePlanGrid = make("goalLargePlanGrid", .large)

        /// 目标·中·计划列表：逐行展示进行中的目标计划。
        static let mediumPlanList = make("goalMediumPlanList", .medium)

        /// 目标·大·计划列表：逐行展示进行中的目标计划。
        static let largePlanList = make("goalLargePlanList", .large)

        /// 模块内全部类型，顺序即组件选择器的展示顺序
        static let all: [WSPluginType] = [
            smallSelected, smallInbox, smallPlanList, smallPlanRing, smallTaskList,
            mediumTaskList, largeTaskList, mediumTaskGrid, largeTaskGrid,
            mediumPlanRings, mediumPlanGrid, largePlanGrid, mediumPlanList, largePlanList,
        ]

        /// 模块内全部组件配置
        static let catalog: [WSPluginConfiguration] = [
            .init(WSGoalPlanSmallSelectedPluginProvider(), title: "Selected Goal", subtitle: "Shows the selected goal"),
            .init(WSGoalPlanSmallInboxPluginProvider(), title: "Inbox", subtitle: "Shows the number of inbox tasks"),
            .init(WSGoalPlanSmallPlanListPluginProvider(), title: "Goals", subtitle: "Shows active goals in a list"),
            .init(WSGoalPlanSmallPlanRingPluginProvider(), title: "Goal Progress", subtitle: "Shows the selected goal's progress rings"),
            .init(WSGoalPlanMediumPlanRingsPluginProvider(), title: "Goal Rings", subtitle: "Shows progress rings of selected goals"),
            .init(WSGoalPlanMediumPlanGridPluginProvider(), title: "Goals", subtitle: "Shows active goals in a grid"),
            .init(WSGoalPlanLargePlanGridPluginProvider(), title: "Goals", subtitle: "Shows active goals in a grid"),
            .init(WSGoalPlanMediumPlanListPluginProvider(), title: "Goals", subtitle: "Shows active goals in a list"),
            .init(WSGoalPlanLargePlanListPluginProvider(), title: "Goals", subtitle: "Shows active goals in a list"),
            .init(WSGoalTaskSmallTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a list"),
            .init(WSGoalTaskMediumTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a list"),
            .init(WSGoalTaskLargeTaskListPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a list"),
            .init(WSGoalTaskMediumTaskGridPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a grid"),
            .init(WSGoalTaskLargeTaskGridPluginProvider(), title: "Tasks", subtitle: "Shows selected goal tasks in a grid"),
        ]

        private static func make(_ rawValue: String, _ size: WSPluginSize) -> WSPluginType {
            return WSPluginType(rawValue, module: .goal, size: size)
        }
    }
}
