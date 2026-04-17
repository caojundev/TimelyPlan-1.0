//
//  TodoUserTagViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/17.
//

import Foundation

enum TodoUserTagChange {
    case create(TodoTag)
    case update(TodoTag)
}

class TodoUserTagViewModel {
    
    /// 用户标签改变
    var tagsDidChange: ((TodoUserTagChange?) -> Void)?
    
    /// 标签数组
    private(set) var tags: [TodoTag]?
    
    private(set) var isLoading: Bool = false
    
    private(set) var state: TPListLoadingState = .initialLoading
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    init() {
        self.loadTags()
        todo.addUpdater(self, for: .tag)
    }

    func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    // MARK: -
    func loadTags(with change: TodoUserTagChange? = nil) {
        self.isLoading = true
        let change = change
        let requestID = requestManager.executeRequest()
        loadTagsIfNeeded {[weak self] tags in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                return
            }

            self.tags = tags
            self.needsRefresh = false
            self.isLoading = false
            self.state = .loaded
            self.tagsDidChange?(change)
        }
    }
    
    private func loadTagsIfNeeded(completion: @escaping ([TodoTag]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.tags)
            return
        }
        
        todo.fetchTags(completion: completion)
    }
}

extension TodoUserTagViewModel: TodoTagProcessorDelegate {
    
    func didCreateTodoTag(_ tag: TodoTag) {
        setNeedsRefresh()
        loadTags(with: .create(tag))
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        setNeedsRefresh()
        loadTags()
    }
    
    func didUpdateTodoTag(_ tag: TodoTag) {
        setNeedsRefresh()
        loadTags(with: .update(tag))
    }
    
    func didRecorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        setNeedsRefresh()
        /// 同步更新
        self.tags = todo.getTags()
        self.needsRefresh = false
        self.tagsDidChange?(nil)
    }
}
