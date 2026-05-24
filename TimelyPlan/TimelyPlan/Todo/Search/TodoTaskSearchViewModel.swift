//
//  TodoTaskSearchViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/5/24.
//

import Foundation

class TodoTaskSearchViewModel: NSObject {
    
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

    private(set) var state: TPListLoadingState = .loaded {
        didSet {
            placeholderProvider.state = state
        }
    }

    /// 占位视图
    private(set) lazy var placeholderProvider: TPLoadableListPlaceholderProvider = {
        let provider = TPLoadableListPlaceholderProvider()
        provider.emptyImage = resGetImage("placeholder_noSearchResult_80")
        return provider
    }()
    
    private let requestManager = TPRequestManager()
    
    func updateSearchResults(with searchText: String?) {
        let searchText = searchText?.whitespacesAndNewlinesTrimmedString
        guard self.searchText != searchText else {
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
        self.fetchResults(containText: searchText) { [weak self] results in
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
    
    private func fetchResults(containText text: String, completion: @escaping([TodoTask]?) -> Void) {
        todo.fetchScheduledTasks(in: .infiniteInterval, completion: completion)
    }
    
}
