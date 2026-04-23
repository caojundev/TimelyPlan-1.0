//
//  TodoFilterViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/19.
//

import Foundation

enum TodoFilterChange {
    case create(TodoFilter)
    case update(TodoFilter)
}

class TodoHomeFilterViewModel: TodoFilterViewModel {
    
    /// 区块是否展开
    var isExpanded: Bool {
        get {
            return TodoState.shared.isHomeFilterExpanded
        }
        
        set {
            TodoState.shared.isHomeFilterExpanded = newValue
        }
    }
}

class TodoFilterViewModel: TodoBaseListViewModel {
    
    /// 数目改变
    var countDidChange: (([TodoFilter]) -> Void)?
    
    /// 用户标签改变
    var filtersDidChange: ((TodoFilterChange?) -> Void)?
    
    /// 标签数组
    private(set) var filters: [TodoFilter]?
    
    private(set) var isLoading: Bool = false
    
    private(set) var state: TPListLoadingState = .initialLoading
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    override init() {
        super.init()
        self.loadFilters()
        todo.addUpdater(self)
    }

    func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    // MARK: -
    func loadFilters(with change: TodoFilterChange? = nil,
                     completion: ((Bool) -> Void)? = nil) {
        self.isLoading = true
        let change = change
        let requestID = requestManager.executeRequest()
        loadFiltersIfNeeded {[weak self] filters in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion?(false)
                return
            }

            self.filters = filters
            self.needsRefresh = false
            self.isLoading = false
            self.state = .loaded
            self.filtersDidChange?(change)
            completion?(true)
        }
    }
    
    private func loadFiltersIfNeeded(completion: @escaping ([TodoFilter]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.filters)
            return
        }
        
        todo.fetchFilters(completion: completion)
    }
}


extension TodoFilterViewModel: TodoFilterProcessorDelegate {

    func didCreateTodoFilter(_ filter: TodoFilter) {
        setNeedsRefresh()
        loadFilters(with: .create(filter))
    }
    
    func didDeleteTodoFilter(_ filter: TodoFilter) {
        setNeedsRefresh()
        loadFilters()
    }
    
    func didUpdateTodoFilter(_ filter: TodoFilter) {
        setNeedsRefresh()
        loadFilters(with: .update(filter)) { [weak self] _ in
            /// 加载最新的 filters 后根据新规则获取任务数目
            self?.didChangeCount(for: [filter])
        }
    }
    
    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        setNeedsRefresh()
        
        /// 同步更新
        self.filters = todo.getFilters()
        self.needsRefresh = false
        self.filtersDidChange?(nil)
    }
}


extension TodoFilterViewModel: TodoTaskProcessorDelegate {

    private func didChangeCountForAllFilters() {
        if let filters = self.filters {
            counter.invalidateCount(for: filters)
            countDidChange?(filters)
        }
    }
    
    private func didChangeCount(for filters: [TodoFilter]) {
        counter.invalidateCount(for: filters)
        countDidChange?(filters)
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        didChangeCountForAllFilters()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        didChangeCountForAllFilters()
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        didChangeCountForAllFilters()
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        let changeInfo = TodoTaskChangeInfo(task: task, change: change)
        self.didUpdateTodoTasks(with: [changeInfo])
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        didChangeCountForAllFilters()
    }
}

