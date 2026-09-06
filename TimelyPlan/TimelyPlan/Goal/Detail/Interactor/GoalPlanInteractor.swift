//
//  GoalPlanInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation

enum GoalPlanTaskChange {
    case create(GoalTask)
}

class GoalPlanInteractor {

    /// 布局改变
    var didChangeLayoutType: (() -> Void)?
    
    /// 列表的信息改变
    var didChangeListInfo: (() -> Void)?
    
    /// 分组改变
    var didChangeGroups: ((GoalPlanTaskChange?) -> Void)?

    /// 当前分组数组
    var groups: [GoalTaskGroup]?
    
    /// 列表配置
    let configuration: GoalPlanConfiguration
    
    var sort: TodoSort {
        return planOptionState.validatedSort(for: configuration)
    }
    
    private(set) var tasks: [GoalTask]?
    
    private(set) var planOptionState: GoalPlanOptionState
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    /// 占位视图
    private(set) var placeholderProvider = TPLoadableListPlaceholderProvider()
        
    /// 加载状态
    private(set) var loadingState: TPListLoadingState = .initialLoading {
        didSet {
            placeholderProvider.state = loadingState
        }
    }
    
    func resetLoadingState() {
        self.loadingState = .initialLoading
    }
    
    init(configuration: GoalPlanConfiguration) {
        self.configuration = configuration
        self.planOptionState = GoalState.shared.planOptionState(for: configuration) ?? GoalPlanOptionState()
        self.placeholderProvider.state = self.loadingState
        GoalRepository.addUpdater(self)
    }

    func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    /// 标题
    func title() -> TextRepresentable? {
        let goalPlan = configuration.goalPlan
        if let image = resGetImage("goal_24") {
            let color = goalPlan.color
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(5),
                            imageColor: color,
                            trailingText: goalPlan.displayName,
                            separator: " ")
            return title
        }
        
        return goalPlan.displayName
    }
    
    /// 选项菜单管理器
    func planOptionConfig() -> GoalPlanOptionConfig? {
        let state = planOptionState
        return GoalPlanOptionConfig.config(with: state, configuration: configuration)
    }
    
    // MARK: -
    var groupType: TodoGroupType {
        let groupType = planOptionState.validatedGroupType(for: configuration)
        return groupType
    }
    
    func loadGroups(with change: GoalPlanTaskChange? = nil) {
        self.loadingState = .loading
        let requestID = requestManager.executeRequest()
        let groupType = self.groupType
        let sort = self.sort
        let change = change
        loadTasksIfNeeded { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let groups = self.groups(for: tasks, groupType: groupType, sort: sort)
                DispatchQueue.main.async {
                    guard self.requestManager.shouldProceed(with: requestID) else {
                        return
                    }
                    
                    self.tasks = tasks
                    self.groups = groups
                    self.needsRefresh = false
                    self.loadingState = .loaded
                    self.didChangeGroups?(change)
                }
            }
        }
    }
    
    private func loadTasksIfNeeded(completion: @escaping ([GoalTask]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.tasks)
            return
        }
        
        fetchTasks(completion: completion)
    }
    
    /// 获取任务方法
    func fetchTasks(completion: @escaping ([GoalTask]?) -> Void) {
        GoalRepository.fetchActiveGoalTasks(completion: completion)
    }
    
    /// 将任务根据分组类型和排序方式分组
    func groups(for tasks: [GoalTask]?, groupType: TodoGroupType, sort: TodoSort) -> [GoalTaskGroup]? {
        return GoalPlanInteractor.groups(for: tasks, groupType: groupType, sort: sort)
    }
    
    func planOptionStateDidChange() {
        GoalState.shared.setPlanOptionSate(planOptionState, for: configuration)
    }

    // MARK: - 菜单操作
    func setGroupType(_ groupType: TodoGroupType) {
        let groupType = configuration.validatedGroupType(groupType)
        guard planOptionState.groupType != groupType else {
            return
        }
        
        planOptionState.groupType = groupType
        planOptionStateDidChange()
        loadGroups()
    }
    
    func setSortType(_ sortType: TodoSortType) {
        var sort = planOptionState.validatedSort(for: configuration)
        sort.type = sortType
        setSort(sort)
    }
    
    func setSortOrder(_ sortOrder: TodoSortOrder) {
        var sort = planOptionState.validatedSort(for: configuration)
        sort.order = sortOrder
        setSort(sort)
    }
    
    private func setSort(_ sort: TodoSort) {
        let sort = configuration.validatedSort(sort)
        guard planOptionState.sort != sort else {
            return
        }
        
        planOptionState.sort = sort
        planOptionStateDidChange()
        loadGroups()
    }
}

extension GoalPlanInteractor: GoalTaskProcessorDelegate {
    
    func didChangeRemoteGoalTask(with results: EntityChangeResults<GoalTask>?) {
        setNeedsRefresh()
        loadGroups()
    }
      
    func didCreateGoalTask(_ goalTask: GoalTask) {
        setNeedsRefresh()
        loadGroups(with: .create(goalTask))
    }
    
    func didUpdateGoalTask(_ goalTask: GoalTask, with change: GoalTaskChange) {
        setNeedsRefresh()
        loadGroups()
    }
    
    func didUpdateGoalTasks(with changeInfos: [GoalTaskChangeInfo]) {
        setNeedsRefresh()
        loadGroups()
    }
    
    func didDeleteGoalTasks(_ goalTasks: [GoalTask]) {
        setNeedsRefresh()
        loadGroups()
    }
    
    func didReorderGoalTask(in goalTasks: [GoalTask], fromIndex: Int, toIndex: Int) {

    }
}

extension GoalPlanInteractor {
    
    static func groups(for tasks: [GoalTask]?, groupType: TodoGroupType, sort: TodoSort) -> [GoalTaskGroup]? {
        guard let tasks = tasks, tasks.count > 0 else {
            return nil
        }

        let orderedTasks = sortedTasks(tasks, sort: sort)
        let groups = groupTasks(orderedTasks, groupType: groupType)
        return groups
    }
    
    /// 任务排序
    static func sortedTasks(_ tasks: [GoalTask], sort: TodoSort) -> [GoalTask] {
        let sortDescriptors = sortDescriptors(for: sort)
        return tasks.sorted(using: sortDescriptors)
    }
    
    static func sortDescriptors(for sort: TodoSort) -> [SortDescriptor<GoalTask>] {
        var results = [SortDescriptor<GoalTask>]()
        if sort.type != .manually {
            let completedSortDescriptor = SortDescriptor(\GoalTask.isCompleted, order: .forward)
            results.append(completedSortDescriptor)
        }
        
        results.append(sort.goalTaskSortDescriptor)
        
        /// 辅助排序
        let types: [TodoSortType] = [.manually, .startDate, .dueDate]
        guard types.contains(sort.type) else {
            return results
        }
        
        /// 以创建日期辅助排序
        let creationDateSort = TodoSort(type: .creationDate, order: .ascending)
        results.append(creationDateSort.goalTaskSortDescriptor)
        return results
    }
    
    /// 任务分组
    static func groupTasks(_ tasks: [GoalTask]?, groupType: TodoGroupType) -> [GoalTaskGroup]? {
        guard let tasks = tasks, tasks.count > 0 else {
            return nil
        }

        switch groupType {
        case .none:
            return tasks.noneClassifiedTaskGroups()
        case .default:
            return tasks.statusClassifiedTaskGroups()
        case .startDate:
            return tasks.startDateClassifiedTaskGroups()
        case .dueDate:
            return tasks.dueDateClassifiedTaskGroups()
        case .completionDate:
            return tasks.completionDateClassifiedTaskGroups()
        case .priority:
            /// 目标任务无优先级概念，以权重替代
            return tasks.weightClassifiedTaskGroups()
        case .list, .custom:
            /// 目标任务无列表与板块概念，退化为不分组
            return tasks.noneClassifiedTaskGroups()
        }
    }
}
