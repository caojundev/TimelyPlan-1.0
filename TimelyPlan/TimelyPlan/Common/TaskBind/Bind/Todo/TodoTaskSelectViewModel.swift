//
//  TodoTaskSelectViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/29.
//

import Foundation

class TodoTaskSelectViewModel {

    var onGroupsChanged: (() -> Void)?
    
    /// 当前分组数组
    var groups: [TodoGroup]?

    private(set) var tasks: [TodoTask]?
    
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
    
    let showCompleted: Bool = false
    
    let sort = TodoSort(type: .creationDate, order: .descending)
    
    init() {
        self.placeholderProvider.state = self.loadingState
        self.placeholderProvider.emptyTitle = resGetString("No Task")
    }
 
    func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    // MARK: - 加载分组
    func loadGroups() {
        self.loadingState = .loading
        let requestID = requestManager.executeRequest()
        loadTasksIfNeeded { tasks in
            guard self.requestManager.shouldProceed(with: requestID) else {
                return
            }

            DispatchQueue.global(qos: .userInitiated).async {
                let groups = TodoListInteractor.groups(for: tasks,
                                                          groupType: .list,
                                                          sort: self.sort)
                DispatchQueue.main.async {
                    guard self.requestManager.shouldProceed(with: requestID) else {
                        return
                    }
                    
                    self.tasks = tasks
                    self.groups = groups
                    self.needsRefresh = false
                    self.loadingState = .loaded
                    self.onGroupsChanged?()
                }
            }
        }
    }
    
    private func loadTasksIfNeeded(completion: @escaping ([TodoTask]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.tasks)
            return
        }
        
        todo.fetchAllTasks(showCompleted: false, completion: completion)
    }
}
