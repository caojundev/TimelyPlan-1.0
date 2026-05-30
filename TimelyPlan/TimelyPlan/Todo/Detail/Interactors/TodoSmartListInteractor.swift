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
        var title: String?
        let listType = listConfiguration.list.listType
        switch listType {
        case .inbox:
            title = resGetString("No tasks in the inbox")
        case .myDay:
            title = resGetString("No tasks in my day")
        case .completed:
            title = resGetString("No completed tasks")
        case .overdue:
            title = resGetString("No overdue tasks")
        case .today:
            title = resGetString("No tasks for today")
        case .tomorrow:
            title = resGetString("No tasks for tomorrow")
        case .upcoming:
            title = resGetString("No upcoming tasks")
        case .trash:
            title = resGetString("No tasks in the trash")
        }

        let imageName = "todo_smartlist_" + listType.rawValue + "_80"
        self.placeholderProvider.emptyImage = resGetImage(imageName)
        self.placeholderProvider.emptyTitle = title
            
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
        todo.fetchSmartListTasks(in: list,
                                 showCompleted: self.listOptionState.showCompleted,
                                 completion: completion)
    }
    
    override func importTasks(_ tasks: [TodoImportTask]) {
        guard list.listType == .inbox else {
            return
        }
        
        todo.importTasks(tasks, to: nil)
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
