//
//  GoalPlanInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/9/1.
//

import Foundation

class GoalPlanInteractor: TodoTaskProcessorDelegate,
                          GoalPlanProcessorDelegate {

    /// 布局改变
    var didChangeLayoutType: (() -> Void)?
    
    /// 列表的信息改变
    var didChangeListInfo: (() -> Void)?
    
    /// 分组改变
    var didChangeGroups: ((AnyObject?) -> Void)?

    /// 当前分组数组
    var groups: [TodoGroup]?
    
    /// 列表配置
    let configuration: GoalPlanConfiguration
    
    var sort: TodoSort {
        return planOptionState.validatedSort(for: configuration)
    }
    
    var showCompleted: Bool {
        return self.planOptionState.showCompleted
    }
    
    var showDetail: Bool {
        return self.planOptionState.showDetail
    }
    
    private(set) var tasks: [TodoTask]?
    
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
    
    func layoutType() -> GoalPlanLayoutType {
        return .list
    }
    
    func setLayoutType(_ layoutType: GoalPlanLayoutType) {
        
    }
    
    func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    /// 标题
    func title() -> TextRepresentable? {
        let goalPlan = configuration.goalPlan
        if let image = resGetImage("todo_list_24") {
            let color = goalPlan.color
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: color,
                            trailingText: goalPlan.displayName,
                            separator: " ")
            return title
        }
        
        return goalPlan.displayName
    }
    
    /// 选项菜单管理器
    func planOptionConfig() -> GoalPlanOptionConfig? {
        var state = planOptionState
        state.layoutType = layoutType() /// 设置布局类型
        return GoalPlanOptionConfig.config(with: state, configuration: configuration)
    }
    
    // MARK: -
    var groupType: TodoGroupType {
        let groupType = planOptionState.validatedGroupType(for: configuration)
        return groupType
    }
    
    func loadGroups(with change: AnyObject? = nil) {
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
    
    private func loadTasksIfNeeded(completion: @escaping ([TodoTask]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.tasks)
            return
        }
        
        fetchTasks(completion: completion)
    }
    
    /// 获取任务方法
    func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        completion(nil)
    }
    
    /// 将任务根据分组类型和排序方式分组
    func groups(for tasks: [TodoTask]?, groupType: TodoGroupType, sort: TodoSort) -> [TodoGroup]? {
        return nil
    }
    
    func planOptionStateDidChange() {
        GoalState.shared.setPlanOptionSate(planOptionState, for: configuration)
    }

    // MARK: - 菜单操作
    func toggleShowCompleted() {
        planOptionState.showCompleted = !showCompleted
        planOptionStateDidChange()
        setNeedsRefresh()
        loadGroups()
    }
    
    func toggleShowDetail() {
        planOptionState.showDetail = !planOptionState.showDetail
        planOptionStateDidChange()
    }
    
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
