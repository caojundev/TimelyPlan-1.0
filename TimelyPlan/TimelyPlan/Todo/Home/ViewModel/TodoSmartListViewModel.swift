//
//  TodoSmartListViewModel.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/18.
//

import Foundation

class TodoSmartListViewModel: TodoBaseListViewModel,
                              SettingAgentObserver,
                              TPMidnightUpdatable {
    
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
        TodoSetting.shared.addObserver(self, forKey: .smartListDisplay)
        TPMidnightScheduler.shared.addUpdater(self)
        todo.addUpdater(self)
    }

    func uncompletedTaskCount(for list: TodoSmartList) -> Int {
        return counter.count(for: list) ?? 0
    }
    
    func loadLists(completion: (() -> Void)? = nil) {
        let requestID = requestManager.executeRequest()
        
        /// 更新当前所有显示类型任务数目
        let group = DispatchGroup()
        for type in self.types {
            group.enter()
            self.fetchUncompletedTaskCount(for: TodoSmartList(type: type)) { _ in
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            guard self.requestManager.shouldProceed(with: requestID) else {
                completion?()
                return
            }
            
            self.updateLists()
            completion?()
        }
    }

    private func updateLists(){
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
    
        self.lists = visibleTypes.map { TodoSmartList(type: $0) }
        self.listsDidChange?()
    }
    
    private func countChanged(of listTypes: [TodoSmartListType] = TodoSmartListType.allCases) {
        var lists = [TodoSmartList]()
        for listType in listTypes {
            if types.contains(listType) {
                let list = TodoSmartList(type: listType)
                lists.append(list)
            }
        }
        
        counter.invalidateCount(for: lists)
        loadLists { [weak self] in
            guard let visibleLists = self?.lists else {
                return
            }

            let updateLists = Set(visibleLists).intersection(Set(lists))
            self?.countDidChange?(Array(updateLists))
        }
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
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        /// 计划智能清单改变
        self.countChanged(of: TodoSmartListType.scheduleTypes)
    }
    
    // MARK: - SettingAgentObserver
    func settingAgentDidChangeValue(for keyName: String) {
        self.updateLists()
    }
}

extension TodoSmartListViewModel: TodoTaskProcessorDelegate {
    
    func didImportTodoTasks(_ tasks: [TodoTask], to list: TodoList?) {
        self.countChanged()
    }
    
    func didCreateTodoTask(_ task: TodoTask) {
        self.countChanged()
    }
    
    func didMoveTodoTasks(_ tasks: [TodoTask], to section: TodoSectionFeature) {
        var bInboxChanged: Bool = false
        for task in tasks {
            if task.list == nil {
                bInboxChanged = true
                break
            }
        }
        
        if !bInboxChanged, section.list == nil {
            bInboxChanged = true
        }
        
        if bInboxChanged {
            countChanged(of: [.inbox])
        }
    }
    
    func didMoveTodoTasksToTrash(_ tasks: [TodoTask]) {
        countChanged()
    }
    
    func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        countChanged()
    }
    
    func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        countChanged(of: [.trash])
    }
    
    func didEmptyTrash() {
        countChanged(of: [.trash])
    }
    
    func didUpdateTodoTask(_ task: TodoTask, with change: TodoTaskChange) {
        let changeInfo = TodoTaskChangeInfo(task: task, change: change)
        self.didUpdateTodoTasks(with: [changeInfo])
    }
    
    func didUpdateTodoTasks(with changeInfos: [TodoTaskChangeInfo]) {
        countChanged()
    }
}
