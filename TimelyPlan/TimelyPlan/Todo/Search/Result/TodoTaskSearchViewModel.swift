//
//  TodoTaskSearchViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation

class TodoTaskSearchViewModel: NSObject, TodoTaskProcessorDelegate {
    
    /// 搜索结果改变
    var onResultsChanged: (() -> Void)?
    
    /// 当前结果对应的搜索文本
    private(set) var searchText: String?
    
    /// 搜索结果分组
    var groups: [TodoGroup]? {
        guard let tasks = tasks, tasks.count > 0 else {
            return nil
        }
        
        let group = TodoGroup(identifier: "SearchResults")
        group.isHeaderHidden = true
        group.tasks = tasks
        return [group]
    }
    
    /// 当前搜索结果
    private(set) var tasks: [TodoTask]?

    private(set) var state: TPListLoadingState = .initialLoading {
        didSet {
            placeholderProvider.state = state
        }
    }

    /// 占位视图
    private(set) lazy var placeholderProvider: TPLoadableListPlaceholderProvider = {
        let provider = TPLoadableListPlaceholderProvider()
        provider.state = .initialLoading
        provider.emptyImage = resGetImage("placeholder_noSearchResult_80")
        return provider
    }()
    
    private let requestManager = TPRequestManager()
    
    private(set) var options = TodoSearchOptions()
    
    override init() {
        super.init()
        TodoRepository.addUpdater(self, for: [.task])
    }
    
    func updateSearchOptions(_ options: TodoSearchOptions) {
        self.options = options
        reloadSearchResults()
    }
    
    func updateSearchResults(with searchText: String?, forceRefresh: Bool = false) {
        let searchText = searchText?.whitespacesAndNewlinesTrimmedString
        guard forceRefresh || self.searchText != searchText else {
            return
        }

        guard let searchText = searchText, searchText.count > 0 else {
            self.searchText = nil
            tasks = nil
            state = .loaded
            onResultsChanged?()
            return
        }

        self.searchText = searchText
        let requestID = requestManager.executeRequest()
        self.state = .loading
        self.fetchResults(matching: searchText) { [weak self] results in
            guard let self = self,
                  self.requestManager.shouldProceed(with: requestID),
                  searchText == self.searchText else {
                return
            }
            
            self.state = .loaded
            self.tasks = results
            self.onResultsChanged?()
        }
    }
    
    private func reloadSearchResults() {
        updateSearchResults(with: searchText, forceRefresh: true)
    }
    
    private func fetchResults(matching searchText: String, completion: @escaping([TodoTask]?) -> Void) {
        TodoRepository.searchTasks(matching: searchText,
                         options: options,
                         completion: completion)
    }
    
    // MARK: - TodoTaskProcessorDelegate
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        reloadSearchResults()
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        reloadSearchResults()
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
        reloadSearchResults()
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        reloadSearchResults()
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        reloadSearchResults()
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        reloadSearchResults()
    }
    
    func didReorderTodoTask(_ task: TodoTask) {
        reloadSearchResults()
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        reloadSearchResults()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
    func didEmptyTrash() {
        
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        
    }
    
}
