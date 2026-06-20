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

class TodoHomeUserTagViewModel: TodoUserTagViewModel {
    
    /// 区块是否展开
    var isExpanded: Bool {
        get {
            return TodoState.shared.isHomeTagExpanded
        }
        
        set {
            TodoState.shared.isHomeTagExpanded = newValue
        }
    }
}

class TodoUserTagViewModel: TodoBaseListViewModel {
    
    /// 数目改变
    var countDidChange: (([TodoTag]) -> Void)?
    
    /// 用户标签改变
    var tagsDidChange: ((TodoUserTagChange?) -> Void)?
    
    /// 标签数组
    private(set) var tags: [TodoTag]?
    
    private(set) var isLoading: Bool = false
    
    private(set) var state: TPListLoadingState = .initialLoading
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    override init() {
        super.init()
        TodoRepository.addUpdater(self)
    }

    func setNeedsRefresh() {
        self.needsRefresh = true
    }
    
    // MARK: -
    func loadTags(with change: TodoUserTagChange? = nil, completion: (() -> Void)? = nil) {
        self.isLoading = true
        let change = change
        let requestID = requestManager.executeRequest()
        loadTagsIfNeeded {[weak self] tags in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion?()
                return
            }

            self.tags = tags
            self.needsRefresh = false
            self.isLoading = false
            self.state = .loaded
            self.tagsDidChange?(change)
            completion?()
        }
    }
    
    private func loadTagsIfNeeded(completion: @escaping ([TodoTag]?) -> Void) {
        guard self.needsRefresh else {
            completion(self.tags)
            return
        }
        
        TodoRepository.fetchTags(completion: completion)
    }
}

extension TodoUserTagViewModel: TodoTagProcessorDelegate {
    
    func didChangeRemoteTodoTag(with results: EntityChangeResults<TodoTag>?) {
        setNeedsRefresh()
        loadTags(with: nil)
    }
    
    func didCreateTodoTag(_ tag: TodoTag) {
        setNeedsRefresh()
        loadTags(with: .create(tag))
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        setNeedsRefresh()
        loadTags()
    }
    
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        setNeedsRefresh()
        loadTags(with: .update(tag))
    }
    
    func didRecorderTodoTag(in tags: [TodoTag], fromIndex: Int, toIndex: Int) {
        /// 同步更新
        self.tags = TodoRepository.getTags()
        needsRefresh = false
        tagsDidChange?(nil)
    }
}

extension TodoUserTagViewModel: TodoTaskProcessorDelegate {

    private func didChangeTagForTasks(_ tasks: [TodoTask]) {
        if let tags = tasks.userTags {
            let tagsArray = Array(tags)
            counter.invalidateCount(for: tagsArray)
            countDidChange?(tagsArray)
        }
    }
    
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        if let tags = self.tags {
            /// 更新所有标签任务数目
            counter.invalidateCount(for: tags)
            countDidChange?(tags)
        }
    }
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        didChangeTagForTasks(tasks)
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
        var results = Set<TodoTag>()
        for changeInfo in changeInfos {
            let change = changeInfo.change
            switch change {
            case .completed(_, _):
                if let tags = changeInfo.task.tags, tags.count > 0 {
                    results.formUnion(Set(tags))
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
            let tagsArray = Array(results)
            counter.invalidateCount(for: tagsArray)
            countDidChange?(tagsArray)
        }
    }
}
