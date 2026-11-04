//
//  TodoCountFetcher.swift
//  TimelyPlan
//
//  Created by caojun on 2026/11/4.
//

import Foundation

// MARK: - 数目变更通知

/// 待办数目变更的通知协议。
///
/// 数目变化时回调，`identifiers` 为受影响的条目标识；为 nil 表示无法确定范围，需要全部重新取数。
protocol TodoCountFetcherDelegate: AnyObject {
    
    func todoCountFetcher(_ fetcher: TodoCountFetcher, didChangeCountsFor identifiers: Set<String>?)
}

// MARK: - 数目获取

/// 待办未完成任务数目的统一获取入口。
///
/// 单例持有数目缓存，各处展示同一清单、标签或过滤器的数目只取数一次：
/// 命中缓存直接回调，未命中时通过仓库取数并缓存。
/// 同时监听任务、标签与过滤器的变更，失效对应缓存后通知所有更新器。
class TodoCountFetcher: NSObject {
    
    /// 单例
    static let shared = TodoCountFetcher()
    
    /// 数目缓存，键为条目标识
    private var counts: [String: Int] = [:]
    
    /// 已缓存的过滤器标识。任务变化时只需失效被展示过的过滤器，无需回仓库取全部过滤器
    private var filterIdentifiers: Set<String> = []
    
    private override init() {
        super.init()
        
        /// 任务数变化会影响清单、标签与过滤器的数目，三者统一观察
        TodoRepository.addUpdater(self, for: [.task, .tag, .filter])
    }
    
    // MARK: - 更新器
    /// 添加更新器。更新器由弱引用持有，无需手动移除
    func addUpdater(_ updater: TodoCountFetcherDelegate) {
        addDelegate(updater)
    }
    
    func removeUpdater(_ updater: TodoCountFetcherDelegate) {
        removeDelegate(updater)
    }
    
    // MARK: - 缓存
    /// 已缓存的数目
    func count(for item: IdentifiableItem) -> Int? {
        return cachedCount(for: item.identifier)
    }
    
    /// 获取数目。命中缓存直接回调，未命中时取数并缓存
    func fetchCount(for item: IdentifiableItem, completion: @escaping (Int) -> Void) {
        if let count = count(for: item) {
            completion(count)
            return
        }
        
        TodoRepository.fetchUncompletedTaskCount(for: item) { [weak self] count in
            self?.cache(count, for: item)
            completion(count)
        }
    }
    
    /// 失效指定条目的数目
    func invalidateCount(for item: IdentifiableItem) {
        invalidateCounts(for: [item.identifier])
    }
    
    /// 失效全部数目
    func invalidateAllCounts() {
        objc_sync_enter(self)
        counts.removeAll()
        filterIdentifiers.removeAll()
        objc_sync_exit(self)
        
        notifyUpdaters(identifiers: nil)
    }
}

// MARK: - 缓存读写

private extension TodoCountFetcher {
    
    func cachedCount(for identifier: String) -> Int? {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return counts[identifier]
    }
    
    func cache(_ count: Int, for item: IdentifiableItem) {
        objc_sync_enter(self)
        counts[item.identifier] = count
        if item is TodoFilter {
            filterIdentifiers.insert(item.identifier)
        }
        objc_sync_exit(self)
    }
    
    func invalidateCounts(for identifiers: Set<String>) {
        guard !identifiers.isEmpty else {
            return
        }
        
        objc_sync_enter(self)
        for identifier in identifiers {
            counts[identifier] = nil
        }
        filterIdentifiers.subtract(identifiers)
        objc_sync_exit(self)
        
        notifyUpdaters(identifiers: identifiers)
    }
    
    /// 通知更新器。数据变更可能来自后台线程，回调统一回到主线程
    func notifyUpdaters(identifiers: Set<String>?) {
        let block = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.notifyDelegates { (updater: TodoCountFetcherDelegate) in
                updater.todoCountFetcher(self, didChangeCountsFor: identifiers)
            }
        }
        
        if Thread.isMainThread {
            block()
        } else {
            DispatchQueue.main.async(execute: block)
        }
    }
    
    /// 任务自身关联的清单与标签
    func ownerIdentifiers(for tasks: [TodoTask]) -> Set<String> {
        var identifiers = Set<String>()
        for task in tasks {
            if let list = task.list {
                identifiers.insert(list.identifier)
            }
            
            identifiers.formUnion(task.tags?.map { $0.identifier } ?? [])
        }
        
        return identifiers
    }
    
    /// 任务变更影响的条目标识：所属清单与标签，外加已缓存的过滤器（规则的匹配范围无法快速判断）
    func affectedIdentifiers(for tasks: [TodoTask]) -> Set<String> {
        return ownerIdentifiers(for: tasks).union(cachedFilterIdentifiers())
    }
    
    /// 已缓存的过滤器标识。过滤器的数目只有在被展示过时才需要刷新
    func cachedFilterIdentifiers() -> Set<String> {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return filterIdentifiers
    }
}

// MARK: - TodoTaskProcessorDelegate

extension TodoCountFetcher: TodoTaskProcessorDelegate {
    
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        /// 远程变更的范围无法确定，保守地全部失效
        invalidateAllCounts()
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        invalidateCounts(for: affectedIdentifiers(for: [task]))
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        invalidateCounts(for: affectedIdentifiers(for: repeatTasks + updatedTasks))
    }
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        var identifiers = affectedIdentifiers(for: tasks)
        if let list = list {
            identifiers.insert(list.identifier)
        }
        
        invalidateCounts(for: identifiers)
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        didUpdateTodoTasks(with: [TodoTaskChangeInfo(task: task, change: change)])
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        var identifiers = Set<String>()
        for changeInfo in changeInfos {
            identifiers.formUnion(ownerIdentifiers(for: [changeInfo.task]))
            
            /// 移入 / 移出清单或标签时，变更前后两边的数目都要刷新
            switch changeInfo.change {
            case let .list(oldValue, newValue):
                if let identifier = oldValue?.identifier {
                    identifiers.insert(identifier)
                }
                
                if let identifier = newValue?.identifier {
                    identifiers.insert(identifier)
                }
            case let .tag(oldValue, newValue):
                identifiers.formUnion(oldValue?.map { $0.identifier } ?? [])
                identifiers.formUnion(newValue?.map { $0.identifier } ?? [])
            default:
                break
            }
        }
        
        identifiers.formUnion(cachedFilterIdentifiers())
        invalidateCounts(for: identifiers)
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
        var identifiers = affectedIdentifiers(for: tasks)
        if let list = section.list {
            identifiers.insert(list.identifier)
        }
        
        invalidateCounts(for: identifiers)
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        invalidateCounts(for: affectedIdentifiers(for: tasks))
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        invalidateCounts(for: affectedIdentifiers(for: tasks))
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        invalidateCounts(for: affectedIdentifiers(for: tasks))
    }
}

// MARK: - TodoTagProcessorDelegate

extension TodoCountFetcher: TodoTagProcessorDelegate {
    
    func didChangeRemoteTodoTag(with results: EntityChangeResults<TodoTag>?) {
        invalidateAllCounts()
    }
    
    func didCreateTodoTag(_ tag: TodoTag) {
        invalidateCounts(for: [tag.identifier])
    }
    
    func didDeleteTodoTag(_ tag: TodoTag) {
        invalidateCounts(for: [tag.identifier])
    }
    
    func didUpdateTodoTag(_ tag: TodoTag, with editingTag: TodoEditingTag) {
        invalidateCounts(for: [tag.identifier])
    }
}

// MARK: - TodoFilterProcessorDelegate

extension TodoCountFetcher: TodoFilterProcessorDelegate {
    
    func didChangeRemoteTodoFilter(with results: EntityChangeResults<TodoFilter>?) {
        invalidateAllCounts()
    }
    
    func didCreateTodoFilter(_ filter: TodoFilter) {
        invalidateCounts(for: [filter.identifier])
    }
    
    func didDeleteTodoFilter(_ filter: TodoFilter) {
        invalidateCounts(for: [filter.identifier])
    }
    
    func didUpdateTodoFilter(_ filter: TodoFilter, with editingFilter: TodoEditingFilter) {
        /// 规则变化后数目需要按新规则重新计算
        invalidateCounts(for: [filter.identifier])
    }
}
