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
    func loadFilters(with change: TodoFilterChange? = nil) {
        self.isLoading = true
        let change = change
        let requestID = requestManager.executeRequest()
        loadFiltersIfNeeded {[weak self] filters in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                return
            }

            self.filters = filters
            self.needsRefresh = false
            self.isLoading = false
            self.state = .loaded
            self.filtersDidChange?(change)
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

    func didCreateTodoFilter(_ tag: TodoFilter) {
        setNeedsRefresh()
        loadFilters(with: .create(tag))
    }
    
    func didDeleteTodoFilter(_ tag: TodoFilter) {
        setNeedsRefresh()
        loadFilters()
    }
    
    func didUpdateTodoFilter(_ tag: TodoFilter) {
        setNeedsRefresh()
        loadFilters(with: .update(tag))
    }
    
    func didReorderTodoFilter(in filters: [TodoFilter], fromIndex: Int, toIndex: Int) {
        setNeedsRefresh()
        
        /// 同步更新
        self.filters = todo.getFilters()
        self.needsRefresh = false
        self.filtersDidChange?(nil)
    }
}

/*
extension TodoFilterViewModel: TodoTaskProcessorDelegate {

    private func didChangeTagForTasks(_ tasks: [TodoTask]) {
        if let filters = tasks.userFilters {
            let filtersArray = Array(filters)
            counter.invalidateCount(for: filtersArray)
            countDidChange?(filtersArray)
        }
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        didChangeTagForTasks([task])
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        didChangeTagForTasks(tasks)
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        didChangeTagForTasks(tasks)
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        let changeInfo = TodoTaskChangeInfo(task: task, change: change)
        self.didUpdateTodoTasks(with: [changeInfo])
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        var results = Set<TodoFilter>()
        for changeInfo in changeInfos {
            let change = changeInfo.change
            switch change {
            case .completed(_, _):
                if let filters = changeInfo.task.filters, filters.count > 0 {
                    results.formUnion(Set(filters))
                }
            case .tag(let oldValue, let newValue):
                if let oldTags = oldValue, !oldTags.isEmpty {
                    results.formUnion(oldTags)
                }
                
                if let newTags = newValue, !newTags.isEmpty {
                    results.formUnion(newTags)
                }
            default:
                break
            }
        }
        
        if results.count > 0 {
            let filtersArray = Array(results)
            counter.invalidateCount(for: filtersArray)
            countDidChange?(filtersArray)
        }
    }
}
*/

