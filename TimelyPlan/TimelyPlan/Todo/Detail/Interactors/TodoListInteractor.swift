//
//  TodoListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoListInteractor: TodoTaskProcessorDelegate {

    /// 布局改变
    var didChangeLayoutType: (() -> Void)?
    
    /// 列表的信息改变
    var didChangeListInfo: (() -> Void)?
    
    /// 分组改变
    var didChangeGroups: (() -> Void)?

    /// 当前分组数组
    var groups: [TodoGroup]?
    
    /// 列表配置
    let configuration: TodoListConfiguration
    
    private(set) var tasks: [TodoTask]?
    
    private(set) var state: TodoListOptionState
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    init(configuration: TodoListConfiguration) {
        self.configuration = configuration
        self.state = TodoState.shared.listOptionState(for: configuration) ?? TodoListOptionState()
        todo.addUpdater(self, for: [.task])
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
        var state = self.state
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
    func loadGroups() {
        let requestID = requestManager.executeRequest()
        let groupType = self.state.validatedGroupType(for: self.configuration)
        let sort = self.state.validatedSort(for: self.configuration)
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
                    self.didChangeGroups?()
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
        todo.fetchTasks { results in
            completion(results)
        }
    }
    
    func stateDidChange() {
        TodoState.shared.setListOptionSate(self.state, for: self.configuration)
    }

    // MARK: - 菜单操作
    func toggleShowCompleted() {
        self.state.showCompleted = !self.state.showCompleted
        self.stateDidChange()
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func setGroupType(_ groupType: TodoGroupType) {
        let groupType = self.configuration.validatedGroupType(groupType)
        guard self.state.groupType != groupType else {
            return
        }
        
        self.state.groupType = groupType
        self.stateDidChange()
        self.loadGroups()
    }
    
    func setSortType(_ sortType: TodoSortType) {
        var sort = self.state.validatedSort(for: self.configuration)
        sort.type = sortType
        setSort(sort)
    }
    
    func setSortOrder(_ sortOrder: TodoSortOrder) {
        var sort = self.state.validatedSort(for: self.configuration)
        sort.order = sortOrder
        setSort(sort)
    }
    
    private func setSort(_ sort: TodoSort) {
        let sort = self.configuration.validatedSort(sort)
        guard self.state.sort != sort else {
            return
        }
        
        self.state.sort = sort
        self.stateDidChange()
        self.loadGroups()
    }
    
    // MARK: - TodoTaskProcessorDelegate
    
    func didCreateTodoTask(_ task: TodoTask) {
        self.setNeedsRefresh()
        self.loadGroups()
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

    func didReorderTodoTask(_ task: TodoTask, fromIndex: Int, toIndex: Int) {
        
    }
}


extension TodoListInteractor {
    
    static func interactor(for configuration: TodoListConfiguration) -> TodoListInteractor {
        switch configuration {
        case let userListConfig as TodoUserListConfiguration:
            return TodoUserListInteractor(configuration: userListConfig)
        case let smartListConfig as TodoSmartListConfiguration:
            return TodoSmartListInteractor.smartListInteractor(with: smartListConfig)
        case let tagListConfig as TodoTagListConfiguration:
            return TodoTagListInteractor(configuration: tagListConfig)
        default:
            return TodoListInteractor(configuration: TodoListConfiguration(identifier: ""))
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
        var results = [sort.sortDescriptor]
        
        /// 辅助排序
        let types: [TodoSortType] = [.manually, .startDate, .dueDate]
        guard types.contains(sort.type) else {
            return results
        }
        
        /// 以创建日期辅助排序
        let secondarySort = TodoSort(type: .creationDate, order: sort.order)
        results.append(secondarySort.sortDescriptor)
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
