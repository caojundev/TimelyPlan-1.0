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
    
    private var showCompleted: Bool = true
    
    var layoutType: TodoListLayoutType {
        return .list
    }
    
    private var groupType: TodoGroupType
    
    private var sort: TodoSort
    
    private let requestManager = TPRequestManager()
    
    /// 是否需要刷新任务
    private(set) var needsRefresh = true
    
    init(configuration: TodoListConfiguration) {
        self.configuration = configuration
        self.groupType = configuration.validatedGroupType(nil)
        self.sort = configuration.validatedSort(TodoSort())
        todo.addUpdater(self, for: [.task])
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
        guard let options = configuration.allowListOptions(), options.count > 0 else {
            return nil
        }
        
        var config = TodoListOptionConfig(options: options,
                                          groupType: self.groupType,
                                          sort: self.sort)
        config.showCompleted = self.showCompleted
        config.layoutType = self.layoutType
        config.allowGroupTypes = self.configuration.allowGroupTypes()
        config.allowSortTypes = self.configuration.allowSortTypes()
        config.allowSortOrders = self.configuration.allowSortOrders(for: self.sort.type)
        return config
    }
    
    /// 当前选中任务可用的任务操作类型数组
    func taskActionTypes(for selectedTasks: Set<TodoTask>) -> [TodoTaskActionType] {
        var actionTypes = [TodoTaskActionType]()
        var isAllDone = selectedTasks.count > 0 ? true : false
        for task in selectedTasks {
            if !task.isCompleted {
                isAllDone = false
            }
        }
        
        if isAllDone {
            actionTypes.append(.undone)
        } else {
            actionTypes.append(.done)
        }
        
        actionTypes.append(contentsOf: [.move, .date, .priority, .trash])
        return actionTypes
    }
    
    // MARK: -
    func loadGroups() {
        let requestID = requestManager.executeRequest()
        loadTasksIfNeeded { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    guard self.requestManager.shouldProceed(with: requestID) else {
                        return
                    }
                    
                    var groups = [TodoGroup]()
                    let group = TodoGroup(identifier: "MyGroup")
                    group.title = "所有任务分组"
                    group.tasks = tasks
                    groups.append(group)
                    
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
            print("❌无需重新获取任务")
            completion(self.tasks)
            return
        }
        
        print("✅获取任务")
        fetchTasks(completion: completion)
    }
    
    /// 获取任务方法
    func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        todo.fetchTasks { results in
            completion(results)
        }
    }
    
    func toggleShowCompleted() {
        self.showCompleted = !self.showCompleted
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    func setGroupType(_ groupType: TodoGroupType) {
        let groupType = self.configuration.validatedGroupType(groupType)
        guard self.groupType != groupType else {
            return
        }
        
        self.groupType = groupType
        self.loadGroups()
    }
    
    func setSortType(_ sortType: TodoSortType) {
        let sortType = self.configuration.validatedSortType(sortType)
        guard self.sort.type != sortType else {
            return
        }
        
        self.sort.type = sortType
        self.loadGroups()
    }
    
    func setSortOrder(_ sortOrder: TodoSortOrder) {
        let sortOrder = self.configuration.validatedSortOrder(sortOrder, for: self.sort.type)
        guard self.sort.order != sortOrder else {
            return
        }
        
        self.sort.order = sortOrder
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
            return TodoSmartListInteractor(configuration: smartListConfig)
        case let tagListConfig as TodoTagListConfiguration:
            return TodoTagListInteractor(configuration: tagListConfig)
        default:
            return TodoListInteractor(configuration: TodoListConfiguration(identifier: ""))
        }
    }
}
