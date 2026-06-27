//
//  TodoNotifiableTaskProvider.swift
//  TimelyPlan
//
//  Created by caojun on 2026/6/25.
//

import Foundation

class TodoNotifiableTaskProvider: LocalNotifiableTaskProvider {
    
    /// 通知任务改变代理
    weak var delegate: LocalNotifiableTaskChangeDelegate?

    private var results: [LocalNotifiable] = []
    
    /// 是否需要刷新任务
    private var needsRefresh = true

    private let requestManager = TPRequestManager()
    
    init() {
        /// 添加任务处理监听
        TodoRepository.addUpdater(self, for: [.task])
    }
    
    func setNeedsRefresh() {
        needsRefresh = true
    }
    
    func fetchNotifiableTasks(completion: @escaping ([LocalNotifiable]) -> Void) {
        guard needsRefresh else {
            completion(results)
            return
        }
        
        /// 重新获取
        let requestID = requestManager.executeRequest()
        TodoRepository.fetchNotifiableTasks { [weak self] tasks in
            guard let self = self, self.requestManager.shouldProceed(with: requestID) else {
                completion([])
                return
            }

            self.needsRefresh = false
            self.results = tasks ?? []
            completion(self.results)
        }
    }
}

extension TodoNotifiableTaskProvider: TodoTaskProcessorDelegate {
    
    func didChangeRemoteTodoTask(with results: EntityChangeResults<TodoTask>?) {
        setNeedsRefresh()
        delegate?.localNotifiableTaskDidChange()
    }
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        notifyIfNeeded(with: tasks)
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        notifyIfNeeded(with: [task])
    }
    
    func didCreateRepeatTodoTasks(_ repeatTasks: [TodoTask], updatedTasks: [TodoTask]) {
        let tasks = repeatTasks + updatedTasks
        notifyIfNeeded(with: tasks)
    }

    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        notifyIfNeeded(with: tasks)
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        notifyIfNeeded(with: tasks)
    }

    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        let changeInfo = TodoTaskChangeInfo(task: task, change: change)
        if shouldNotify(with: changeInfo) {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        let shouldNotify = changeInfos.anySatisfy{ self.shouldNotify(with: $0) }
        if shouldNotify {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }
    
    private func notifyIfNeeded(with changedTasks: [TodoTask]) {
        let shouldNotify = changedTasks.anySatisfy{ $0.hasReminder }
        if shouldNotify {
            setNeedsRefresh()
            delegate?.localNotifiableTaskDidChange()
        }
    }

    private func shouldNotify(with changeInfo: TodoTaskChangeInfo) -> Bool {
        if case .name(_, _) = changeInfo.change {
            /// 任务名称改变，并且设置了提醒
            return changeInfo.task.hasReminder
        }
    
        if case .completed(_, _) = changeInfo.change {
            /// 完成状态改变，并且设置了提醒
            return changeInfo.task.hasReminder
        }
        
        guard case let .schedule(oldValue, newValue) = changeInfo.change else {
            return false
        }
        
        if oldValue?.reminder != nil || newValue?.reminder != nil {
            return true
        }
        
        return false
    }
    
}
