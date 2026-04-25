//
//  TodoSmartListInteractor.swift
//  TimelyPlan
//
//  Created by caojun on 2026/4/3.
//

import Foundation

class TodoSmartListInteractor: TodoListInteractor,
                                TPMidnightUpdatable {
    
    static func smartListInteractor(with configuration: TodoSmartListConfiguration) -> TodoSmartListInteractor {
        let listType = configuration.list.listType
        switch listType {
        case .inbox:
            return TodoInboxListInteractor(configuration: configuration)
        case .completed:
            return TodoCompletedListInteractor(configuration: configuration)
        case .trash:
            return TodoTrashListInteractor(configuration: configuration)
        default:
            return TodoSmartListInteractor(configuration: configuration)
        }
    }
    
    var list: TodoSmartList {
        return listConfiguration.list
    }
    
    var listConfiguration: TodoSmartListConfiguration {
       return configuration as! TodoSmartListConfiguration
    }
    
    override init(configuration: TodoListConfiguration) {
        super.init(configuration: configuration)
        
        /// 添加至凌晨更新对象
        TPMidnightScheduler.shared.addUpdater(self)
    }
    
    override func layoutType() -> TodoListLayoutType {
        let layoutType = TodoSetting.shared.listLayoutType(for: self.list.identifier)
        return layoutType ?? .list
    }
    
    override func setLayoutType(_ layoutType: TodoListLayoutType) {
        TodoSetting.shared.setListLayoutType(layoutType, for: self.list.identifier)
        
        /// 通知布局类型改变
        self.didChangeLayoutType?()
    }
    
    override func title() -> TextRepresentable? {
        let listName = self.list.title
        if let image = self.list.icon {
            let title: ASAttributedString
            title = .string(image: image,
                            imageSize: .size(4),
                            imageColor: self.list.color,
                            trailingText: listName,
                            separator: " ")
            return title
        }
        
        return listName
    }
    
    override func fetchTasks(completion: @escaping ([TodoTask]?) -> Void) {
        let showCompleted = self.state.showCompleted
        todo.fetchSmartListTasks(in: list,
                                 showCompleted: showCompleted,
                                 completion: completion)
    }
    
    // MARK: - TPMidnightUpdatable
    func updateAtMidnight() {
        guard list.listType.isScheduleType else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
}

class TodoInboxListInteractor: TodoSmartListInteractor {
    
  
}

class TodoCompletedListInteractor: TodoSmartListInteractor {
  
}

class TodoTrashListInteractor: TodoSmartListInteractor {
    
    override func taskActionTypes(for selectedTasks: Set<TodoTask>) -> [TodoTaskActionType] {
        return [.restore, .shred]
    }
    
    override func didRestoreTrashTodoTasks(_ tasks: [TodoTask]) {
        guard listConfiguration.list.listType == .trash else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    override func didDeleteTodoTasks(_ tasks: [TodoTask]) {
        guard listConfiguration.list.listType == .trash else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
    
    override func didEmptyTrash() {
        guard listConfiguration.list.listType == .trash else {
            return
        }
        
        self.setNeedsRefresh()
        self.loadGroups()
    }
}
