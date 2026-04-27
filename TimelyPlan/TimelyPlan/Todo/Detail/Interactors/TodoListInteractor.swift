//
//  TodoListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

enum TodoTaskListChange {
    case create(TodoTask)
}

class TodoListInteractor: TodoTaskProcessorDelegate {

    /// 布局改变
    var didChangeLayoutType: (() -> Void)?
    
    /// 列表的信息改变
    var didChangeListInfo: (() -> Void)?
    
    /// 分组改变
    var didChangeGroups: ((TodoTaskListChange?) -> Void)?

    /// 当前分组数组
    var groups: [TodoGroup]?
    
    /// 列表配置
    let configuration: TodoListConfiguration
    
    var sort: TodoSort {
        return self.listOptionState.validatedSort(for: self.configuration)
    }
    
    private(set) var tasks: [TodoTask]?
    
    private(set) var listOptionState: TodoListOptionState
    
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
    
    init(configuration: TodoListConfiguration) {
        self.configuration = configuration
        self.listOptionState = TodoState.shared.listOptionState(for: configuration) ?? TodoListOptionState()
        todo.addUpdater(self, for: [.task])
        
        self.placeholderProvider.emptyImage = resGetImage("placeholder_hashTag_80")
        self.placeholderProvider.state = self.loadingState
    }
    
    func layoutType() -> TodoListLayoutType {
        return .list
    }
    
    func setLayoutType(_ layoutType: TodoListLayoutType) {
        
    }
    
    func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    /// 标题
    func title() -> TextRepresentable? {
        return nil
    }
    
    /// 列表选项菜单管理器
    func listOptionConfig() -> TodoListOptionConfig? {
        var state = listOptionState
        state.layoutType = layoutType() /// 设置布局类型
        return TodoListOptionConfig.config(with: state, configuration: self.configuration)
    }
    
    /// 当前选中任务可用的任务操作类型数组
    func taskActionTypes(for selectedTasks: Set<TodoTask>) -> [TodoTaskActionType] {
        var actionTypes = [TodoTaskActionType]()
        let isAllDone = selectedTasks.allSatisfy { $0.isCompleted }
        if isAllDone {
            actionTypes.append(.undone)
        } else {
            actionTypes.append(.done)
        }
        
        actionTypes.append(contentsOf: [.move, .date, .priority])
        let isAllAddedToMyDay = selectedTasks.allSatisfy { $0.isAddedToMyDay }
        if isAllAddedToMyDay {
            actionTypes.append(.removeFromMyDay)
        } else {
            actionTypes.append(.addToMyDay)
        }
        
        actionTypes.append(.trash)
        return actionTypes
    }
    
    // MARK: -
    func loadGroups(with change: TodoTaskListChange? = nil) {
        let requestID = requestManager.executeRequest()
        let groupType = listOptionState.validatedGroupType(for: configuration)
        let sort = self.listOptionState.validatedSort(for: configuration)
        let change = change
        loadTasksIfNeeded { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let groups = TodoListInteractor.groups(for: tasks, groupType: groupType, sort: sort)
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
    
    func listOptionStateDidChange() {
        TodoState.shared.setListOptionSate(self.listOptionState, for: self.configuration)
    }

    // MARK: - 菜单操作
    func toggleShowCompleted() {
        self.listOptionState.showCompleted = !self.listOptionState.showCompleted
        self.listOptionStateDidChange()
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    var showDetail: Bool {
        return self.listOptionState.showDetail
    }
    
    func toggleShowDetail() {
        self.listOptionState.showDetail = !self.listOptionState.showDetail
        self.listOptionStateDidChange()
    }
    
    func setGroupType(_ groupType: TodoGroupType) {
        let groupType = self.configuration.validatedGroupType(groupType)
        guard self.listOptionState.groupType != groupType else {
            return
        }
        
        self.listOptionState.groupType = groupType
        self.listOptionStateDidChange()
        self.loadGroups()
    }
    
    func setSortType(_ sortType: TodoSortType) {
        var sort = self.listOptionState.validatedSort(for: self.configuration)
        sort.type = sortType
        setSort(sort)
    }
    
    func setSortOrder(_ sortOrder: TodoSortOrder) {
        var sort = self.listOptionState.validatedSort(for: self.configuration)
        sort.order = sortOrder
        setSort(sort)
    }
    
    private func setSort(_ sort: TodoSort) {
        let sort = self.configuration.validatedSort(sort)
        guard self.listOptionState.sort != sort else {
            return
        }
        
        self.listOptionState.sort = sort
        self.listOptionStateDidChange()
        self.loadGroups()
    }
    
    // MARK: - TodoTaskProcessorDelegate
    
    func didCreateTodoTask(_ task: TodoTask) {
        self.setNeedsRefresh()
        self.loadGroups(with: .create(task))
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didReorderTodoTask(_ task: TodoTask) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
    func didEmptyTrash() {
        
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
    func didUpdateActiveRepeatTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask]) {
        
    }
}


extension TodoListInteractor {
    
    static func interactor(for configuration: TodoListConfiguration) -> TodoListInteractor! {
        switch configuration {
        case let userListConfig as TodoUserListConfiguration:
            return TodoUserListInteractor(configuration: userListConfig)
        case let smartListConfig as TodoSmartListConfiguration:
            return TodoSmartListInteractor.smartListInteractor(with: smartListConfig)
        case let tagListConfig as TodoTagListConfiguration:
            return TodoTagListInteractor(configuration: tagListConfig)
        case let filterListConfig as TodoFilterListConfiguration:
            return TodoFilterListInteractor(configuration: filterListConfig)
        default:
            return nil
        }
    }

    static func groups(for tasks: [TodoTask]?, groupType: TodoGroupType, sort: TodoSort) -> [TodoGroup]? {
        guard let tasks = tasks, tasks.count > 0 else {
            return nil
        }

        let orderedTasks = sortedTasks(tasks, sort: sort)
        let groups = groupTasks(orderedTasks, groupType: groupType)
        return groups
    }
    
    /// 任务排序
    static func sortedTasks(_ tasks: [TodoTask], sort: TodoSort) -> [TodoTask] {
        let sortDescriptors = sortDescriptors(for: sort)
        return tasks.sorted(using: sortDescriptors)
    }
    
    static func sortDescriptors(for sort: TodoSort) -> [SortDescriptor<TodoTask>] {
        var results = [SortDescriptor<TodoTask>]()
        if sort.type != .manually {
            let completedSortDescriptor = SortDescriptor(\TodoTask.isCompleted, order: .forward)
            results.append(completedSortDescriptor)
        }
        
        results.append(sort.sortDescriptor)
        
        /// 辅助排序
        let types: [TodoSortType] = [.manually, .startDate, .dueDate]
        guard types.contains(sort.type) else {
            return results
        }
        
        /// 以创建日期辅助排序
        let creationDateSort = TodoSort(type: .creationDate, order: .ascending)
        results.append(creationDateSort.sortDescriptor)
        return results
    }
    
    /// 任务分组
    static func groupTasks(_ tasks: [TodoTask]?, groupType: TodoGroupType) -> [TodoGroup]? {
        guard let tasks = tasks, tasks.count > 0 else {
            return nil
        }

        switch groupType {
        case .none:
            return tasks.noneClassifiedTaskGroups()
        case .list:
            return tasks.listClassifiedTaskGroups()
        case .default:
            return tasks.statusClassifiedTaskGroups()
        case .startDate:
            return tasks.startDateClassifiedTaskGroups()
        case .dueDate:
            return tasks.dueDateClassifiedTaskGroups()
        case .priority:
            return tasks.priorityClassifiedTaskGroups()
        }
    }
}
