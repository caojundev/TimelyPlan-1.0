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

class TodoListInteractor: TodoTaskProcessorDelegate,
                          TodoListProcessorDelegate,
                          TodoSectionProcessorDelegate,
                          TodoTagProcessorDelegate {

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
        return listOptionState.validatedSort(for: configuration)
    }
    
    var showCompleted: Bool {
        return self.listOptionState.showCompleted
    }
    
    var showDetail: Bool {
        return self.listOptionState.showDetail
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
    
    func resetLoadingState() {
        self.loadingState = .initialLoading
    }
    
    init(configuration: TodoListConfiguration) {
        self.configuration = configuration
        self.listOptionState = TodoState.shared.listOptionState(for: configuration) ?? TodoListOptionState()
        self.placeholderProvider.state = self.loadingState
        TodoRepository.addUpdater(self, for: [.list, .section, .task, .tag])
    }
    
    /// 是否匹配分组
    func isQuickAddTask(_ task: TodoQuickAddTask, matches group: TodoGroup) -> Bool {
        return task.matchesGroup(group, groupType: self.groupType)
    }
        
    func quickAddTask(in group: TodoGroup) -> TodoQuickAddTask {
        let task = configuration.quickAddTask() ?? TodoQuickAddTask()
        switch groupType {
        case .startDate:
            if let dateType = TodoTaskStartDateType(identifier: group.identifier) {
                task.schedule = .schedule(for: dateType)
            }
        case .dueDate:
            if let dateType = TodoTaskDueDateType(identifier: group.identifier) {
                task.schedule = .schedule(for: dateType)
            }
        case .priority:
            if let priority = TodoTaskPriority(identifier: group.identifier) {
                task.priority = priority
            }
        case .custom:
            if let section = group.dataItem as? TodoSectionFeature {
                task.section = section
            }
        default:
            break
        }
        
        return task
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
        return TodoListOptionConfig.config(with: state,
                                           configuration: configuration)
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
    var groupType: TodoGroupType {
        let groupType = listOptionState.validatedGroupType(for: configuration)
        return groupType
    }
    
    func loadGroups(with change: TodoTaskListChange? = nil) {
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
        return TodoListInteractor.groups(for: tasks, groupType: groupType, sort: sort)
    }
    
    
    func listOptionStateDidChange() {
        TodoState.shared.setListOptionSate(self.listOptionState, for: self.configuration)
    }

    // MARK: - 菜单操作
    func importTasks(_ tasks: [TodoImportTask]) {
    
    }
    
    func toggleShowCompleted() {
        self.listOptionState.showCompleted = !showCompleted
        self.listOptionStateDidChange()
        self.setNeedsRefresh()
        self.loadGroups()
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
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        self.setNeedsRefresh()
        self.loadGroups(with: .create(task))
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
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
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
    func didEmptyTrash() {
        
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
    // MARK: - TodoListProcessorDelegate
    func didUpdateTodoList(_ list: TodoList, with editingList: TodoEditingList) {
        let detailOption = configuration.detailOption()
        guard detailOption.contains(.list), list.name != editingList.name, let tasks = tasks else {
            return
        }
        
        var shouldRefresh = false
        if groupType == .list {
            shouldRefresh = true
        } else {
            let newName = editingList.name
            shouldRefresh = tasks.contains { task in
                guard let taskList = task.list else { return false }
                return taskList.identifier == list.identifier && taskList.name != newName
            }
        }
        
        if shouldRefresh {
            setNeedsRefresh()
            loadGroups()
        }
    }
    
    // MARK: - TodoSectionProcessorDelegate,
    func didCreateTodoSection(_ section: TodoSection, in list: TodoList?) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didDeleteTodoSection(_ section: TodoSection) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
        
    func didUpdateTodoSection(_ section: TodoSection) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func didReorderTodoSection(in sections: [TodoSection], of list: TodoList?, from fromIndex: Int, to toIndex: Int) {
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    // MARK: - TodoTagProcessorDelegate
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        let detailOption = configuration.detailOption()
        guard detailOption.contains(.tag), let tasks = tasks else {
            return
        }
        
        let hasAffectedTask = tasks.contains { task in
            return task.tags?.contains(where: { aTag in
                return tag.identifier == aTag.identifier
            }) ?? false
        }
        
        if hasAffectedTask {
            setNeedsRefresh()
            loadGroups()
        }
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
        case .completionDate:
            return tasks.completionDateClassifiedTaskGroups()
        case .priority:
            return tasks.priorityClassifiedTaskGroups()
        case .custom:
            return tasks.customSectionClassifiedTaskGroups()
        }
    }
}
