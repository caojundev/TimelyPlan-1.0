//
//  TodoSmartListViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/18.
//

import Foundation

class TodoSmartListViewModel: TodoBaseListViewModel,
                              SettingAgentObserver {
    
    /// 列表改变
    var listsDidChange: (() -> Void)?
    
    /// 数目改变
    var countDidChange: (([TodoSmartList]) -> Void)?
    
    /// 自动隐藏智能列表白名单（不隐藏）
    private let autoHideEmptyWhiteListTypes: [TodoSmartListType] = [.inbox, .myDay]
    
    private let types: [TodoSmartListType]
    
    private(set) var lists: [TodoSmartList] = []
    
    private let requestManager = TPRequestManager()
    
    init(types: [TodoSmartListType]) {
        self.types = types
        super.init()
        let displayTypes = self.displayTypes()
        self.lists = displayTypes.map { TodoSmartList(type: $0) }
        self.loadLists()
   
        /// 添加智能清单显示设置项监听
        TodoSetting.shared.addObserver(self, forKey: .smartListDisplay)
        todo.addUpdater(self)
    }

    func uncompletedTaskCount(for list: TodoSmartList) -> Int {
        return counter.count(for: list) ?? 0
    }
    
    private func loadLists(completion: (() -> Void)? = nil) {
        let requestID = requestManager.executeRequest()
        
        /// 更新当前所有显示类型任务数目
        let group = DispatchGroup()
        let displayTypes = displayTypes()
        for displayType in displayTypes {
            group.enter()
            self.fetchUncompletedTaskCount(for: TodoSmartList(type: displayType)) { _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            guard self.requestManager.shouldProceed(with: requestID) else {
               return
            }
            
            if self.updateLists() {
                self.listsDidChange?()
            }
        }
    }

    @discardableResult
    private func updateLists() -> Bool {
        let displayTypes = displayTypes()
        var visibleTypes: [TodoSmartListType] = []
        let display = TodoSetting.shared.smartListDisplay
        let autoHideEmpty = display?.autoHideEmpty ?? false
        if autoHideEmpty {
            for displayType in displayTypes {
                if autoHideEmptyWhiteListTypes.contains(displayType) {
                    /// 在白名单中显示该类型
                    visibleTypes.append(displayType)
                    continue
                }
            
                let count = counter.count(for: displayType.identifier) ?? 0
                if count > 0 {
                    visibleTypes.append(displayType)
                }
            }
        } else {
            visibleTypes = displayTypes
        }
    
        let visibleLists = visibleTypes.map { TodoSmartList(type: $0) }
        if self.lists != visibleLists {
            self.lists = visibleLists
            return true
        }

        return false
    }
    
    /// 显示的清单类型
    private func displayTypes() -> [TodoSmartListType] {
        var displayTypes = [TodoSmartListType]()
        let display = TodoSetting.shared.smartListDisplay
        let hiddenTypes = display?.hiddenListTypes ?? []
        for type in self.types {
            if hiddenTypes.contains(type) {
               continue
            }
            
            displayTypes.append(type)
        }
        
        return displayTypes
    }
    
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        if self.updateLists() {
            self.listsDidChange?()
        }
    }
}

extension TodoSmartListViewModel: TodoTaskProcessorDelegate {

    private func changeCount(of listTypes: [TodoSmartListType] = TodoSmartListType.allCases) {
        var lists = [TodoSmartList]()
        for listType in listTypes {
            if types.contains(listType) {
                let list = TodoSmartList(type: listType)
                lists.append(list)
            }
        }
        
        counter.invalidateCount(for: lists)
        self.loadLists { [weak self] in
            guard let visibleLists = self?.lists else {
                return
            }
            
            let updateLists = Set(visibleLists).intersection(Set(lists))
            self?.countDidChange?(Array(updateLists))
        }
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        changeCount()
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        var bInboxChanged: Bool = false
        for task in tasks {
            if task.list == nil {
                bInboxChanged = true
                break
            }
        }
        
        if !bInboxChanged, list == nil {
            bInboxChanged = true
        }
        
        if bInboxChanged {
            changeCount(of: [.inbox])
        }
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        changeCount()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        changeCount()
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        changeCount(of: [.trash])
    }
    
    func didEmptyTrash() {
        changeCount(of: [.trash])
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        let changeInfo = TodoTaskChangeInfo(task: task, change: change)
        self.didUpdateTodoTasks(with: [changeInfo])
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        changeCount()
    }
}
